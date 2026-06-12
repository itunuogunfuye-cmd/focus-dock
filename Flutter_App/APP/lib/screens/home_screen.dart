import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../widgets/dock_status_card.dart';
import '../widgets/circular_timer.dart';
import '../utils/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    String statusHeadline;
    String statusDetail;

    if (!appState.isBluetoothConnected) {
      statusHeadline = 'Waiting for Bluetooth dock connection.';
      statusDetail = 'Connect your dock and place the phone to begin focus.';
    } else {
      switch (appState.currentState) {
        case DockState.focus:
          statusHeadline = 'Focus mode active. Stay locked in.';
          statusDetail = 'Your dock is controlling the session. Keep the phone in place.';
          break;
        case DockState.away:
          statusHeadline = 'Phone removed. Session interrupted.';
          statusDetail = 'Return the phone to the dock to continue.';
          break;
        case DockState.complete:
          statusHeadline = 'Focus session complete. Great work.';
          statusDetail = 'Review your session history in the overview tab.';
          break;
        case DockState.idle:
          statusHeadline = 'Dock ready. Place phone to begin focus.';
          statusDetail = 'The physical system is active and waiting for your phone.';
          break;
        case DockState.off:
          statusHeadline = 'Focus system powered down.';
          statusDetail = 'Switch the dock on to start using focus mode.';
          break;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Focus Dock'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Control your session with a premium dock experience.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            DockStatusCard(
              isConnected: appState.isBluetoothConnected,
              isSystemOn: appState.isSystemOn,
              currentState: appState.stateDisplay,
              deviceName: appState.lastDeviceName.isNotEmpty
                  ? appState.lastDeviceName
                  : 'HC-05 Device',
            ),
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Text(
                    statusHeadline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CircularCountdownTimer(
                    remainingSeconds: appState.remainingSeconds,
                    totalSeconds: appState.sessionDuration.inSeconds,
                    label: appState.isSessionActive ? 'Session in progress' : 'Focus session',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusDetail,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
