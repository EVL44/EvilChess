package com.evilchess.server.imports;

import static org.assertj.core.api.Assertions.assertThat;

import com.evilchess.server.IntegrationTest;
import com.jayway.jsonpath.JsonPath;
import com.sun.net.httpserver.HttpServer;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

/** Imports run against a local fake of the Lichess and Chess.com APIs. */
class ImportIntegrationTest extends IntegrationTest {

    static final HttpServer fake;
    static final Map<String, String> routes = new ConcurrentHashMap<>();
    static final List<String> requested = new CopyOnWriteArrayList<>();

    static {
        try {
            fake = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
            fake.createContext("/", ex -> {
                String key = ex.getRequestURI().getPath();
                requested.add(ex.getRequestURI().toString());
                String body = routes.get(key);
                byte[] bytes = (body == null ? "" : body).getBytes(StandardCharsets.UTF_8);
                ex.sendResponseHeaders(body == null ? 404 : 200, bytes.length == 0 ? -1 : bytes.length);
                if (bytes.length > 0) {
                    try (OutputStream out = ex.getResponseBody()) {
                        out.write(bytes);
                    }
                }
                ex.close();
            });
            fake.start();
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    @DynamicPropertySource
    static void urls(DynamicPropertyRegistry r) {
        String base = "http://127.0.0.1:" + fake.getAddress().getPort();
        r.add("evilchess.imports.lichess-base-url", () -> base);
        r.add("evilchess.imports.chesscom-base-url", () -> base);
    }

    @AfterAll
    static void stop() {
        fake.stop(0);
    }

    @BeforeEach
    void clear() {
        routes.clear();
        requested.clear();
    }

    static final String PGN = "[White \\\"carol\\\"]\\n[Black \\\"dave\\\"]\\n\\n1. e4 e5 0-1";

    private String waitForIdle(String token, String provider) throws Exception {
        for (int i = 0; i < 100; i++) {
            Res r = get("/api/v1/imports", token);
            List<String> status = r.json("$[?(@.provider == '" + provider + "')].status");
            if (!status.isEmpty() && !status.get(0).equals("queued") && !status.get(0).equals("running")) {
                return status.get(0);
            }
            Thread.sleep(50);
        }
        throw new AssertionError("import did not finish");
    }

    @Test
    void lichessImportArrivesThroughSyncAndResumes() throws Exception {
        String token = newUser();
        routes.put("/api/games/user/carol", String.join("\n",
                "{\"id\":\"g1\",\"variant\":\"standard\",\"speed\":\"blitz\",\"createdAt\":1760000000000,\"pgn\":\"" + PGN + "\"}",
                "{\"id\":\"g2\",\"variant\":\"crazyhouse\",\"createdAt\":1760000100000,\"pgn\":\"" + PGN + "\"}",
                "{\"id\":\"g3\",\"variant\":\"standard\",\"speed\":\"rapid\",\"createdAt\":1760000200000,\"pgn\":\"" + PGN + "\"}"));

        assertThat(call(HttpMethod.PUT, "/api/v1/imports/lichess", "{\"username\":\"carol\"}", token).status())
                .isEqualTo(200);
        assertThat(post("/api/v1/imports/lichess/sync", null, token).status()).isEqualTo(202);
        assertThat(waitForIdle(token, "lichess")).isEqualTo("idle");

        Res pulled = post("/api/v1/sync", "{\"since\":0,\"changes\":[]}", token);
        List<String> keys = pulled.json("$.changes[*].key");
        assertThat(keys).containsExactlyInAnyOrder("lichess:g1", "lichess:g3"); // variant skipped
        String payload = ((List<String>) pulled.json("$.changes[?(@.key == 'lichess:g1')].payload")).get(0);
        assertThat((String) JsonPath.read(payload, "$.pgn")).contains("1. e4 e5");
        assertThat((String) JsonPath.read(payload, "$.username")).isEqualTo("carol");
        assertThat((Integer) get("/api/v1/imports", token).json("$[0].imported")).isEqualTo(2);

        // The next run asks only for newer games.
        requested.clear();
        post("/api/v1/imports/lichess/sync", null, token);
        waitForIdle(token, "lichess");
        assertThat(requested.get(0)).contains("since=1760000200001");
    }

    @Test
    void chesscomImportReadsMonthlyArchives() throws Exception {
        String token = newUser();
        String base = "http://127.0.0.1:" + fake.getAddress().getPort();
        routes.put("/pub/player/alice/games/archives",
                "{\"archives\":[\"" + base + "/pub/player/alice/games/2026/09\"]}");
        routes.put("/pub/player/alice/games/2026/09", """
                {"games":[
                  {"url":"https://www.chess.com/game/live/1","uuid":"u1","rules":"chess","time_class":"blitz",
                   "end_time":1760000000,"pgn":"%s"},
                  {"url":"https://www.chess.com/game/live/2","uuid":"u2","rules":"chess960","time_class":"blitz",
                   "end_time":1760000100,"pgn":"%s"}
                ]}""".formatted(PGN, PGN));

        call(HttpMethod.PUT, "/api/v1/imports/chesscom", "{\"username\":\"Alice\"}", token);
        post("/api/v1/imports/chesscom/sync", null, token);
        assertThat(waitForIdle(token, "chesscom")).isEqualTo("idle");
        List<String> keys = post("/api/v1/sync", "{\"since\":0,\"changes\":[]}", token).json("$.changes[*].key");
        assertThat(keys).containsExactly("chesscom:u1");
    }

    @Test
    void unknownUsersEndInAnError() throws Exception {
        String token = newUser();
        call(HttpMethod.PUT, "/api/v1/imports/lichess", "{\"username\":\"ghost\"}", token);
        post("/api/v1/imports/lichess/sync", null, token);
        assertThat(waitForIdle(token, "lichess")).isEqualTo("error");
        assertThat((String) get("/api/v1/imports", token).json("$[0].lastError")).contains("not found");
    }

    @Test
    void validation() throws Exception {
        String token = newUser();
        assertThat(call(HttpMethod.PUT, "/api/v1/imports/lichess", "{\"username\":\"no spaces!\"}", token)
                .status()).isEqualTo(400);
        assertThat(call(HttpMethod.PUT, "/api/v1/imports/fics", "{\"username\":\"x1\"}", token).status())
                .isEqualTo(400);
        assertThat(post("/api/v1/imports/lichess/sync", null, token).status()).isEqualTo(404);
    }
}
