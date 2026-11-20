package com.evilchess.server.config;

import java.time.Duration;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

/** Everything under {@code evilchess.*} in application.properties. */
@ConfigurationProperties(prefix = "evilchess")
public record AppProperties(
        String version,
        Jwt jwt,
        Social social,
        Imports imports,
        RateLimit rateLimit) {

    public record Jwt(String secret, Duration accessTtl, Duration refreshTtl) {}

    /** OAuth client IDs. Empty lists switch that sign-in method off. */
    public record Social(List<String> googleClientIds, List<String> appleClientIds) {
        public Social {
            googleClientIds = googleClientIds == null ? List.of() : googleClientIds;
            appleClientIds = appleClientIds == null ? List.of() : appleClientIds;
        }
    }

    public record Imports(String lichessBaseUrl, String chesscomBaseUrl, String userAgent, int maxGames) {}

    /** Requests per minute per client IP. */
    public record RateLimit(int authPerMinute, int apiPerMinute) {}
}
