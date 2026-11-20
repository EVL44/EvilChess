package com.evilchess.server.users;

import java.util.Optional;
import java.util.UUID;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

@Repository
public class UserRepository {

    /** A user row. Password hash is never sent to clients. */
    public record User(
            UUID id,
            String email,
            String passwordHash,
            String displayName,
            String googleSub,
            String appleSub,
            double puzzleRating,
            double puzzleRd,
            double puzzleVol,
            int puzzlesPlayed) {}

    private static final String COLUMNS = """
            id, email, password_hash, display_name, google_sub, apple_sub,
            puzzle_rating, puzzle_rd, puzzle_vol, puzzles_played
            """;

    private final JdbcClient jdbc;

    public UserRepository(JdbcClient jdbc) {
        this.jdbc = jdbc;
    }

    public Optional<User> byId(UUID id) {
        return jdbc.sql("SELECT " + COLUMNS + " FROM users WHERE id = ?")
                .param(id).query(User.class).optional();
    }

    public Optional<User> byEmail(String email) {
        return jdbc.sql("SELECT " + COLUMNS + " FROM users WHERE email = ?")
                .param(email).query(User.class).optional();
    }

    public Optional<User> bySocial(String provider, String subject) {
        String column = provider.equals("google") ? "google_sub" : "apple_sub";
        return jdbc.sql("SELECT " + COLUMNS + " FROM users WHERE " + column + " = ?")
                .param(subject).query(User.class).optional();
    }

    public User create(String email, String passwordHash, String displayName) {
        UUID id = UUID.randomUUID();
        jdbc.sql("INSERT INTO users (id, email, password_hash, display_name) VALUES (?, ?, ?, ?)")
                .params(id, email, passwordHash, displayName).update();
        return byId(id).orElseThrow();
    }

    /** Creates a user from a Google/Apple sign-in, or links the subject to an existing email. */
    public User createOrLinkSocial(String provider, String subject, String email, String displayName) {
        String column = provider.equals("google") ? "google_sub" : "apple_sub";
        if (email != null) {
            Optional<User> existing = byEmail(email);
            if (existing.isPresent()) {
                jdbc.sql("UPDATE users SET " + column + " = ? WHERE id = ?")
                        .params(subject, existing.get().id()).update();
                return byId(existing.get().id()).orElseThrow();
            }
        }
        UUID id = UUID.randomUUID();
        jdbc.sql("INSERT INTO users (id, email, display_name, " + column + ") VALUES (?, ?, ?, ?)")
                .params(id, email, displayName, subject).update();
        return byId(id).orElseThrow();
    }

    public void setDisplayName(UUID id, String displayName) {
        jdbc.sql("UPDATE users SET display_name = ? WHERE id = ?").params(displayName, id).update();
    }

    public void setPuzzleRating(UUID id, double rating, double rd, double vol) {
        jdbc.sql("""
                UPDATE users SET puzzle_rating = ?, puzzle_rd = ?, puzzle_vol = ?,
                       puzzles_played = puzzles_played + 1
                WHERE id = ?
                """).params(rating, rd, vol, id).update();
    }
}
