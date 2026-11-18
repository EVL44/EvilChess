package com.evilchess.server.sync;

import com.evilchess.server.common.ApiException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.regex.Pattern;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Device sync: every item is a (kind, key) → opaque payload with the time the
 * client changed it. Conflicts are settled by last-write-wins on that time;
 * clients pull everything the server stored after their cursor.
 */
@Service
public class SyncService {

    public record Change(String kind, String key, String payload, boolean deleted, Instant updatedAt) {}

    public record Pulled(String kind, String key, String payload, boolean deleted, Instant updatedAt, long seq) {}

    public record Result(long cursor, boolean hasMore, List<Pulled> changes) {}

    /** Kinds the app syncs; anything else is refused. */
    public static final List<String> KINDS =
            List.of("game", "analysis", "settings", "puzzleAttempt", "import");

    static final int MAX_PUSH = 200;
    static final int PAGE = 500;
    static final int MAX_PAYLOAD = 1_000_000;
    private static final Pattern KEY = Pattern.compile("^[\\w:.\\-]{1,200}$");

    private final JdbcClient jdbc;

    public SyncService(JdbcClient jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional
    public Result sync(UUID userId, long since, List<Change> changes) {
        if (changes.size() > MAX_PUSH) {
            throw ApiException.badRequest("too_many_changes", "Send at most " + MAX_PUSH + " changes per request");
        }
        for (Change c : changes) {
            validate(c);
            put(userId, c);
        }
        List<Pulled> pulled = jdbc.sql("""
                SELECT kind, item_key, payload, deleted, updated_at, server_seq
                FROM sync_items WHERE user_id = ? AND server_seq > ?
                ORDER BY server_seq LIMIT ?
                """).params(userId, since, PAGE + 1)
                .query((rs, i) -> new Pulled(rs.getString(1), rs.getString(2), rs.getString(3),
                        rs.getBoolean(4), rs.getTimestamp(5).toInstant(), rs.getLong(6)))
                .list();
        boolean hasMore = pulled.size() > PAGE;
        List<Pulled> page = hasMore ? pulled.subList(0, PAGE) : pulled;
        long cursor = page.isEmpty() ? since : page.get(page.size() - 1).seq();
        return new Result(cursor, hasMore, page);
    }

    /** Stores [c] unless the server already has a newer version. */
    public void put(UUID userId, Change c) {
        jdbc.sql("""
                INSERT INTO sync_items (user_id, kind, item_key, payload, deleted, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
                ON CONFLICT (user_id, kind, item_key) DO UPDATE SET
                    payload = EXCLUDED.payload,
                    deleted = EXCLUDED.deleted,
                    updated_at = EXCLUDED.updated_at,
                    server_seq = nextval('sync_items_server_seq_seq')
                WHERE sync_items.updated_at < EXCLUDED.updated_at
                """)
                .params(userId, c.kind(), c.key(), c.deleted() ? null : c.payload(), c.deleted(),
                        Timestamp.from(c.updatedAt()))
                .update();
    }

    private static void validate(Change c) {
        if (c.kind() == null || !KINDS.contains(c.kind())) {
            throw ApiException.badRequest("invalid_kind", "Unknown kind: " + c.kind());
        }
        if (c.key() == null || !KEY.matcher(c.key()).matches()) {
            throw ApiException.badRequest("invalid_key", "Invalid key");
        }
        if (c.updatedAt() == null || c.updatedAt().isAfter(Instant.now().plusSeconds(300))) {
            throw ApiException.badRequest("invalid_time", "updatedAt missing or in the future");
        }
        if (!c.deleted() && (c.payload() == null || c.payload().length() > MAX_PAYLOAD)) {
            throw ApiException.badRequest("invalid_payload", "Payload missing or larger than 1 MB");
        }
    }
}
