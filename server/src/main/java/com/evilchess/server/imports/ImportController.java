package com.evilchess.server.imports;

import com.evilchess.server.users.MeController;
import io.swagger.v3.oas.annotations.Operation;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/imports")
public class ImportController {

    public record LinkRequest(String username) {}

    private final ImportService imports;

    public ImportController(ImportService imports) {
        this.imports = imports;
    }

    @GetMapping
    @Operation(summary = "Linked Lichess / Chess.com accounts and their import status")
    public List<ImportService.Account> accounts(@AuthenticationPrincipal Jwt jwt) {
        return imports.accounts(MeController.userId(jwt));
    }

    @PutMapping("/{provider}")
    @Operation(summary = "Link (or change) a Lichess / Chess.com username")
    public ImportService.Account link(@AuthenticationPrincipal Jwt jwt, @PathVariable String provider,
            @RequestBody LinkRequest req) {
        return imports.link(MeController.userId(jwt), provider, req.username());
    }

    @DeleteMapping("/{provider}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Unlink an account (imported games stay)")
    public void unlink(@AuthenticationPrincipal Jwt jwt, @PathVariable String provider) {
        imports.unlink(MeController.userId(jwt), provider);
    }

    @PostMapping("/{provider}/sync")
    @ResponseStatus(HttpStatus.ACCEPTED)
    @Operation(summary = "Start importing new games in the background")
    public ImportService.Account sync(@AuthenticationPrincipal Jwt jwt, @PathVariable String provider) {
        imports.start(MeController.userId(jwt), provider);
        return imports.account(MeController.userId(jwt), provider);
    }
}
