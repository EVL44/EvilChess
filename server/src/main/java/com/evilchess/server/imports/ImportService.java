package com.evilchess.server.imports;

import com.evilchess.server.common.ApiException;
import com.evilchess.server.config.AppProperties;
import com.evilchess.server.sync.SyncService;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.regex.Pattern;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

/**
 * Imports a linked Lichess / Chess.com account's games on the server, so
 * every signed-in device gets them through sync ("import" items holding the
 * PGN). Jobs run one at a time, as both APIs ask, and resume from the newest
 * game already imported.
 */
@Service
public class ImportService {

    private static final Logger log = LoggerFactory.getLogger(ImportService.class);
    private static final Pattern USERNAME = Pattern.compile("^[A-Za-z0-9_-]{2,40}$");
    public static final List<String> PROVIDERS = List.of("lichess", "chesscom");

    public record Account(
            String provider, String username, Instant newestGameAt, Instant lastSyncedAt,
            String status, String lastError, int imported) {}

    private final JdbcClient jdbc;
    private final SyncService sync;
    private final JsonMapper json;
    private final AppProperties.Imports config;
    private final HttpClient http = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();
    private final ExecutorService worker = Executors.newSingleThreadExecutor(r -> {
        Thread t = new Thread(r, "game-import");
        t.setDaemon(true);
        return t;
    });

    public ImportService(JdbcClient jdbc, SyncService sync, JsonMapper json, AppProperties props) {
        this.jdbc = jdbc;
        this.sync = sync;
        this.json = json;
        this.config = props.imports();
    }

    public List<Account> accounts(UUID userId) {
        return jdbc.sql("""
                SELECT provider, username, newest_game_at, last_synced_at, status, last_error, imported
                FROM linked_accounts WHERE user_id = ? ORDER BY provider
                """).param(userId).query(Account.class).list();
    }

    public Account link(UUID userId, String provider, String username) {
        checkProvider(provider);
        if (username == null || !USERNAME.matcher(username.trim()).matches()) {
            throw ApiException.badRequest("invalid_username", "Invalid username");
        }
        String name = username.trim();
        // A different username starts from scratch; the same one keeps its cursor.
        jdbc.sql("""
                INSERT INTO linked_accounts (user_id, provider, username) VALUES (?, ?, ?)
                ON CONFLICT (user_id, provider) DO UPDATE SET
                    username = EXCLUDED.username,
                    newest_game_at = CASE WHEN lower(linked_accounts.username) = lower(EXCLUDED.username)
                                          THEN linked_accounts.newest_game_at END,
                    imported = CASE WHEN lower(linked_accounts.username) = lower(EXCLUDED.username)
                                    THEN linked_accounts.imported ELSE 0 END
                """).params(userId, provider, name).update();
        return account(userId, provider);
    }

    public void unlink(UUID userId, String provider) {
        jdbc.sql("DELETE FROM linked_accounts WHERE user_id = ? AND provider = ?").params(userId, provider).update();
    }

    /** Queues an import; returns immediately. Running jobs are not queued twice. */
    public Future<?> start(UUID userId, String provider) {
        checkProvider(provider);
        int queued = jdbc.sql("""
                UPDATE linked_accounts SET status = 'queued', last_error = NULL
                WHERE user_id = ? AND provider = ? AND status NOT IN ('queued', 'running')
                """).params(userId, provider).update();
        if (queued == 0) {
            account(userId, provider); // 404 when not linked
            return java.util.concurrent.CompletableFuture.completedFuture(null);
        }
        return worker.submit(() -> run(userId, provider));
    }

    public Account account(UUID userId, String provider) {
        return jdbc.sql("""
                SELECT provider, username, newest_game_at, last_synced_at, status, last_error, imported
                FROM linked_accounts WHERE user_id = ? AND provider = ?
                """).params(userId, provider).query(Account.class).optional()
                .orElseThrow(() -> ApiException.notFound("not_linked", "No " + provider + " account linked"));
    }

    private void run(UUID userId, String provider) {
        Account acc = account(userId, provider);
        jdbc.sql("UPDATE linked_accounts SET status = 'running' WHERE user_id = ? AND provider = ?")
                .params(userId, provider).update();
        int[] count = {0};
        Instant[] newest = {acc.newestGameAt()};
        try {
            GameSink sink = (externalId, url, pgn, playedAt, speed) -> {
                Map<String, Object> payload = new LinkedHashMap<>();
                payload.put("provider", provider);
                payload.put("externalId", externalId);
                payload.put("url", url);
                payload.put("pgn", pgn);
                payload.put("playedAt", playedAt == null ? null : playedAt.toEpochMilli());
                payload.put("speed", speed);
                payload.put("username", acc.username());
                sync.put(userId, new SyncService.Change("import", provider + ":" + externalId,
                        json.writeValueAsString(payload), false, Instant.now()));
                count[0]++;
                if (playedAt != null && (newest[0] == null || playedAt.isAfter(newest[0]))) newest[0] = playedAt;
                return count[0] < config.maxGames();
            };
            if (provider.equals("lichess")) {
                lichess(acc.username(), acc.newestGameAt(), sink);
            } else {
                chesscom(acc.username(), acc.newestGameAt(), sink);
            }
            jdbc.sql("""
                    UPDATE linked_accounts SET status = 'idle', last_synced_at = now(),
                        newest_game_at = ?, imported = imported + ?
                    WHERE user_id = ? AND provider = ?
                    """).params(newest[0] == null ? null : Timestamp.from(newest[0]), count[0], userId, provider)
                    .update();
        } catch (Exception e) {
            log.warn("Import {} for {} failed: {}", provider, userId, e.toString());
            jdbc.sql("""
                    UPDATE linked_accounts SET status = 'error', last_error = ?,
                        newest_game_at = ?, imported = imported + ?
                    WHERE user_id = ? AND provider = ?
                    """).params(String.valueOf(e.getMessage()),
                            newest[0] == null ? null : Timestamp.from(newest[0]), count[0], userId, provider)
                    .update();
        }
    }

