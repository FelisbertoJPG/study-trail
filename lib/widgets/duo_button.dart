import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Botão "estilo Duolingo": cantos bem arredondados e uma borda inferior mais
/// escura que dá sensação de profundidade.
class DuoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color? textColor;

  const DuoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppTheme.primary,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final base = enabled ? color : AppTheme.locked;
    final shadow = enabled
        ? Color.lerp(color, Colors.black, 0.22)!
        : AppTheme.lockedDark;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(16),
              border: Border(bottom: BorderSide(color: shadow, width: 4)),
            ),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
