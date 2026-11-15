# evilchess

Free chess analysis, training and play. Everything that other sites charge for — full game
review, personal reports, unlimited puzzles — is free here. An optional **Pro** tier adds
extras on top.

| Folder | What | Licence |
|---|---|---|
| [`app/`](app) | Flutter client (Android, iOS, web, Windows, macOS, Linux) | GPL-3.0-or-later |
| [`server/`](server) | Spring Boot 4.1 / Java 21 backend | Proprietary |
| [`infra/`](infra) | Docker Compose: Postgres 17, Redis 7, server | — |
| [`docs/`](docs) | Architecture decision records | — |

Why the split licence: see [docs/adr/0001-licensing.md](docs/adr/0001-licensing.md).

## Status

| Phase | Scope | State |
|---|---|---|
| 0 | Monorepo, CI, design system, EN/FR/AR + RTL, app shell | ✅ done |
| 1 | Offline analysis MVP (PGN + Lichess/Chess.com import, Stockfish, review screen) | ✅ done |
| 2 | Reports + puzzles from my mistakes | next |

## Prerequisites

| Tool | Version | Needed for |
|---|---|---|
| Flutter | 3.50 stable (Dart 3.14) | the app |
| JDK | 21 | server, Android builds |
| Docker Desktop | any recent | Postgres/Redis, server integration tests |
| Android SDK | API 36 | Android builds |
| Visual Studio 2022 + "Desktop development with C++" | — | Windows desktop builds |
| Xcode (macOS only) | latest | iOS / macOS builds |

### Windows notes
- **Developer Mode** must be on (Settings → System → For developers). Flutter plugins need
  symlinks.
- The Android SDK path must not contain spaces. If yours is under a user folder with spaces,
  create a junction and point Flutter at it:
  ```
  mklink /J C:\Android\Sdk "%LOCALAPPDATA%\Android\Sdk"
  flutter config --android-sdk C:\Android\Sdk
  ```
- If Gradle fails with `Unable to establish loopback connection`, your `%TEMP%` path is too
  long or unusual for Java's Unix-domain sockets. Use a short temp dir for that shell:
  `set TEMP=C:\tmp` and `set TMP=C:\tmp`.

## Run the app

```
cd app
flutter pub get
flutter run -d chrome --wasm # web (WebAssembly only — see below)
flutter run -d windows       # Windows desktop
flutter run                  # connected Android/iOS device or emulator
```

**Web is WebAssembly-only.** The chess core (dartchess) uses 64-bit integer bitboards that
can't compile to plain JavaScript. Always pass `--wasm` (`flutter build web --release --wasm`).
Flutter still emits a JavaScript fallback for browsers without WasmGC; that fallback only shows
an "update your browser" page (`lib/bootstrap/bootstrap_js_fallback.dart`). Supported: Chrome/Edge
119+, Firefox 120+, Safari 18.2+.

Localizations are generated from `app/lib/l10n/*.arb` on `pub get` / build
(`flutter gen-l10n` to regenerate manually).

### The chess engine (Stockfish 19, GPL-3.0)

| Platform | Engine | Setup |
|---|---|---|
| Android, iOS | compiled into the app (`multistockfish`) | none |
| Web | WebAssembly build in `app/web/engine/` (stockfish.js lite, single-threaded) | none |
| Windows, Linux | official binary, bundled next to the executable | run `bash tool/fetch_stockfish.sh` once before building |
| macOS | official binary | not bundled yet: `brew install stockfish` (found on PATH) |

All of them sit behind one interface (`lib/core/engine/`): a `UciTransport` per platform and a
shared `UciEngine`. Analysis results are cached per position in the local database.

### Code generation

The Drift database code (`lib/core/db/app_database.g.dart`) is committed. After changing
tables run `dart run build_runner build --delete-conflicting-outputs`.
The opening book (`assets/openings/book.tsv`) is built from Lichess's CC0 tables with
`dart run tool/build_opening_book.dart <folder with a.tsv … e.tsv>`.

### App checks (same as CI)

```
cd app
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

## Run the backend

```
docker compose -f infra/docker-compose.yml up -d --build   # db + redis + server on :8080
```

or run only the dependencies and start the server from your IDE / Gradle:

```
docker compose -f infra/docker-compose.yml up -d db redis
cd server
./gradlew bootRun
```

Useful URLs: `http://localhost:8080/api/v1/meta`, `http://localhost:8080/actuator/health`,
OpenAPI UI at `http://localhost:8080/api/docs/ui`.

### Server tests

```
cd server
./gradlew unitTest   # fast, no Docker
./gradlew test       # everything, including Testcontainers integration tests (needs Docker)
```

## CI

GitHub Actions (`.github/workflows`):
- **app.yml** — format check, analyzer (infos are fatal), tests; then builds web (Wasm), Android
  (debug APK), Windows, Linux, iOS (simulator) and macOS.
- **server.yml** — all Gradle tests including Testcontainers.

## Repository layout (app)

```
app/lib/
  app.dart, main.dart
  core/         theme, router, settings, shared widgets, db (Drift), engine (UCI + per-platform transports)
  features/     one folder per feature:
                games (PGN + Lichess/Chess.com import, library), analysis (win%, accuracy,
                classification, opening book, runner), review (review screen),
                home, analyze, puzzles, play, profile, settings, shell, design_system
  l10n/         ARB files (en, fr, ar) + generated localizations
```

Arabic mirrors the whole layout, **except** the chessboard, coordinates and algebraic
notation — wrap those in `ForceLtr`.

## Third-party credits
- Board & rules: [chessground](https://pub.dev/packages/chessground) and
  [dartchess](https://pub.dev/packages/dartchess) by lichess.org (GPL-3.0).
- Pieces: cburnett set (via chessground), CC BY-SA 3.0, by Colin M.L. Burnett.
- Fonts: Nunito and Cairo, SIL Open Font License 1.1.
- Engine: [Stockfish](https://stockfishchess.org) (GPL-3.0); web build from
  [stockfish.js](https://github.com/nmrugg/stockfish.js); mobile via
  [multistockfish](https://pub.dev/packages/multistockfish).
- Opening names: [lichess-org/chess-openings](https://github.com/lichess-org/chess-openings) (CC0).