    @FunctionalInterface
    interface GameSink {
        /** Returns false to stop (limit reached). */
        boolean accept(String externalId, String url, String pgn, Instant playedAt, String speed) throws Exception;
    }

    // ------------------------------------------------------------- Lichess

    void lichess(String username, Instant since, GameSink sink) throws Exception {
        String q = "pgnInJson=true&clocks=true&opening=true&evals=false"
                + "&perfType=ultraBullet,bullet,blitz,rapid,classical,correspondence"
                + "&max=" + config.maxGames()
                + (since == null ? "" : "&since=" + (since.toEpochMilli() + 1));
        HttpRequest req = request(config.lichessBaseUrl() + "/api/games/user/" + enc(username) + "?" + q)
                .header("Accept", "application/x-ndjson").build();
        HttpResponse<InputStream> res = http.send(req, HttpResponse.BodyHandlers.ofInputStream());
        check(res.statusCode(), "Lichess", username);
        try (BufferedReader r = new BufferedReader(new InputStreamReader(res.body(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = r.readLine()) != null) {
                if (line.isBlank()) continue;
                JsonNode g = json.readTree(line);
                String variant = text(g, "variant");
                if (variant != null && !List.of("standard", "fromPosition", "chess960").contains(variant)) continue;
                String id = text(g, "id");
                String pgn = text(g, "pgn");
                if (id == null || pgn == null) continue;
                Instant at = g.has("createdAt") ? Instant.ofEpochMilli(g.get("createdAt").asLong()) : null;
                if (!sink.accept(id, "https://lichess.org/" + id, pgn, at, text(g, "speed"))) return;
            }
        }
    }

    // ----------------------------------------------------------- Chess.com

    void chesscom(String username, Instant since, GameSink sink) throws Exception {
        String user = username.toLowerCase(Locale.ROOT);
        JsonNode archives = getJson(config.chesscomBaseUrl() + "/pub/player/" + enc(user) + "/games/archives",
                "Chess.com", username);
        YearMonth from = since == null ? null : YearMonth.from(since.atZone(ZoneOffset.UTC));
        List<String> urls = new ArrayList<>();
        for (JsonNode u : archives.path("archives")) urls.add(u.asString());
        for (String url : urls) {
            String[] parts = url.split("/");
            YearMonth month = YearMonth.of(Integer.parseInt(parts[parts.length - 2]),
                    Integer.parseInt(parts[parts.length - 1]));
            if (from != null && month.isBefore(from)) continue;
            // Archive URLs are absolute; keep the path so tests can point at a fake server.
            String path = URI.create(url).getPath();
            JsonNode data = getJson(config.chesscomBaseUrl() + path, "Chess.com", username);
            for (JsonNode g : data.path("games")) {
                if (!"chess".equals(text(g, "rules"))) continue;
                String pgn = text(g, "pgn");
                if (pgn == null) continue;
                Instant at = g.has("end_time") ? Instant.ofEpochSecond(g.get("end_time").asLong()) : null;
                if (since != null && at != null && !at.isAfter(since)) continue;
                String gameUrl = text(g, "url");
                String id = text(g, "uuid");
                if (id == null && gameUrl != null) id = gameUrl.substring(gameUrl.lastIndexOf('/') + 1);
                if (id == null) continue;
                String speed = text(g, "time_class");
                if (!sink.accept(id, gameUrl, pgn, at, "daily".equals(speed) ? "correspondence" : speed)) return;
            }
        }
    }

    // ------------------------------------------------------------- helpers

    private JsonNode getJson(String url, String site, String username) throws IOException, InterruptedException {
        HttpResponse<String> res = http.send(request(url).header("Accept", "application/json").build(),
                HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        check(res.statusCode(), site, username);
        return json.readTree(res.body());
    }

    private HttpRequest.Builder request(String url) {
        return HttpRequest.newBuilder(URI.create(url))
                .timeout(Duration.ofMinutes(5))
                .header("User-Agent", config.userAgent());
    }

    private static void check(int status, String site, String username) throws IOException {
        if (status == 404) throw new IOException(site + " user \"" + username + "\" not found");
        if (status == 429) throw new IOException(site + " rate limit reached, try again later");
        if (status != 200) throw new IOException(site + " returned HTTP " + status);
    }

    private static String text(JsonNode node, String field) {
        JsonNode v = node.get(field);
        return v == null || v.isNull() ? null : v.asString();
    }

    private static String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    private static void checkProvider(String provider) {
        if (!PROVIDERS.contains(provider)) throw ApiException.badRequest("invalid_provider", "Unknown provider");
    }
}
