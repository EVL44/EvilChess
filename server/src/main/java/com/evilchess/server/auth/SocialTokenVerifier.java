package com.evilchess.server.auth;

import com.evilchess.server.common.ApiException;
import com.evilchess.server.config.AppProperties;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.http.HttpStatus;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Component;

/**
 * Verifies ID tokens from "Sign in with Google" and "Sign in with Apple":
 * signature (provider JWKS), issuer, expiry and audience (our client IDs).
 * A provider with no configured client ID is switched off.
 */
@Component
public class SocialTokenVerifier {

    /** Verified identity from a provider. */
    public record Identity(String subject, String email, boolean emailVerified, String name) {}

    private record Provider(String jwks, List<String> issuers, List<String> audiences) {}

    private final Map<String, Provider> providers;
    private final Map<String, JwtDecoder> decoders = new ConcurrentHashMap<>();

    public SocialTokenVerifier(AppProperties props) {
        this.providers = Map.of(
                "google", new Provider(
                        "https://www.googleapis.com/oauth2/v3/certs",
                        List.of("https://accounts.google.com", "accounts.google.com"),
                        props.social().googleClientIds()),
                "apple", new Provider(
                        "https://appleid.apple.com/auth/keys",
                        List.of("https://appleid.apple.com"),
                        props.social().appleClientIds()));
    }

    public boolean enabled(String provider) {
        Provider p = providers.get(provider);
        return p != null && !p.audiences().isEmpty();
    }

    public Identity verify(String provider, String idToken) {
        if (!enabled(provider)) {
            throw new ApiException(HttpStatus.NOT_IMPLEMENTED, "provider_disabled",
                    provider + " sign-in is not configured on this server");
        }
        try {
            Jwt jwt = decoders.computeIfAbsent(provider, this::decoder).decode(idToken);
            Object verified = jwt.getClaims().get("email_verified");
            boolean emailVerified = Boolean.TRUE.equals(verified) || "true".equals(verified);
            return new Identity(jwt.getSubject(), jwt.getClaimAsString("email"),
                    emailVerified, jwt.getClaimAsString("name"));
        } catch (JwtException e) {
            throw ApiException.unauthorized("invalid_id_token", "Could not verify the " + provider + " sign-in");
        }
    }

    private JwtDecoder decoder(String name) {
        Provider p = providers.get(name);
        NimbusJwtDecoder decoder = NimbusJwtDecoder.withJwkSetUri(p.jwks()).build();
        OAuth2TokenValidator<Jwt> issuer = jwt -> p.issuers().contains(String.valueOf(jwt.getIssuer()))
                ? OAuth2TokenValidatorResult.success()
                : OAuth2TokenValidatorResult.failure(new OAuth2Error("invalid_issuer"));
        OAuth2TokenValidator<Jwt> audience = jwt -> jwt.getAudience().stream().anyMatch(p.audiences()::contains)
                ? OAuth2TokenValidatorResult.success()
                : OAuth2TokenValidatorResult.failure(new OAuth2Error("invalid_audience"));
        decoder.setJwtValidator(new DelegatingOAuth2TokenValidator<>(
                JwtValidators.createDefault(), issuer, audience));
        return decoder;
    }
}
