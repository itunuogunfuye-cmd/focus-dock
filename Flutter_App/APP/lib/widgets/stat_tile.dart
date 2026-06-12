import 'package:flutter/material.dart';

import '../utils/theme.dart';

class StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const StatTile({
    super.key,
    required this.title,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppTheme.accent, size: 28),
            const SizedBox(width: 14),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
