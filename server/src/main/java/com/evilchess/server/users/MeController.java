package com.evilchess.server.users;

import com.evilchess.server.common.ApiException;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me")
public class MeController {

    public record Profile(
            UUID id,
            String email,
            String displayName,
            int puzzleRating,
            int puzzleRd,
            boolean provisional,
            int puzzlesPlayed,
            boolean hasPassword,
            boolean google,
            boolean apple) {}

    public record UpdateProfile(@NotBlank @Size(max = 40) String displayName) {}

    private final UserRepository users;

    public MeController(UserRepository users) {
        this.users = users;
    }

    /** The signed-in user's id, from the access token. */
    public static UUID userId(Jwt jwt) {
        return UUID.fromString(jwt.getSubject());
    }

    @GetMapping
    @Operation(summary = "The signed-in user's profile and puzzle rating")
    public Profile me(@AuthenticationPrincipal Jwt jwt) {
        return profile(userId(jwt));
    }

    @PatchMapping
    @Operation(summary = "Change the display name")
    public Profile update(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody UpdateProfile req) {
        users.setDisplayName(userId(jwt), req.displayName().trim());
        return profile(userId(jwt));
    }

    private Profile profile(UUID id) {
        UserRepository.User u = users.byId(id)
                .orElseThrow(() -> ApiException.unauthorized("unknown_user", "Account no longer exists"));
        return new Profile(u.id(), u.email(), u.displayName(),
                (int) Math.round(u.puzzleRating()), (int) Math.round(u.puzzleRd()),
                u.puzzleRd() > 110, u.puzzlesPlayed(),
                u.passwordHash() != null, u.googleSub() != null, u.appleSub() != null);
    }
}
