import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'logger.dart';

int _androidSdkInt() {
  if (!Platform.isAndroid) return 0;
  final match = RegExp(r'API (\d+)').firstMatch(Platform.operatingSystemVersion);
  return match != null ? int.tryParse(match.group(1) ?? '') ?? 0 : 0;
}

class BleNotificationService {
  BleNotificationService._internal();
  static final BleNotificationService instance = BleNotificationService._internal();

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _scanStateSubscription;
  final StreamController<String> _messages = StreamController<String>.broadcast();

  Stream<String> get messages => _messages.stream;

  Future<bool> _requestPermissions(BuildContext? context) async {
    AppLogger.i('Requesting BLE permissions');
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.notification,
    ];
    if (Platform.isAndroid && _androidSdkInt() >= 34) {
      // No runtime permission exists for foreground services on Android.
      // Only a manifest declaration is required, so skip requesting it.
    }
    final statuses = await permissions.request();

    statuses.forEach((permission, status) {
      if (status.isGranted) {
        AppLogger.i('Permission granted: ${permission.toString()}');
      } else {
        AppLogger.e('Permission denied: ${permission.toString()}');
      }
    });

    final granted = statuses.values.every((status) => status.isGranted);
    if (!granted) {
      AppLogger.e(
          'Required BLE permissions not granted. Please grant "Nearby devices" and "Post notifications" permissions in system settings.');
    }

    bool locationEnabled = true;
    final locationStatus = statuses[Permission.locationWhenInUse];
    if (locationStatus?.isGranted ?? false) {
      final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
      if (!serviceStatus.isEnabled) {
        locationEnabled = false;
        AppLogger.e('Location services are disabled');
        if (context != null) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Location Off'),
              content: const Text(
                  'Please enable location services to use BLE notifications.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }

    return granted && locationEnabled;
  }

  Future<void> startScanning({BuildContext? context}) async {
    if (!await _requestPermissions(context)) {
      AppLogger.e('Cannot start scanning: permissions not granted');
      return;
    }
    AppLogger.i('Starting BLE scan');
    await _scanSubscription?.cancel();
    await _scanStateSubscription?.cancel();
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
    _scanStateSubscription =
        FlutterBluePlus.isScanning.listen((isScanning) async {
      if (!isScanning) {
        AppLogger.i('Scan stopped unexpectedly, restarting');
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 0));
      }
    });
    AppLogger.i('BLE scan started');
  }

  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _scanStateSubscription?.cancel();
    _scanStateSubscription = null;
    AppLogger.i('Stopped BLE scan');
  }

  Future<void> broadcastName(String name, {Duration duration = const Duration(seconds: 5), BuildContext? context}) async {
    if (!await _requestPermissions(context)) {
      AppLogger.e('Cannot advertise: permissions not granted');
      return;
    }
    AppLogger.i('Starting BLE advertising with name ' + name);
    final encodedName = utf8.encode(name);
    final truncatedBytes = encodedName.length > 20
        ? encodedName.sublist(0, 20)
        : encodedName;
    final shortName = name.length > 18 ? name.substring(0, 18) : name;
    final data = AdvertiseData(
      includeDeviceName: true,
      localName: 'face:$shortName',
      manufacturerId: 0xffff,
      manufacturerData: Uint8List.fromList(truncatedBytes),
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
