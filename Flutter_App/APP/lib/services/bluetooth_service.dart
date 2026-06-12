import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_state.dart';

class BluetoothServiceManager {
  final AppState appState;
  BluetoothDevice? _device;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  BluetoothCharacteristic? _writeCharacteristic;
  final StringBuffer _messageBuffer = StringBuffer();
  Timer? _reconnectTimer;

  BluetoothServiceManager(this.appState);

  Future<void> init() async {
    _listenAdapterState();
    await requestPermissionsAndScan();
  }

  Future<void> requestPermissionsAndScan() async {
    final granted = await _requestPermissions();

    if (!granted) {
      appState.setScanning(false);
      return;
    }

    startScan();
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  void _listenAdapterState() {
    _adapterSubscription?.cancel();
    _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        if (_device != null && _device!.isDisconnected) {
          connectToDevice(_device!);
          return;
        }

        if (!FlutterBluePlus.isScanningNow && !_isDeviceConnected) {
          startScan();
        }
      }

      if (state == BluetoothAdapterState.off) {
        appState.setBluetoothConnected(false);
        appState.setSystemOn(false);
        stopScan();
      }
    });
  }

  bool get _isDeviceConnected => _device != null && _device!.isConnected;

  void startScan({Duration timeout = const Duration(seconds: 10)}) {
    appState.setScanning(true);
    stopScan();
    FlutterBluePlus.startScan(timeout: timeout);

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final name = result.advertisementData.localName.isNotEmpty
            ? result.advertisementData.localName
            : result.device.name;

        final deviceId = result.device.id.id;
        if (deviceId == '5A:BE:57:BE:CC:3A' ||
            name.contains('HC-05') ||
            name.contains('TUNU_DOCK') ||
            name.contains('TUNU')) {
          _device = result.device;
          appState.setLastDeviceName(name.isNotEmpty ? name : deviceId);
          stopScan();
          connectToDevice(_device!);
          break;
        }
      }
    });
  }

  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    appState.setScanning(false);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    _device = device;
    _connectionSubscription?.cancel();

    _connectionSubscription = device.connectionState.listen((state) {
      final connected = state == BluetoothConnectionState.connected;
      appState.setBluetoothConnected(connected);
      if (!connected) {
        appState.setSystemOn(false);
        _scheduleReconnect();
      } else {
        _reconnectTimer?.cancel();
      }
    });

    try {
      await device.connect();
      await _discoverServicesAndSubscribe();
    } catch (_) {
      appState.setBluetoothConnected(false);
      _scheduleReconnect();
    }
  }

  Future<void> _discoverServicesAndSubscribe() async {
    if (_device == null) return;

    final services = await _device!.discoverServices();

    BluetoothDevice? device = _device;
    if (device == null) return;

    final targetService = services.firstWhere(
      (service) => service.uuid.toString().toUpperCase().contains('FFE0'),
      orElse: () => throw StateError('Service FFE0 not found'),
    );

    BluetoothCharacteristic? notifyCharacteristic;
    _writeCharacteristic = null;

    for (final char in targetService.characteristics) {
      final uuid = char.uuid.toString().toUpperCase();
      if (uuid.contains('FFE1')) {
        notifyCharacteristic = char;
      }
      if (uuid.contains('FFE2')) {
        _writeCharacteristic = char;
      }
    }

    if (notifyCharacteristic == null) {
      throw StateError('Characteristic FFE1 not found');
    }

    await notifyCharacteristic.setNotifyValue(true);
    _notificationSubscription?.cancel();
    _notificationSubscription = notifyCharacteristic.lastValueStream.listen((value) {
      if (value.isEmpty) return;

      final chunk = String.fromCharCodes(value);
      _messageBuffer.write(chunk);
      final text = _messageBuffer.toString();
      final lines = text.split(RegExp(r'[\r\n]+'));

      for (var i = 0; i < lines.length - 1; i++) {
        final message = lines[i].trim();
        if (message.isNotEmpty) {
          appState.updateFromBleMessage(message);
        }
      }

      _messageBuffer.clear();
      if (!text.endsWith('\n') && !text.endsWith('\r')) {
        _messageBuffer.write(lines.isNotEmpty ? lines.last : '');
      }
    });
  }

  Future<void> disconnect() async {
    await _connectionSubscription?.cancel();
    await _notificationSubscription?.cancel();
    await _scanSubscription?.cancel();
    _reconnectTimer?.cancel();

    if (_device != null) {
      await _device!.disconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_isDeviceConnected || FlutterBluePlus.isScanningNow) return;
      if (_device != null) {
        connectToDevice(_device!);
      } else {
        startScan();
      }
    });
  }

  void dispose() {
    _connectionSubscription?.cancel();
    _notificationSubscription?.cancel();
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    _reconnectTimer?.cancel();
  }
}
