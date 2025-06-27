import 'package:intl/intl.dart';

class RecognitionLog {
  final String name;
  final String time;
  final int age;
  final int gender;

  const RecognitionLog(
      {required this.name,
      required this.time,
      required this.age,
      required this.gender});

  factory RecognitionLog.fromMap(Map<String, dynamic> data) {
    return RecognitionLog(
      name: data['name'],
      time: data['time'],
      age: data['age'] ?? -1,
      gender: data['gender'] ?? -1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'time': time,
      'age': age,
      'gender': gender,
    };
  }

  String get formattedTime {
    try {
      final parsed = DateTime.parse(time);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsed);
    } catch (_) {
      return time;
    }
  }
}
