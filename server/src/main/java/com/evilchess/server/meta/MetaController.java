package com.evilchess.server.meta;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Tiny public endpoint the app can call to check it is talking to a compatible server. */
@RestController
@RequestMapping("/api/v1/meta")
public class MetaController {

    /** Bumped whenever the REST contract changes in a breaking way. */
    public static final int API_VERSION = 1;

    private final String serverVersion;

    public MetaController(@Value("${evilchess.version:dev}") String serverVersion) {
        this.serverVersion = serverVersion;
    }

    @GetMapping
    @Operation(summary = "Server name, version and API version")
    public MetaResponse meta() {
        return new MetaResponse("evilchess", serverVersion, API_VERSION);
    }

    public record MetaResponse(String name, String version, int apiVersion) {}
}
