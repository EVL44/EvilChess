package com.evilchess.server.sync;

import com.evilchess.server.users.MeController;
import io.swagger.v3.oas.annotations.Operation;
import java.util.List;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/sync")
public class SyncController {

    /** Push local changes and pull everything stored after [since]. */
    public record SyncRequest(long since, List<SyncService.Change> changes) {}

    private final SyncService sync;

    public SyncController(SyncService sync) {
        this.sync = sync;
    }

    @PostMapping
    @Operation(summary = "Push local changes and pull remote changes after a cursor")
    public SyncService.Result sync(@AuthenticationPrincipal Jwt jwt, @RequestBody SyncRequest req) {
        return sync.sync(MeController.userId(jwt), req.since(),
                req.changes() == null ? List.of() : req.changes());
    }
}
