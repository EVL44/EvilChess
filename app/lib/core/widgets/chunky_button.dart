import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// The signature evilchess button: rounded, bold, with a solid "3D" ledge
/// underneath that squashes when pressed.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.foregroundColor,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Face colour. Defaults to the theme's primary colour.
  final Color? color;
  final Color? foregroundColor;

  /// Stretch to the available width.
  final bool expand;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  static const _ledge = 5.0;
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;
    final face = enabled
        ? (widget.color ?? scheme.primary)
        : scheme.onSurface.withValues(alpha: 0.18);
    final fg =
        widget.foregroundColor ??
        (ThemeData.estimateBrightnessForColor(face) == Brightness.dark
            ? Colors.white
            : const Color(0xFF1E1530));
    final ledge = Color.lerp(face, Colors.black, 0.32)!;
    final offset = _pressed ? _ledge - 1 : 0.0;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: fg, size: 22),
          const SizedBox(width: EcSpace.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: fg, fontSize: 17),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: widget.onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
          child: Container(
            padding: EdgeInsets.only(top: offset),
            decoration: BoxDecoration(
              color: ledge,
              borderRadius: BorderRadius.circular(EcRadii.md),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              margin: EdgeInsets.only(bottom: _ledge - offset),
              padding: const EdgeInsets.symmetric(
                horizontal: EcSpace.lg,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: face,
                borderRadius: BorderRadius.circular(EcRadii.md),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
