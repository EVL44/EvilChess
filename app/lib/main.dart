// The chess core (dartchess/chessground) uses 64-bit integer bitboards, which
// compile to native code and to WebAssembly but not to plain JavaScript.
// `flutter build web --wasm` always also builds a JavaScript fallback for
// browsers without WasmGC; that fallback (the only target where `dart:html`
// exists) gets a small "please update your browser" page instead.
import 'bootstrap/bootstrap.dart'
    if (dart.library.html) 'bootstrap/bootstrap_js_fallback.dart';

Future<void> main() => bootstrap();
