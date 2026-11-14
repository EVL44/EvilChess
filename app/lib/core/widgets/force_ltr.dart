import 'package:flutter/widgets.dart';

/// Forces left-to-right layout for its subtree.
///
/// The app mirrors for Arabic, but a chessboard (files a→h), coordinates and
/// algebraic notation (`Nf3`, `O-O`) must never mirror. Wrap those widgets in
/// [ForceLtr].
class ForceLtr extends StatelessWidget {
  const ForceLtr({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Directionality(textDirection: TextDirection.ltr, child: child);
}
