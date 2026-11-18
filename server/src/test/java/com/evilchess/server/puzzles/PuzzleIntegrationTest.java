package com.evilchess.server.puzzles;

import static org.assertj.core.api.Assertions.assertThat;

import com.evilchess.server.IntegrationTest;
import com.github.luben.zstd.ZstdOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

class PuzzleIntegrationTest extends IntegrationTest {

    @Autowired
    PuzzleImporter importer;

    @Autowired
    PuzzleService service;

    @BeforeEach
    void loadSample() throws Exception {
        jdbc.sql("DELETE FROM puzzles").update();
        try (InputStream in = getClass().getResourceAsStream("/puzzles-sample.csv")) {
            assertThat(importer.importStream(in)).isEqualTo(8); // the "bad" row is skipped
        }
    }

    @Test
    void importIsIdempotentAndReadsZstd() throws Exception {
        byte[] csv;
        try (InputStream in = getClass().getResourceAsStream("/puzzles-sample.csv")) {
            csv = in.readAllBytes();
        }
        ByteArrayOutputStream zst = new ByteArrayOutputStream();
        try (ZstdOutputStream out = new ZstdOutputStream(zst)) {
            out.write(csv);
        }
        importer.importStream(new com.github.luben.zstd.ZstdInputStream(new ByteArrayInputStream(zst.toByteArray())));
        assertThat(jdbc.sql("SELECT COUNT(*) FROM puzzles").query(Integer.class).single()).isEqualTo(8);
        assertThat(jdbc.sql("SELECT themes FROM puzzles WHERE id = '00007'").query(String.class).single())
                .isEqualTo(" fork short endgame ");
    }

    @Test
    void ratedPuzzlesMoveTheRatingOnlyOnce() throws Exception {
        String token = newUser();
        Res next = get("/api/v1/puzzles/next", token);
        assertThat(next.status()).isEqualTo(200);
        String id = next.json("$.id");
        List<String> moves = next.json("$.moves");
        assertThat(moves).isNotEmpty();

        Res win = post("/api/v1/puzzles/" + id + "/attempt", "{\"win\":true}", token);
        assertThat((Boolean) win.json("$.rated")).isTrue();
        assertThat((Integer) win.json("$.delta")).isPositive();
        int after = win.json("$.rating");

        Res again = post("/api/v1/puzzles/" + id + "/attempt", "{\"win\":false}", token);
        assertThat((Boolean) again.json("$.rated")).isFalse();
        assertThat((Integer) again.json("$.rating")).isEqualTo(after);

        Res me = get("/api/v1/me", token);
        assertThat((Integer) me.json("$.puzzleRating")).isEqualTo(after);
        assertThat((Integer) me.json("$.puzzlesPlayed")).isEqualTo(1);

        // That puzzle is not served again.
        for (int i = 0; i < 10; i++) {
            assertThat((String) get("/api/v1/puzzles/next", token).json("$.id")).isNotEqualTo(id);
        }
    }

    @Test
    void themedPuzzles() throws Exception {
        String token = newUser();
        Res fork = get("/api/v1/puzzles/next?theme=fork", token);
        assertThat((String) fork.json("$.id")).isEqualTo("00007");
        List<String> themes = fork.json("$.themes");
        assertThat(themes).contains("fork");
        post("/api/v1/puzzles/00007/attempt", "{\"win\":false}", token);
        assertThat(get("/api/v1/puzzles/next?theme=fork", token).status()).isEqualTo(404);
        assertThat(get("/api/v1/puzzles/next?theme=drop%20table", token).status()).isEqualTo(400);
    }

    @Test
    void puzzlesNeedSignInExceptDailyAndBatch() throws Exception {
        assertThat(get("/api/v1/puzzles/next", null).status()).isEqualTo(401);
        assertThat(post("/api/v1/puzzles/00001/attempt", "{\"win\":true}").status()).isEqualTo(401);
        assertThat(get("/api/v1/puzzles/daily", null).status()).isEqualTo(200);
        assertThat(get("/api/v1/puzzles/batch?count=3", null).status()).isEqualTo(200);
    }

    @Test
    void dailyIsStablePerDay() {
        LocalDate day = LocalDate.of(2030, 1, 1);
        String first = service.daily(day).id();
        assertThat(service.daily(day).id()).isEqualTo(first);
        // Prefers popular, medium puzzles: in the sample that's 00001, 00002 or 00007.
        assertThat(List.of("00001", "00002", "00007")).contains(first);
    }

    @Test
    void batchGoesFromEasyToHard() throws Exception {
        Res batch = get("/api/v1/puzzles/batch?count=5&from=600&to=2000", null);
        List<Integer> ratings = batch.json("$[*].rating");
        assertThat(ratings).hasSizeGreaterThanOrEqualTo(4).isSorted();
        List<String> ids = batch.json("$[*].id");
        assertThat(ids).doesNotHaveDuplicates();
    }

    @Test
    void rushKeepsTheBestScore() throws Exception {
        String token = newUser();
        Res first = post("/api/v1/rush", "{\"mode\":\"3min\",\"score\":12}", token);
        assertThat((Boolean) first.json("$.newBest")).isTrue();
        Res worse = post("/api/v1/rush", "{\"mode\":\"3min\",\"score\":7}", token);
        assertThat((Boolean) worse.json("$.newBest")).isFalse();
        assertThat((Integer) worse.json("$.best")).isEqualTo(12);
        assertThat(post("/api/v1/rush", "{\"mode\":\"forever\",\"score\":1}", token).status()).isEqualTo(400);

        Res bests = get("/api/v1/rush", token);
        Map<String, Integer> map = bests.json("$");
        assertThat(map).containsEntry("3min", 12).containsEntry("5min", 0).containsEntry("survival", 0);
    }

    @Test
    void parseHandlesMissingOpeningTags() {
        Object[] row = PuzzleImporter.parse("x,fen,e2e4,1000,80,90,100,mate,url,");
        assertThat(row).isNotNull();
        assertThat(row[8]).isNull();
        assertThat(PuzzleImporter.parse("x,fen,e2e4,notanumber,80,90,100,mate,url,")).isNull();
    }
}
