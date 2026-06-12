import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DockState { idle, focus, away, complete, off }

class AppState extends ChangeNotifier {
  static const _kSessionLogs = 'session_history_logs';
  static const _kTotalSessions = 'session_total_sessions';
  static const _kCompletedSessions = 'session_completed_sessions';
  static const _kInterruptedSessions = 'session_interrupted_sessions';
  static const _kTotalFocusSeconds = 'session_total_focus_seconds';
  static const _kWeeklyFocusSeconds = 'session_weekly_focus_seconds';
  static const _kWeeklyCompletedSessions = 'session_weekly_completed_sessions';
  static const _kWeeklyInterruptedSessions = 'session_weekly_interrupted_sessions';
  static const _kWeeklyStartDate = 'session_weekly_start_date';

  final List<String> _sessionLogs = [];
  SharedPreferences? _prefs;

  int _totalSessions = 0;
  int _completedSessions = 0;
  int _interruptedSessions = 0;
  int _totalFocusSeconds = 0;
  int _weeklyFocusSeconds = 0;
  int _weeklyCompletedSessions = 0;
  int _weeklyInterruptedSessions = 0;
  DateTime? _weeklyStartDate;

  bool isBluetoothConnected = false;
  bool isSystemOn = false;
  DockState currentState = DockState.off;
  bool isScanning = false;
  String lastDeviceName = '';
  Duration sessionDuration = const Duration(minutes: 25);
  int remainingSeconds = 0;
  Timer? _sessionTimer;

  List<String> get sessionLogs => List.unmodifiable(_sessionLogs);
  int get totalSessions => _totalSessions;
  int get completedSessions => _completedSessions;
  int get interruptedSessions => _interruptedSessions;
  int get totalFocusSeconds => _totalFocusSeconds;
  int get weeklyFocusSeconds => _weeklyFocusSeconds;
  int get weeklyCompletedSessions => _weeklyCompletedSessions;
  int get weeklyInterruptedSessions => _weeklyInterruptedSessions;

  Duration get totalFocusDuration => Duration(seconds: _totalFocusSeconds);
  Duration get weeklyFocusDuration => Duration(seconds: _weeklyFocusSeconds);

  String get totalFocusTimeDisplay => _formatDuration(totalFocusDuration);
  String get weeklyFocusTimeDisplay => _formatDuration(weeklyFocusDuration);

  bool get isSessionActive => _sessionTimer != null && remainingSeconds > 0;

  double get sessionProgress =>
      sessionDuration.inSeconds > 0 ? remainingSeconds / sessionDuration.inSeconds : 0.0;

