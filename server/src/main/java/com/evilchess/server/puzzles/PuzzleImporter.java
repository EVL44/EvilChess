package com.evilchess.server.puzzles;

import com.github.luben.zstd.ZstdInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Loads the Lichess puzzle database (https://database.lichess.org/#puzzles,
 * CC0) into the {@code puzzles} table.
 *
 * <p>Run once with {@code --evilchess.puzzles.import=/path/lichess_db_puzzle.csv.zst}
 * (plain .csv works too). Rows already present are skipped, so it can be
 * re-run to pick up new monthly exports.
 *
 * <p>CSV columns: PuzzleId, FEN, Moves, Rating, RatingDeviation, Popularity,
 * NbPlays, Themes, GameUrl, OpeningTags. FEN is the position before the
 * opponent's move; the first move in Moves is that opponent move.
 */
@Component
public class PuzzleImporter implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(PuzzleImporter.class);
    private static final int BATCH = 5_000;

    private final JdbcTemplate jdbc;
    private final String importPath;

    public PuzzleImporter(JdbcTemplate jdbc, @Value("${evilchess.puzzles.import:}") String importPath) {
        this.jdbc = jdbc;
        this.importPath = importPath;
    }

    @Override
    public void run(ApplicationArguments args) throws IOException {
        if (importPath == null || importPath.isBlank()) return;
        Path path = Path.of(importPath);
        log.info("Importing puzzles from {}", path);
        try (InputStream in = Files.newInputStream(path)) {
            long n = importStream(path.toString().endsWith(".zst") ? new ZstdInputStream(in) : in);
            log.info("Puzzle import done: {} rows read", n);
        }
    }

    /** Imports CSV from [in]; returns the number of rows read. */
    public long importStream(InputStream in) throws IOException {
        long count = 0;
        List<Object[]> batch = new ArrayList<>(BATCH);
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.isBlank() || line.startsWith("PuzzleId,")) continue;
                Object[] row = parse(line);
                if (row == null) continue;
                batch.add(row);
                count++;
                if (batch.size() == BATCH) {
                    flush(batch);
                    if (count % 500_000 == 0) log.info("… {} puzzles", count);
                }
            }
        }
        flush(batch);
        return count;
    }

    /** One CSV line → insert parameters, or null when malformed. Fields never contain commas. */
    static Object[] parse(String line) {
        String[] f = line.split(",", -1);
        if (f.length < 8) return null;
        try {
            return new Object[] {
                f[0], f[1], f[2],
                Integer.parseInt(f[3]), Integer.parseInt(f[4]),
                Integer.parseInt(f[5]), Integer.parseInt(f[6]),
                " " + f[7].trim() + " ",
                f.length > 9 && !f[9].isBlank() ? f[9].trim() : null,
            };
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void flush(List<Object[]> batch) {
        if (batch.isEmpty()) return;
        jdbc.batchUpdate("""
                INSERT INTO puzzles (id, fen, moves, rating, rating_rd, popularity, nb_plays, themes, opening_tags)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT (id) DO NOTHING
                """, batch);
        batch.clear();
    }
}
