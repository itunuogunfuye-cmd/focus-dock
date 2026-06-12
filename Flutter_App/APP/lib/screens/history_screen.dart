import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../utils/theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORY'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: appState.sessionLogs.isEmpty
                  ? null
                  : () => context.read<AppState>().clearHistory(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.25)),
                foregroundColor: AppTheme.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Clear History'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: appState.sessionLogs.isEmpty
                  ? const Center(
                      child: Text(
                        'No activity yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: appState.sessionLogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                left: BorderSide(
                                  color: _getLogColor(appState.sessionLogs[index]),
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Text(
                              appState.sessionLogs[index],
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Courier',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('START')) return Colors.green;
    if (log.contains('AWAY')) return Colors.orange;
    if (log.contains('COMPLETE')) return Colors.blue;
    if (log.contains('OFF')) return Colors.red;
    return Colors.grey;
  }
}
