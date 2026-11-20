package com.evilchess.server.sync;

import static org.assertj.core.api.Assertions.assertThat;

import com.evilchess.server.IntegrationTest;
import java.util.List;
import org.junit.jupiter.api.Test;

class SyncIntegrationTest extends IntegrationTest {

    private static String change(String kind, String key, String payload, String at) {
        return payload == null
                ? "{\"kind\":\"%s\",\"key\":\"%s\",\"deleted\":true,\"updatedAt\":\"%s\"}".formatted(kind, key, at)
                : "{\"kind\":\"%s\",\"key\":\"%s\",\"payload\":%s,\"deleted\":false,\"updatedAt\":\"%s\"}"
                        .formatted(kind, key, quote(payload), at);
    }

    private static String quote(String s) {
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
    }

    private Res sync(String token, long since, String... changes) throws Exception {
        return post("/api/v1/sync", "{\"since\":%d,\"changes\":[%s]}".formatted(since, String.join(",", changes)),
                token);
    }

    @Test
    void twoDevicesConvergeWithLastWriteWins() throws Exception {
        String token = newUser();

        // Device A pushes a game and the settings.
        Res a1 = sync(token, 0,
                change("game", "pgn:abc", "{\"pgn\":\"1. e4\"}", "2026-11-01T10:00:00Z"),
                change("settings", "app", "{\"theme\":\"dark\"}", "2026-11-01T10:00:00Z"));
        assertThat(a1.status()).isEqualTo(200);
        long cursorA = ((Number) a1.json("$.cursor")).longValue();

        // Device B pulls everything from scratch.
        Res b1 = sync(token, 0);
        List<String> keys = b1.json("$.changes[*].key");
        assertThat(keys).containsExactlyInAnyOrder("pgn:abc", "app");
        long cursorB = ((Number) b1.json("$.cursor")).longValue();

        // B changes the settings later; A changes them earlier (offline): B wins.
        sync(token, cursorB, change("settings", "app", "{\"theme\":\"light\"}", "2026-11-02T10:00:00Z"));
        Res a2 = sync(token, cursorA, change("settings", "app", "{\"theme\":\"stale\"}", "2026-11-01T12:00:00Z"));
        List<String> payloads = a2.json("$.changes[?(@.key == 'app')].payload");
        assertThat(payloads).containsExactly("{\"theme\":\"light\"}");

        // Deletes travel too.
        long cursor = ((Number) a2.json("$.cursor")).longValue();
        sync(token, cursor, change("game", "pgn:abc", null, "2026-11-03T10:00:00Z"));
        Res b2 = sync(token, cursorB);
        List<Boolean> deleted = b2.json("$.changes[?(@.key == 'pgn:abc')].deleted");
        assertThat(deleted).containsExactly(true);
    }

    @Test
    void usersOnlySeeTheirOwnData() throws Exception {
        String alice = newUser();
        String bob = newUser();
        sync(alice, 0, change("game", "secret", "{}", "2026-11-01T10:00:00Z"));
        List<Object> bobs = sync(bob, 0).json("$.changes");
        assertThat(bobs).isEmpty();
        assertThat(post("/api/v1/sync", "{\"since\":0,\"changes\":[]}").status()).isEqualTo(401);
    }

    @Test
    void largeHistoriesArePaged() throws Exception {
        String token = newUser();
        for (int batch = 0; batch < 3; batch++) {
            String[] changes = new String[200];
            for (int i = 0; i < 200; i++) {
                changes[i] = change("game", "g" + batch + "-" + i, "{}", "2026-11-01T10:00:00Z");
            }
            assertThat(sync(token, Long.MAX_VALUE / 2, changes).status()).isEqualTo(200);
        }
        Res page1 = sync(token, 0);
        assertThat((Boolean) page1.json("$.hasMore")).isTrue();
        assertThat((List<?>) page1.json("$.changes")).hasSize(500);
        Res page2 = sync(token, ((Number) page1.json("$.cursor")).longValue());
        assertThat((Boolean) page2.json("$.hasMore")).isFalse();
        assertThat((List<?>) page2.json("$.changes")).hasSize(100);
    }

    @Test
    void rejectsBadInput() throws Exception {
        String token = newUser();
        assertThat(sync(token, 0, change("nope", "k", "{}", "2026-11-01T10:00:00Z")).status()).isEqualTo(400);
        assertThat(sync(token, 0, change("game", "bad key!", "{}", "2026-11-01T10:00:00Z")).status())
                .isEqualTo(400);
        assertThat(sync(token, 0, change("game", "k", "{}", "2099-01-01T00:00:00Z")).status()).isEqualTo(400);
    }
}