  String get sessionTimeDisplay {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get stateDisplay {
    switch (currentState) {
      case DockState.idle:
        return 'Dock ready';
      case DockState.focus:
        return 'Focus mode active';
      case DockState.away:
        return 'Phone removed';
      case DockState.complete:
        return 'Session complete';
      case DockState.off:
        return 'System powered down';
    }
  }

  void setBluetoothConnected(bool connected) {
    if (isBluetoothConnected == connected) return;
    isBluetoothConnected = connected;
    notifyListeners();
  }

  void setSystemOn(bool value) {
    if (isSystemOn == value) return;
    isSystemOn = value;
    notifyListeners();
  }

  void setCurrentState(DockState state) {
    if (currentState == state) return;
    currentState = state;
    notifyListeners();
  }

  void setScanning(bool scanning) {
    if (isScanning == scanning) return;
    isScanning = scanning;
    notifyListeners();
  }

  void setLastDeviceName(String name) {
    if (lastDeviceName == name) return;
    lastDeviceName = name;
    notifyListeners();
  }

  Future<void> loadSavedState() async {
    final prefs = await _ensurePrefs();
    final savedLogs = prefs.getStringList(_kSessionLogs);
    _sessionLogs
      ..clear()
      ..addAll(savedLogs ?? []);
    _totalSessions = prefs.getInt(_kTotalSessions) ?? 0;
    _completedSessions = prefs.getInt(_kCompletedSessions) ?? 0;
    _interruptedSessions = prefs.getInt(_kInterruptedSessions) ?? 0;
    _totalFocusSeconds = prefs.getInt(_kTotalFocusSeconds) ?? 0;
    _weeklyFocusSeconds = prefs.getInt(_kWeeklyFocusSeconds) ?? 0;
    _weeklyCompletedSessions = prefs.getInt(_kWeeklyCompletedSessions) ?? 0;
    _weeklyInterruptedSessions = prefs.getInt(_kWeeklyInterruptedSessions) ?? 0;
    final weeklyStartText = prefs.getString(_kWeeklyStartDate);
    _weeklyStartDate = weeklyStartText != null ? DateTime.tryParse(weeklyStartText) : null;
    _resetWeeklyIfNeeded();
    notifyListeners();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _saveState() async {
    final prefs = await _ensurePrefs();
    await prefs.setStringList(_kSessionLogs, _sessionLogs);
    await prefs.setInt(_kTotalSessions, _totalSessions);
    await prefs.setInt(_kCompletedSessions, _completedSessions);
    await prefs.setInt(_kInterruptedSessions, _interruptedSessions);
    await prefs.setInt(_kTotalFocusSeconds, _totalFocusSeconds);
    await prefs.setInt(_kWeeklyFocusSeconds, _weeklyFocusSeconds);
    await prefs.setInt(_kWeeklyCompletedSessions, _weeklyCompletedSessions);
    await prefs.setInt(_kWeeklyInterruptedSessions, _weeklyInterruptedSessions);
    await prefs.setString(_kWeeklyStartDate, _weeklyStartDate?.toIso8601String() ?? _currentWeekStart().toIso8601String());
  }

  void startSession({Duration? duration}) {
    stopSession();
    sessionDuration = duration ?? sessionDuration;
    remainingSeconds = sessionDuration.inSeconds;
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds <= 0) {
        _sessionTimer?.cancel();
        _sessionTimer = null;
        remainingSeconds = 0;
        if (currentState != DockState.complete) {
          currentState = DockState.complete;
        }
        notifyListeners();
        return;
      }
      remainingSeconds -= 1;
      notifyListeners();
    });
    notifyListeners();
  }

  void stopSession() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    remainingSeconds = 0;
    notifyListeners();
  }

  void addSessionLog(String message) {
    _sessionLogs.insert(0, message);
    notifyListeners();
    _saveState();
  }

  Future<void> clearStatistics() async {
    _totalSessions = 0;
    _completedSessions = 0;
    _interruptedSessions = 0;
    _totalFocusSeconds = 0;
    _weeklyFocusSeconds = 0;
    _weeklyCompletedSessions = 0;
    _weeklyInterruptedSessions = 0;
    _weeklyStartDate = _currentWeekStart();
    notifyListeners();
    await _saveState();
  }

  Future<void> clearHistory() async {
    _sessionLogs.clear();
    notifyListeners();
    await _saveState();
  }

  void updateFromBleMessage(String message) {
    _resetWeeklyIfNeeded();

    if (message.startsWith('TIME:')) {
      final parts = message.split(':');
      if (parts.length == 2) {
        final seconds = int.tryParse(parts[1].trim());
        if (seconds != null && seconds > 0) {
          sessionDuration = Duration(seconds: seconds);
          if (!isSessionActive) {
            remainingSeconds = sessionDuration.inSeconds;
          }
          notifyListeners();
        }
      }
      return;
    }

    final timestamp = DateFormat('HH:mm').format(DateTime.now());
    final logEntry = '$message - $timestamp';

    switch (message) {
      case 'SYSTEM_ON':
      case 'READY':
        currentState = DockState.idle;
        isSystemOn = true;
        break;
      case 'START':
        if (currentState != DockState.focus) {
          _totalSessions += 1;
          if (!isSessionActive) {
            startSession();
          }
        }
        currentState = DockState.focus;
        break;
      case 'AWAY':
        if (currentState != DockState.away) {
          _interruptedSessions += 1;
          _weeklyInterruptedSessions += 1;
        }
        currentState = DockState.away;
        stopSession();
        break;
      case 'COMPLETE':
        if (currentState != DockState.complete) {
          _completedSessions += 1;
          _weeklyCompletedSessions += 1;
          _totalFocusSeconds += sessionDuration.inSeconds;
          _weeklyFocusSeconds += sessionDuration.inSeconds;
        }
        currentState = DockState.complete;
        stopSession();
        break;
      case 'SYSTEM_OFF':
      case 'OFF':
        currentState = DockState.off;
        isSystemOn = false;
        stopSession();
        break;
      default:
        break;
    }

    _sessionLogs.insert(0, logEntry);
    notifyListeners();
    _saveState();
  }

  DateTime _currentWeekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  void _resetWeeklyIfNeeded() {
    final currentWeek = _currentWeekStart();
    if (_weeklyStartDate == null || _weeklyStartDate!.isBefore(currentWeek)) {
      _weeklyStartDate = currentWeek;
      _weeklyFocusSeconds = 0;
      _weeklyCompletedSessions = 0;
      _weeklyInterruptedSessions = 0;
    }
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);
    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0 || hours > 0) parts.add('${minutes}m');
    parts.add('${seconds}s');
    return parts.join(' ');
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
