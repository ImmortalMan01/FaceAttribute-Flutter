import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RelayService {
  static const String deviceName = 'BT04-A';
  static const Guid serviceUuid = Guid('0000FFE0-0000-1000-8000-00805F9B34FB');
  static const Guid characteristicUuid = Guid('FFE1');

  final FlutterBluePlus _ble = FlutterBluePlus.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;

  Future<void> _connect() async {
    if (_device != null && _characteristic != null) return;

    await _ble.startScan(timeout: const Duration(seconds: 5));
    await for (final scan in _ble.scanResults) {
      final result = scan.firstWhere(
        (r) => r.device.name == deviceName,
        orElse: () => null,
      );
      if (result != null) {
        _device = result.device;
        break;
      }
    }
    await _ble.stopScan();

    if (_device == null) return;
    await _device!.connect();
    List<BluetoothService> services = await _device!.discoverServices();
    for (var s in services) {
      if (s.uuid == serviceUuid) {
        for (var c in s.characteristics) {
          if (c.uuid == characteristicUuid) {
            _characteristic = c;
            break;
          }
        }
      }
    }
  }

  Future<void> sendRelay(int relay, bool on) async {
    await _connect();
    if (_characteristic == null) return;
    final cmd = _buildCommand(relay, on);
    await _characteristic!.write(cmd, withoutResponse: true);
  }

  List<int> _buildCommand(int relay, bool on) {
    final state = on ? 0x01 : 0x00;
    final checksum = (0xA0 + relay + state) & 0xFF;
    return [0xA0, relay, state, checksum];
  }
}
