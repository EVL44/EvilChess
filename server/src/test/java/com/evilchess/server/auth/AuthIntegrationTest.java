package com.evilchess.server.auth;

import static org.assertj.core.api.Assertions.assertThat;

import com.evilchess.server.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;

class AuthIntegrationTest extends IntegrationTest {

    private static final String PASSWORD = "{\"email\":\"%s\",\"password\":\"%s\"}";

    @Test
    void registerLoginAndProfile() throws Exception {
        Res reg = post("/api/v1/auth/register",
                "{\"email\":\"  Alice@Example.com \",\"password\":\"hunter2hunter2\",\"displayName\":\"Alice\"}");
        assertThat(reg.status()).isEqualTo(201);
        assertThat((String) reg.json("$.accessToken")).isNotBlank();
        assertThat((String) reg.json("$.refreshToken")).isNotBlank();
        assertThat((Integer) reg.json("$.expiresIn")).isEqualTo(900);

        // Email is normalised; duplicates are refused.
        Res dup = post("/api/v1/auth/register", PASSWORD.formatted("alice@example.com", "whatever123"));
        assertThat(dup.status()).isEqualTo(409);
        assertThat((String) dup.json("$.code")).isEqualTo("email_taken");

        Res login = post("/api/v1/auth/login", PASSWORD.formatted("ALICE@example.com", "hunter2hunter2"));
        assertThat(login.status()).isEqualTo(200);

        Res me = get("/api/v1/me", login.json("$.accessToken"));
        assertThat(me.status()).isEqualTo(200);
        assertThat((String) me.json("$.email")).isEqualTo("alice@example.com");
        assertThat((String) me.json("$.displayName")).isEqualTo("Alice");
        assertThat((Integer) me.json("$.puzzleRating")).isEqualTo(1500);
        assertThat((Boolean) me.json("$.provisional")).isTrue();
        assertThat((Boolean) me.json("$.hasPassword")).isTrue();

        Res renamed = call(HttpMethod.PATCH, "/api/v1/me", "{\"displayName\":\"Evil Alice\"}",
                login.json("$.accessToken"));
        assertThat((String) renamed.json("$.displayName")).isEqualTo("Evil Alice");
    }

    @Test
    void badCredentialsAndValidation() throws Exception {
        newUser();
        assertThat(post("/api/v1/auth/login", PASSWORD.formatted("nobody@example.com", "whatever123"))
                .status()).isEqualTo(401);
        Res shortPw = post("/api/v1/auth/register", PASSWORD.formatted("bob@example.com", "short"));
        assertThat(shortPw.status()).isEqualTo(400);
        assertThat((String) shortPw.json("$.message")).contains("password");
        assertThat(post("/api/v1/auth/register", PASSWORD.formatted("not-an-email", "longenough1"))
                .status()).isEqualTo(400);
    }

    @Test
    void protectedEndpointsNeedAValidToken() throws Exception {
        assertThat(get("/api/v1/me", null).status()).isEqualTo(401);
        assertThat(get("/api/v1/me", "garbage").status()).isEqualTo(401);
        // Public endpoints stay open.
        assertThat(get("/api/v1/meta", null).status()).isEqualTo(200);
        assertThat(get("/api/v1/auth/providers", null).status()).isEqualTo(200);
    }

    @Test
    void refreshRotatesAndDetectsReuse() throws Exception {
        Res first = newUserTokens();
        String r1 = first.json("$.refreshToken");

        Res second = post("/api/v1/auth/refresh", "{\"refreshToken\":\"" + r1 + "\"}");
        assertThat(second.status()).isEqualTo(200);
        String r2 = second.json("$.refreshToken");
        assertThat(r2).isNotEqualTo(r1);
        assertThat(get("/api/v1/me", second.json("$.accessToken")).status()).isEqualTo(200);

        // Replaying the rotated token ends every session of the user…
        Res replay = post("/api/v1/auth/refresh", "{\"refreshToken\":\"" + r1 + "\"}");
        assertThat(replay.status()).isEqualTo(401);
        assertThat((String) replay.json("$.code")).isEqualTo("refresh_token_reused");
        // …including the legitimate newer one.
        assertThat(post("/api/v1/auth/refresh", "{\"refreshToken\":\"" + r2 + "\"}").status())
                .isEqualTo(401);
    }

    @Test
    void logoutRevokesTheRefreshToken() throws Exception {
        Res t = newUserTokens();
        String refresh = t.json("$.refreshToken");
        assertThat(post("/api/v1/auth/logout", "{\"refreshToken\":\"" + refresh + "\"}").status())
                .isEqualTo(204);
        assertThat(post("/api/v1/auth/refresh", "{\"refreshToken\":\"" + refresh + "\"}").status())
                .isEqualTo(401);
    }

    @Test
    void socialSignInIsOffUntilConfigured() throws Exception {
        Res providers = get("/api/v1/auth/providers", null);
        assertThat((Boolean) providers.json("$.google")).isFalse();
        assertThat((Boolean) providers.json("$.apple")).isFalse();
        Res google = post("/api/v1/auth/google", "{\"idToken\":\"x.y.z\"}");
        assertThat(google.status()).isEqualTo(501);
        assertThat((String) google.json("$.code")).isEqualTo("provider_disabled");
    }

    @Test
    void signInIsRateLimited() throws Exception {
        int limited = 0;
        for (int i = 0; i < 25; i++) {
            if (post("/api/v1/auth/login", PASSWORD.formatted("x@example.com", "wrongwrong")).status() == 429) {
                limited++;
            }
        }
        assertThat(limited).isEqualTo(5);
    }
}
