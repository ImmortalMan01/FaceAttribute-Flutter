import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleNotificationService {
  BleNotificationService._internal();
  static final BleNotificationService instance = BleNotificationService._internal();

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final StreamController<String> _messages = StreamController<String>.broadcast();

  Stream<String> get messages => _messages.stream;

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> startScanning() async {
    if (!await _requestPermissions()) return;
    await _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (r.advertisementData.manufacturerData.isNotEmpty) {
          final bytes = r.advertisementData.manufacturerData.values.first;
          try {
            final msg = String.fromCharCodes(bytes);
            _messages.add(msg);
          } catch (_) {}
        } else if (r.advertisementData.advName.startsWith('face:')) {
          _messages.add(r.advertisementData.advName.substring(5));
        }
      }
    });
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 0));
  }

  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<void> broadcastName(String name, {Duration duration = const Duration(seconds: 5)}) async {
    if (!await _requestPermissions()) return;
    final data = AdvertiseData(
      includeDeviceName: true,
      localName: 'face:$name',
      manufacturerId: 0xffff,
      manufacturerData: Uint8List.fromList(name.codeUnits),
    );
    await _peripheral.start(advertiseData: data);
    await Future.delayed(duration);
    await _peripheral.stop();
  }
}
