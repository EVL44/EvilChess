package com.evilchess.server.auth;

import com.evilchess.server.common.ApiException;
import com.evilchess.server.users.UserRepository;
import com.evilchess.server.users.UserRepository.User;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    public record RegisterRequest(
            @NotBlank @Size(max = 320) String email,
            @NotBlank @Size(min = 8, max = 128) String password,
            @Size(max = 40) String displayName) {}

    public record LoginRequest(@NotBlank String email, @NotBlank String password) {}

    public record RefreshRequest(@NotBlank String refreshToken) {}

    public record SocialRequest(@NotBlank String idToken, @Size(max = 40) String displayName) {}

    /** Deliberately simple: something@something.tld, no spaces. */
    private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

    private final UserRepository users;
    private final TokenService tokens;
    private final PasswordEncoder passwords;
    private final SocialTokenVerifier social;

    public AuthController(UserRepository users, TokenService tokens, PasswordEncoder passwords,
            SocialTokenVerifier social) {
        this.users = users;
        this.tokens = tokens;
        this.passwords = passwords;
        this.social = social;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create an account with email and password")
    public TokenService.Tokens register(@Valid @RequestBody RegisterRequest req) {
        String email = req.email().trim().toLowerCase(Locale.ROOT);
        if (!EMAIL.matcher(email).matches()) {
            throw ApiException.badRequest("invalid_email", "email is not a valid address");
        }
        if (users.byEmail(email).isPresent()) {
            throw ApiException.conflict("email_taken", "An account with this email already exists");
        }
        String name = req.displayName() == null || req.displayName().isBlank()
                ? email.substring(0, email.indexOf('@'))
                : req.displayName().trim();
        User user = users.create(email, passwords.encode(req.password()), truncate(name));
        return tokens.issue(user.id());
    }

    @PostMapping("/login")
    @Operation(summary = "Sign in with email and password")
    public TokenService.Tokens login(@Valid @RequestBody LoginRequest req) {
        User user = users.byEmail(req.email().trim().toLowerCase(Locale.ROOT))
                .filter(u -> u.passwordHash() != null && passwords.matches(req.password(), u.passwordHash()))
                .orElseThrow(() -> ApiException.unauthorized("invalid_credentials", "Wrong email or password"));
        return tokens.issue(user.id());
    }

    @PostMapping("/refresh")
    @Operation(summary = "Exchange a refresh token for a new token pair")
    public TokenService.Tokens refresh(@Valid @RequestBody RefreshRequest req) {
        return tokens.refresh(req.refreshToken());
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "End this session")
    public void logout(@Valid @RequestBody RefreshRequest req) {
        tokens.revoke(req.refreshToken());
    }

    @GetMapping("/providers")
    @Operation(summary = "Which social sign-in methods this server accepts")
    public Map<String, Boolean> providers() {
        return Map.of("google", social.enabled("google"), "apple", social.enabled("apple"));
    }

    @PostMapping("/{provider:google|apple}")
    @Operation(summary = "Sign in with a Google or Apple ID token")
    public TokenService.Tokens socialLogin(@PathVariable String provider, @Valid @RequestBody SocialRequest req) {
        SocialTokenVerifier.Identity id = social.verify(provider, req.idToken());
        // Only link to an existing email account when the provider verified it.
        String email = id.email() != null && id.emailVerified() ? id.email().toLowerCase(Locale.ROOT) : null;
        User user = users.bySocial(provider, id.subject()).orElseGet(() -> {
            String name = firstNonBlank(req.displayName(), id.name(),
                    email == null ? "player" : email.substring(0, email.indexOf('@')));
            return users.createOrLinkSocial(provider, id.subject(), email, truncate(name));
        });
        return tokens.issue(user.id());
    }

    private static String firstNonBlank(String... values) {
        for (String v : values) {
            if (v != null && !v.isBlank()) return v.trim();
        }
        return "player";
    }

    private static String truncate(String name) {
        return name.length() > 40 ? name.substring(0, 40) : name;
    }
}
