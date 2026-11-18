package com.evilchess.server;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.request;

import com.evilchess.server.config.RateLimitFilter;
import com.jayway.jsonpath.JsonPath;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

/**
 * Base for tests that run the whole server against real Postgres and Redis
 * (Testcontainers). All subclasses share one Spring context and one set of
 * containers.
 */
@Tag("integration")
@SpringBootTest
@AutoConfigureMockMvc
@Import(TestcontainersConfiguration.class)
public abstract class IntegrationTest {

    @Autowired
    protected MockMvc mvc;

    @Autowired
    protected JdbcClient jdbc;

    @Autowired
    private RateLimitFilter rateLimit;

    @BeforeEach
    void resetRateLimits() {
        rateLimit.reset();
    }

    /** A response: status and raw JSON body. */
    public record Res(int status, String body) {
        public <T> T json(String path) {
            return JsonPath.read(body, path);
        }
    }

    protected Res call(HttpMethod method, String path, String json, String token) throws Exception {
        MockHttpServletRequestBuilder req = request(method, path);
        if (json != null) req.contentType(MediaType.APPLICATION_JSON).content(json);
        if (token != null) req.header("Authorization", "Bearer " + token);
        MvcResult r = mvc.perform(req).andReturn();
        return new Res(r.getResponse().getStatus(), r.getResponse().getContentAsString());
    }

    protected Res post(String path, String json) throws Exception {
        return call(HttpMethod.POST, path, json, null);
    }

    protected Res post(String path, String json, String token) throws Exception {
        return call(HttpMethod.POST, path, json, token);
    }

    protected Res get(String path, String token) throws Exception {
        return call(HttpMethod.GET, path, null, token);
    }

    /** Registers a fresh user and returns its access token. */
    protected String newUser() throws Exception {
        return newUserTokens().json("$.accessToken");
    }

    protected Res newUserTokens() throws Exception {
        String email = "u" + UUID.randomUUID().toString().substring(0, 8) + "@example.com";
        Res r = post("/api/v1/auth/register",
                "{\"email\":\"" + email + "\",\"password\":\"correct horse\"}");
        if (r.status() != 201) throw new AssertionError("register failed: " + r);
        return r;
    }
}
