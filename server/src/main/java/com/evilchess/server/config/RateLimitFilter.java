package com.evilchess.server.config;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Per-IP token buckets: a tight one for sign-in/sign-up (slows password
 * guessing) and a looser one for the rest of the API. In memory, so limits
 * are per server instance; move to Redis when running more than one.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RateLimitFilter extends OncePerRequestFilter {

    private final int authPerMinute;
    private final int apiPerMinute;
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    public RateLimitFilter(AppProperties props) {
        this.authPerMinute = props.rateLimit().authPerMinute();
        this.apiPerMinute = props.rateLimit().apiPerMinute();
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith("/api/");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws ServletException, IOException {
        boolean auth = req.getRequestURI().startsWith("/api/v1/auth/")
                && !req.getRequestURI().endsWith("/providers");
        String key = (auth ? "auth:" : "api:") + clientIp(req);
        int perMinute = auth ? authPerMinute : apiPerMinute;
        Bucket bucket = buckets.computeIfAbsent(key, k -> Bucket.builder()
                .addLimit(Bandwidth.builder().capacity(perMinute)
                        .refillGreedy(perMinute, Duration.ofMinutes(1)).build())
                .build());
        if (bucket.tryConsume(1)) {
            chain.doFilter(req, res);
        } else {
            res.setStatus(429);
            res.setHeader("Retry-After", "60");
            res.setContentType("application/json");
            res.getWriter().write("{\"code\":\"rate_limited\",\"message\":\"Too many requests, slow down\"}");
        }
    }

    private static String clientIp(HttpServletRequest req) {
        // Behind a proxy, configure server.forward-headers-strategy so this is the real client.
        return req.getRemoteAddr();
    }

    /** For tests. */
    public void reset() {
        buckets.clear();
    }
}
