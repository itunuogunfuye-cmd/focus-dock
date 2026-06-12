import 'package:flutter/material.dart';

import '../utils/theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool enabled;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: enabled ? AppTheme.accentDim : AppTheme.accentDim.withOpacity(0.55),
      foregroundColor: Colors.black,
      shadowColor: AppTheme.accentDim.withOpacity(0.24),
      elevation: enabled ? 6 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );

    if (icon == null) {
      return ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: buttonStyle,
        child: Text(label),
      );
    }

    return ElevatedButton.icon(
      icon: icon!,
      label: Text(label),
      onPressed: enabled ? onPressed : null,
      style: buttonStyle,
    );
  }
}
