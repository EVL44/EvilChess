# ADR 0002 — Spring Boot 4.1 instead of Spring Boot 3

- Status: proposed (2026-11-14) — needs product-owner confirmation

## Context
The brief says "Spring Boot 3 (Java 21)". As of November 2026, Spring Initializr only
offers Boot 4.0.x and 4.1.x; open-source support for the last 3.x line (3.5) has ended.

## Decision
Use **Spring Boot 4.1.2 on Java 21** (Gradle toolchain; Java 21 is downloaded automatically
via the foojay resolver if it isn't installed). Everything in the brief (Spring Security,
WebSocket/STOMP, Flyway, Testcontainers, springdoc OpenAPI) is supported on Boot 4.

## Consequences
- Starting a new project on an unsupported 3.x line would mean a migration within months.
- Boot 4 uses Jakarta EE 11 and Jackson 3; libraries must be Boot-4 compatible
  (e.g. springdoc-openapi 3.x).
