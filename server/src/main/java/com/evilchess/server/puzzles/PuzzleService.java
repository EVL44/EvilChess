package com.evilchess.server.puzzles;

import com.evilchess.server.common.ApiException;
import com.evilchess.server.users.UserRepository;
import com.evilchess.server.users.UserRepository.User;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;
import java.util.regex.Pattern;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PuzzleService {

    /** A puzzle as sent to the app. The first move is the opponent's. */
    public record Puzzle(String id, String fen, List<String> moves, int rating, List<String> themes) {}

    public record AttemptResult(boolean rated, int rating, int delta, int rd, boolean provisional) {}

    public record RushBest(String mode, int best, boolean newBest) {}

    /** Theme names are Lichess's camelCase tags ("fork", "mateIn2", …). */
    private static final Pattern THEME = Pattern.compile("^[a-zA-Z0-9]{1,40}$");

    /** Rush modes the app offers. */
    public static final List<String> RUSH_MODES = List.of("3min", "5min", "survival");

    private final JdbcClient jdbc;
    private final UserRepository users;
    private final Glicko2 glicko = new Glicko2(0.75, 45, 350);
    private final Map<LocalDate, Puzzle> dailyCache = new ConcurrentHashMap<>();

    public PuzzleService(JdbcClient jdbc, UserRepository users) {
        this.jdbc = jdbc;
        this.users = users;
    }

    private record Row(String id, String fen, String moves, int rating, String themes) {
        Puzzle toPuzzle() {
            return new Puzzle(id, fen, Arrays.asList(moves.trim().split(" ")), rating,
                    Arrays.stream(themes.trim().split(" ")).filter(s -> !s.isEmpty()).toList());
        }
    }

    private static final String COLUMNS = "id, fen, moves, rating, themes";

    private static String themeClause(String theme) {
        if (theme == null || theme.isBlank()) return "";
        if (!THEME.matcher(theme).matches()) throw ApiException.badRequest("invalid_theme", "Unknown theme");
        return " AND themes LIKE '% " + theme + " %'";
    }

    /** A puzzle near the user's rating that they have not tried yet. */
    public Puzzle next(UUID userId, String theme) {
        User user = users.byId(userId).orElseThrow();
        int target = (int) Math.round(user.puzzleRating()) + ThreadLocalRandom.current().nextInt(-100, 101);
        String filter = themeClause(theme) + """
                 AND NOT EXISTS (SELECT 1 FROM puzzle_attempts a
                                 WHERE a.user_id = :user AND a.puzzle_id = p.id)
                """;
        Optional<Row> up = jdbc.sql("SELECT " + COLUMNS + " FROM puzzles p WHERE rating >= :r"
                        + filter + " ORDER BY rating LIMIT 1")
                .param("r", target).param("user", userId).query(Row.class).optional();
        Row row = up.or(() -> jdbc.sql("SELECT " + COLUMNS + " FROM puzzles p WHERE rating < :r"
                                + filter + " ORDER BY rating DESC LIMIT 1")
                        .param("r", target).param("user", userId).query(Row.class).optional())
                .orElseThrow(() -> ApiException.notFound("no_puzzle", "No puzzle left for this filter"));
        return row.toPuzzle();
    }

    /**
     * Records a rated attempt. Only the first attempt at a puzzle moves the
     * rating (Glicko-2 against the puzzle's own rating, one game per period).
     */
    @Transactional
    public AttemptResult attempt(UUID userId, String puzzleId, boolean win) {
        record P(int rating, int ratingRd) {}
        P puzzle = jdbc.sql("SELECT rating, rating_rd FROM puzzles WHERE id = ?").param(puzzleId)
                .query(P.class).optional()
                .orElseThrow(() -> ApiException.notFound("unknown_puzzle", "Unknown puzzle"));
        User user = jdbc.sql("SELECT id FROM users WHERE id = ? FOR UPDATE").param(userId)
                .query(UUID.class).optional().flatMap(users::byId).orElseThrow();

        boolean already = jdbc.sql("SELECT EXISTS (SELECT 1 FROM puzzle_attempts WHERE user_id = ? AND puzzle_id = ?)")
                .params(userId, puzzleId).query(Boolean.class).single();
        if (already) {
            return new AttemptResult(false, (int) Math.round(user.puzzleRating()), 0,
                    (int) Math.round(user.puzzleRd()), user.puzzleRd() > 110);
        }

        Glicko2.Rating before = new Glicko2.Rating(user.puzzleRating(), user.puzzleRd(), user.puzzleVol());
        Glicko2.Rating after = glicko.update(before, List.of(
                new Glicko2.Result(puzzle.rating(), Math.max(puzzle.ratingRd(), 45), win ? 1 : 0)));
        users.setPuzzleRating(userId, after.rating(), after.rd(), after.volatility());
        jdbc.sql("INSERT INTO puzzle_attempts (user_id, puzzle_id, win, rating_after) VALUES (?, ?, ?, ?)")
                .params(userId, puzzleId, win, after.rating()).update();
        int newRating = (int) Math.round(after.rating());
        return new AttemptResult(true, newRating, newRating - (int) Math.round(before.rating()),
                (int) Math.round(after.rd()), after.rd() > 110);
    }

    /**
     * Today's puzzle (UTC): the same for everyone, picked deterministically
     * from popular, well-tested puzzles of medium difficulty.
     */
    public Puzzle daily(LocalDate date) {
        return dailyCache.computeIfAbsent(date, d -> {
            String where = " FROM puzzles WHERE popularity >= 90 AND nb_plays >= 1000"
                    + " AND rating BETWEEN 1400 AND 2200";
            int count = jdbc.sql("SELECT COUNT(*)" + where).query(Integer.class).single();
            if (count == 0) {
                where = " FROM puzzles";
                count = jdbc.sql("SELECT COUNT(*)" + where).query(Integer.class).single();
            }
            if (count == 0) throw ApiException.notFound("no_puzzle", "The puzzle database is empty");
            long offset = Math.floorMod(seed(d.toString()), count);
            return jdbc.sql("SELECT " + COLUMNS + where + " ORDER BY id OFFSET ? LIMIT 1")
                    .param(offset).query(Row.class).single().toPuzzle();
        });
    }

    public Puzzle daily() {
        return daily(LocalDate.now(ZoneOffset.UTC));
    }

    /**
     * Puzzles spread from [from] to [to] rating, easiest first (Puzzle Rush,
     * offline packs). Public, so guests can play too.
     */
    public List<Puzzle> batch(int count, int from, int to, String theme) {
        int n = Math.max(1, Math.min(count, 100));
        int lo = Math.max(400, Math.min(from, to));
        int hi = Math.min(3200, Math.max(from, to));
        String filter = themeClause(theme);
        Map<String, Puzzle> picked = new LinkedHashMap<>();
        for (int i = 0; i < n; i++) {
            int target = n == 1 ? lo : lo + (hi - lo) * i / (n - 1);
            target += ThreadLocalRandom.current().nextInt(0, 40);
            List<Row> rows = jdbc.sql("SELECT " + COLUMNS + " FROM puzzles WHERE rating >= ?" + filter
                            + " ORDER BY rating LIMIT 5")
                    .param(target).query(Row.class).list();
            for (Row r : rows) {
                if (!picked.containsKey(r.id())) {
                    picked.put(r.id(), r.toPuzzle());
                    break;
                }
            }
        }
        return new ArrayList<>(picked.values());
    }

    @Transactional
    public RushBest submitRush(UUID userId, String mode, int score) {
        if (!RUSH_MODES.contains(mode)) throw ApiException.badRequest("invalid_mode", "Unknown rush mode");
        if (score < 0 || score > 500) throw ApiException.badRequest("invalid_score", "Score out of range");
        Integer previous = jdbc.sql("SELECT best FROM rush_scores WHERE user_id = ? AND mode = ?")
                .params(userId, mode).query(Integer.class).optional().orElse(null);
        if (previous == null || score > previous) {
            jdbc.sql("""
                    INSERT INTO rush_scores (user_id, mode, best) VALUES (?, ?, ?)
                    ON CONFLICT (user_id, mode) DO UPDATE SET best = EXCLUDED.best, updated_at = now()
                    """).params(userId, mode, score).update();
            return new RushBest(mode, score, true);
        }
        return new RushBest(mode, previous, false);
    }

    public Map<String, Integer> rushBests(UUID userId) {
        Map<String, Integer> out = new LinkedHashMap<>();
        for (String m : RUSH_MODES) out.put(m, 0);
        record R(String mode, int best) {}
        jdbc.sql("SELECT mode, best FROM rush_scores WHERE user_id = ?").param(userId)
                .query(R.class).list().forEach(r -> out.put(r.mode(), r.best()));
        return out;
    }

    private static long seed(String s) {
        try {
            byte[] h = MessageDigest.getInstance("SHA-256").digest(s.getBytes(StandardCharsets.UTF_8));
            long v = 0;
            for (int i = 0; i < 8; i++) v = (v << 8) | (h[i] & 0xff);
            return v;
        } catch (Exception e) {
            return s.hashCode();
        }
    }
}
