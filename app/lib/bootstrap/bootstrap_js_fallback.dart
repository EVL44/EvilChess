import 'package:material_ui/material_ui.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/evil_logo.dart';

/// Shown only by the JavaScript fallback build, i.e. in browsers that cannot
/// run WebAssembly with garbage collection (WasmGC).
Future<void> bootstrap() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'evilchess',
      theme: AppTheme.light(),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EvilLogo(size: 96),
                SizedBox(height: 24),
                _Message(
                  'Your browser is too old for evilchess. Please update to the '
                  'latest Chrome, Edge, Firefox or Safari.',
                ),
                _Message(
                  'Votre navigateur est trop ancien pour evilchess. Mettez à '
                  'jour Chrome, Edge, Firefox ou Safari.',
                ),
                _Message(
                  'متصفحك قديم جدًا لتشغيل evilchess. يرجى تحديث Chrome أو Edge '
                  'أو Firefox أو Safari.',
                  rtl: true,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.rtl = false});

  final String text;
  final bool rtl;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      text,
      textAlign: TextAlign.center,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      style: Theme.of(context).textTheme.titleMedium,
    ),
  );
}
