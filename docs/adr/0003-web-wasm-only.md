# ADR 0003 — Web build is WebAssembly-only

- Status: proposed (2026-11-14) — needs product-owner confirmation

## Context
`dartchess` (and therefore `chessground`) represents the board as 64-bit integer bitboards.
dart2js cannot represent those integers, so the app does not compile to JavaScript.
dart2wasm supports 64-bit integers, and the app builds and runs as WebAssembly.

`flutter build web --wasm` always also builds a JavaScript fallback for browsers without
WasmGC, and there is no flag to skip it.

## Decision
- Ship the web app as WebAssembly only.
- `lib/main.dart` uses a conditional import: the JS fallback build (the only target where
  `dart:html` exists) gets `bootstrap_js_fallback.dart`, a tiny trilingual "please update
  your browser" page that does not import the chess code.
- Minimum browsers: Chrome/Edge 119+, Firefox 120+, Safari 18.2+.

## Alternatives rejected
- Writing or forking a 32-bit chess core for JS: big effort, two rule engines to keep in sync.
- Dropping web: the brief requires it.

## Consequences
- Stockfish on web (Phase 1) also needs a modern browser, so the minimum barely moves.
- For the multi-threaded renderer and multi-threaded Stockfish WASM, the web host must send
  `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp`.
  Without them it still works, single-threaded.
