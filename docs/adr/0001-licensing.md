# ADR 0001 — Licensing: GPLv3 client, proprietary server

- Status: accepted (2026-11-14)

## Context
The best Flutter chess building blocks are GPLv3: `dartchess` (rules), `chessground`
(board), `multistockfish` (engine bridge) — all from lichess-org. Stockfish and Maia are
GPLv3 too. Linking or bundling any of them into a closed-source app is not allowed.

## Options considered
| Option | Why not |
|---|---|
| A. Closed client, engine only on the server | Free unlimited analysis would cost server CPU per game; no offline; we'd have to write our own rules engine and board. |
| B. Closed client, engine as a downloadable component | iOS forbids downloading executable code; GPL status of the combination is unclear; still no `dartchess`/`chessground`. |
| **C. Client under GPLv3, server proprietary** | Chosen. |

## Decision
- `/app` is licensed **GPL-3.0-or-later** (see `app/LICENSE`). Source must be published
  alongside every binary release.
- `/server` is proprietary (see `server/LICENSE`). It runs Stockfish only as a separate
  process over UCI, which the GPL allows; Stockfish is not AGPL, so offering it over the
  network does not trigger source disclosure.
- Everything that is sold (Pro entitlements, cloud deep analysis, AI coach) lives on the
  server, so an open client does not weaken the business model.

## Consequences / follow-ups
- Third-party assets in the app must be GPL-compatible. Piece sets: use sets such as
  cburnett (CC BY-SA 3.0 / GPL) with attribution in an in-app "Licences" screen.
- Data: Lichess puzzle DB, opening/ECO TSVs are CC0.
- App Store + GPL has a history of friction. Lichess Mobile and other Stockfish apps ship on
  iOS today, but get a lawyer to review before the first store release (Phase 7).
- Lichess / Chess.com API calls must send an identifying `User-Agent` and respect rate
  limits (Lichess: one request at a time, back off on HTTP 429).
