class RecognitionLog {
  final String name;
  final String time;

  const RecognitionLog({required this.name, required this.time});

  factory RecognitionLog.fromMap(Map<String, dynamic> data) {
    return RecognitionLog(
      name: data['name'],
      time: data['time'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'time': time,
    };
  }
}
