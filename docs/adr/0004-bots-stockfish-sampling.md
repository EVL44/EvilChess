# ADR 0004 — Bots: Stockfish with human-like sampling (Maia later)

- Status: accepted (2026-11-18) — Maia to be evaluated in a later phase

## Context
The brief asks for weak bots that feel human rather than "Stockfish with random blunders",
and suggests Maia networks. Maia is a set of Leela Chess Zero networks trained on human games
at fixed rating bands (1100–1900). Running it needs the lc0 engine (or an ONNX runtime) on
every platform, including WebAssembly for the web, plus about 1–2 MB of weights per rating
band. None of that exists as a maintained Flutter package today.

## Decision (Phase 3)
Every bot uses the Stockfish we already ship, with three strength knobs and a style:

| Knob | Effect |
|---|---|
| Search depth (1–16) | Low depth misses tactics the way people do |
| MultiPV + temperature | Picks among the engine's top moves; worse moves get exponentially less likely (`exp(Δcp / T)`) |
| Blunder chance | Occasionally a random legal move (only the weakest bots) |
| Opening book | Known opening moves for variety (stronger bots) |
| Style bonus | Small centipawn bonus for checks/captures/castling, never overriding a forced mate |

Ratings shown in the app are rough estimates ("~1400") and say so.

## Consequences
- Works offline on every platform today, with no extra download.
- Weak bots are still engine-flavoured: they don't make *typical human* mistakes the way
  Maia would.
- Follow-up: evaluate Maia via lc0 on desktop/mobile and onnxruntime-web on the web, for the
  1100–1900 bots only. Calibrate the shown ratings by self-play against Maia or by measuring
  results against real users once online play exists (Phase 5).
