package com.evilchess.server.auth;

import com.evilchess.server.common.ApiException;
import com.evilchess.server.config.AppProperties;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.UUID;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Issues short-lived JWT access tokens and long-lived opaque refresh tokens.
 *
 * <p>Refresh tokens are random, stored only as SHA-256 hashes, and rotated on
 * every use. Presenting a token that was already rotated means it leaked:
 * every session of that user is revoked.
 */
@Service
public class TokenService {

    public static final String ISSUER = "evilchess";

    public record Tokens(String accessToken, String refreshToken, long expiresIn) {}

    private final JwtEncoder encoder;
    private final JdbcClient jdbc;
    private final AppProperties.Jwt config;
    private final SecureRandom random = new SecureRandom();

    public TokenService(JwtEncoder encoder, JdbcClient jdbc, AppProperties props) {
        this.encoder = encoder;
        this.jdbc = jdbc;
        this.config = props.jwt();
    }

    @Transactional
    public Tokens issue(UUID userId) {
        Instant now = Instant.now();
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer(ISSUER)
                .subject(userId.toString())
                .issuedAt(now)
                .expiresAt(now.plus(config.accessTtl()))
                .build();
        String access = encoder.encode(JwtEncoderParameters.from(
                JwsHeader.with(MacAlgorithm.HS256).build(), claims)).getTokenValue();

        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        String refresh = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        jdbc.sql("INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at) VALUES (?, ?, ?, ?)")
                .params(UUID.randomUUID(), userId, hash(refresh),
                        java.sql.Timestamp.from(now.plus(config.refreshTtl())))
                .update();
        return new Tokens(access, refresh, config.accessTtl().toSeconds());
    }

    /** Exchanges a refresh token for a new pair; the old one stops working. */
    @Transactional(noRollbackFor = ApiException.class)
    public Tokens refresh(String refreshToken) {
        record Row(UUID id, UUID userId, Instant expiresAt, Instant revokedAt) {}
        Row row = jdbc.sql("""
                SELECT id, user_id, expires_at, revoked_at FROM refresh_tokens
                WHERE token_hash = ? FOR UPDATE
                """).param(hash(refreshToken)).query(Row.class).optional()
                .orElseThrow(() -> ApiException.unauthorized("invalid_refresh_token", "Unknown refresh token"));
        if (row.revokedAt() != null) {
            // Reuse of a rotated token: assume theft, end every session.
            revokeAll(row.userId());
            throw ApiException.unauthorized("refresh_token_reused", "Session ended, please sign in again");
        }
        if (row.expiresAt().isBefore(Instant.now())) {
            throw ApiException.unauthorized("refresh_token_expired", "Session expired, please sign in again");
        }
        jdbc.sql("UPDATE refresh_tokens SET revoked_at = now() WHERE id = ?").param(row.id()).update();
        return issue(row.userId());
    }

    public void revoke(String refreshToken) {
        jdbc.sql("UPDATE refresh_tokens SET revoked_at = now() WHERE token_hash = ? AND revoked_at IS NULL")
                .param(hash(refreshToken)).update();
    }

    public void revokeAll(UUID userId) {
        jdbc.sql("UPDATE refresh_tokens SET revoked_at = now() WHERE user_id = ? AND revoked_at IS NULL")
                .param(userId).update();
    }

    static String hash(String token) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
