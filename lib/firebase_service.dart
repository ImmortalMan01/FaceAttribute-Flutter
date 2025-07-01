import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.subscribeToTopic('face_events');
  }

  // Replace with your actual FCM server key.
  static const String _serverKey = 'YOUR_SERVER_KEY';

  static Future<void> sendNotification(String name) async {
    final payload = {
      'to': '/topics/face_events',
      'notification': {
        'title': 'Face Recognized',
        'body': '$name recognized',
      },
      'data': {
        'name': name,
      }
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to send FCM message: ${response.body}');
    }
  }
}
