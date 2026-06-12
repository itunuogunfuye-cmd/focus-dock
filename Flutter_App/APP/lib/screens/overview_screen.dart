import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../utils/theme.dart';
import '../widgets/stat_tile.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OVERVIEW'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatTile(
              title: 'Total Sessions',
              value: appState.totalSessions.toString(),
              icon: Icons.history,
            ),
            const SizedBox(height: 16),
            StatTile(
              title: 'Total Focus Time',
              value: appState.totalFocusTimeDisplay,
              icon: Icons.timer,
            ),
            const SizedBox(height: 16),
            StatTile(
              title: 'Completed',
              value: appState.completedSessions.toString(),
              icon: Icons.check_circle,
            ),
            const SizedBox(height: 16),
            StatTile(
              title: 'Interrupted',
              value: appState.interruptedSessions.toString(),
              icon: Icons.warning,
            ),
            const SizedBox(height: 28),
            const Text(
              'Weekly Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            StatTile(
              title: 'Focus Time This Week',
              value: appState.weeklyFocusTimeDisplay,
              icon: Icons.calendar_view_week,
            ),
            const SizedBox(height: 16),
            StatTile(
              title: 'Completed This Week',
              value: appState.weeklyCompletedSessions.toString(),
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 16),
            StatTile(
              title: 'Interrupted This Week',
              value: appState.weeklyInterruptedSessions.toString(),
              icon: Icons.report_problem,
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: () => context.read<AppState>().clearStatistics(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.35)),
                foregroundColor: AppTheme.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.restore, size: 18),
              label: const Text('Reset Statistics'),
            ),
          ],
        ),
      ),
    );
  }
}
