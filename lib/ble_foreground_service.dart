import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'ble_notification_service.dart';
import 'notification_helper.dart';

const String notificationChannelId = 'ble_scan';
const int notificationId = 999;

Future<void> initializeBleForegroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'BLE Scan',
    description: 'Scanning for BLE messages',
    // Use default importance so notifications appear visibly
    importance: Importance.defaultImportance,
  );

  // Initialize the notification plugin so the background isolate
  // can display alerts when BLE messages arrive.
  await initLocalNotifications(channel: channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: bleServiceOnStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'BLE Scanning',
      initialNotificationContent: 'Listening for BLE messages',
      foregroundServiceNotificationId: notificationId,
      foregroundServiceTypes: [AndroidForegroundType.connectedDevice],
    ),
    iosConfiguration: IosConfiguration(),
  );

  // Ensure the service actually starts. Without this call the background
  // service might never begin, preventing BLE scanning and notifications.
  await service.startService();
}

  @pragma('vm:entry-point')
void bleServiceOnStart(ServiceInstance service) async {
  // Ensure all plugins and bindings are ready for use in this isolate
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'BLE Scan',
    description: 'Scanning for BLE messages',
    importance: Importance.defaultImportance,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      await initLocalNotifications(channel: channel);

  BleNotificationService.instance.messages.listen((msg) {
    flutterLocalNotificationsPlugin.show(
      msg.hashCode,
      'BLE Message',
      msg,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          'BLE Scan',
          importance: Importance.defaultImportance,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  });

  await BleNotificationService.instance.startScanning();

  service.on('stopService').listen((event) async {
    await BleNotificationService.instance.stopScanning();
    service.stopSelf();
  });
}
