import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'logger.dart';

class BleNotificationService {
  BleNotificationService._internal();
  static final BleNotificationService instance = BleNotificationService._internal();

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final StreamController<String> _messages = StreamController<String>.broadcast();

  Stream<String> get messages => _messages.stream;

  Future<bool> _requestPermissions() async {
    AppLogger.i('Requesting BLE permissions');
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.notification,
    ].request();
    statuses.forEach((permission, status) {
      if (status.isGranted) {
        AppLogger.i('Permission granted: ${permission.toString()}');
      } else {
        AppLogger.e('Permission denied: ${permission.toString()}');
      }
    });
    final granted = statuses.values.every((status) => status.isGranted);
    if (!granted) {
      AppLogger.e('Required BLE permissions not granted');
    }
    return granted;
  }

  Future<void> startScanning() async {
    if (!await _requestPermissions()) {
      AppLogger.e('Cannot start scanning: permissions not granted');
      return;
    }
    AppLogger.i('Starting BLE scan');
    await _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (r.advertisementData.manufacturerData.isNotEmpty) {
          final bytes = r.advertisementData.manufacturerData.values.first;
          try {
            final msg = String.fromCharCodes(bytes);
            AppLogger.i('BLE message received: ' + msg);
            _messages.add(msg);
          } catch (_) {}
        } else if (r.advertisementData.advName.startsWith('face:')) {
          final msg = r.advertisementData.advName.substring(5);
          AppLogger.i('BLE message received: ' + msg);
          _messages.add(msg);
        }
      }
    });
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 0));
    AppLogger.i('BLE scan started');
  }

  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    AppLogger.i('Stopped BLE scan');
  }

  Future<void> broadcastName(String name, {Duration duration = const Duration(seconds: 5)}) async {
    if (!await _requestPermissions()) {
      AppLogger.e('Cannot advertise: permissions not granted');
      return;
    }
    AppLogger.i('Starting BLE advertising with name ' + name);
    final data = AdvertiseData(
      includeDeviceName: true,
      localName: 'face:$name',
      manufacturerId: 0xffff,
      manufacturerData: Uint8List.fromList(name.codeUnits),
    );
    try {
      await _peripheral.start(advertiseData: data);
      AppLogger.i('BLE advertising started');
    } catch (e, st) {
      AppLogger.e('Failed to start BLE advertising', e, st);
      return;
    }
    await Future.delayed(duration);
    try {
      await _peripheral.stop();
      AppLogger.i('BLE advertising stopped');
    } catch (e, st) {
      AppLogger.e('Failed to stop BLE advertising', e, st);
    }
  }
}
