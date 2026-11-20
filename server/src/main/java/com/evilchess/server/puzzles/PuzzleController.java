package com.evilchess.server.puzzles;

import com.evilchess.server.users.MeController;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.Map;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class PuzzleController {

    public record AttemptRequest(@NotNull Boolean win) {}

    public record RushRequest(@NotBlank String mode, @NotNull Integer score) {}

    private final PuzzleService puzzles;

    public PuzzleController(PuzzleService puzzles) {
        this.puzzles = puzzles;
    }

    @GetMapping("/puzzles/next")
    @Operation(summary = "A rated puzzle near your rating, optionally of one theme")
    public PuzzleService.Puzzle next(@AuthenticationPrincipal Jwt jwt,
            @RequestParam(required = false) String theme) {
        return puzzles.next(MeController.userId(jwt), theme);
    }

    @PostMapping("/puzzles/{id}/attempt")
    @Operation(summary = "Record a solve or fail; the first attempt is rated")
    public PuzzleService.AttemptResult attempt(@AuthenticationPrincipal Jwt jwt, @PathVariable String id,
            @Valid @RequestBody AttemptRequest req) {
        return puzzles.attempt(MeController.userId(jwt), id, req.win());
    }

    @GetMapping("/puzzles/daily")
    @Operation(summary = "Today's puzzle (UTC), the same for everyone")
    public PuzzleService.Puzzle daily() {
        return puzzles.daily();
    }

    @GetMapping("/puzzles/batch")
    @Operation(summary = "Puzzles from easy to hard, for Puzzle Rush and offline packs")
    public List<PuzzleService.Puzzle> batch(
            @RequestParam(defaultValue = "30") int count,
            @RequestParam(defaultValue = "600") int from,
            @RequestParam(defaultValue = "2400") int to,
            @RequestParam(required = false) String theme) {
        return puzzles.batch(count, from, to, theme);
    }

    @PostMapping("/rush")
    @Operation(summary = "Submit a Puzzle Rush score")
    public PuzzleService.RushBest rush(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody RushRequest req) {
        return puzzles.submitRush(MeController.userId(jwt), req.mode(), req.score());
    }

    @GetMapping("/rush")
    @Operation(summary = "Your best Puzzle Rush score per mode")
    public Map<String, Integer> rushBests(@AuthenticationPrincipal Jwt jwt) {
        return puzzles.rushBests(MeController.userId(jwt));
    }
}
