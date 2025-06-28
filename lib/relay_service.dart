import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RelayService {
  static const String deviceName = 'BT04-A';
  static final Guid serviceUuid = Guid('0000FFE0-0000-1000-8000-00805F9B34FB');
  static final Guid characteristicUuid = Guid('FFE1');

  Future<void> sendRelay(int relay, bool on) async {
    BluetoothDevice? target;

    // listen to scan results while scanning
    final sub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final advName = r.advertisementData.advName;
        final name = advName.isNotEmpty ? advName : r.device.platformName;
        if (name == deviceName) {
          target = r.device;
        }
      }
    });

    await FlutterBluePlus.startScan(
        withNames: [deviceName], timeout: const Duration(seconds: 5));

    // wait until scanning completes
    await FlutterBluePlus.isScanning.where((v) => v == false).first;
    await sub.cancel();

    if (target == null) return;

    await target!.connect();
    final services = await target!.discoverServices();
    for (final s in services) {
      if (s.uuid == serviceUuid) {
        for (final c in s.characteristics) {
          if (c.uuid == characteristicUuid) {
            final cmd = _buildCommand(relay, on);
            await c.write(cmd, withoutResponse: true);
            break;
          }
        }
      }
    }
    await target!.disconnect();
  }

  List<int> _buildCommand(int relay, bool on) {
    final state = on ? 0x01 : 0x00;
    final checksum = (0xA0 + relay + state) & 0xFF;
    return [0xA0, relay, state, checksum];
  }
}
