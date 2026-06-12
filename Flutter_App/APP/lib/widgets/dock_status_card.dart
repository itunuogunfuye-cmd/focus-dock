import 'package:flutter/material.dart';

import '../utils/theme.dart';

class DockStatusCard extends StatelessWidget {
  final bool isConnected;
  final bool isSystemOn;
  final String currentState;
  final String deviceName;

  const DockStatusCard({
    super.key,
    required this.isConnected,
    required this.isSystemOn,
    required this.currentState,
    this.deviceName = 'Unknown Device',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration.copyWith(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (isConnected)
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.14),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: isConnected ? AppTheme.accent : AppTheme.textSecondary,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  isConnected ? 'Bluetooth connected' : 'Bluetooth disconnected',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSystemOn ? AppTheme.accent.withOpacity(0.16) : Colors.white10,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  isSystemOn ? 'System ON' : 'System OFF',
                  style: TextStyle(
                    color: isSystemOn ? AppTheme.accent : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            deviceName,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              currentState,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
