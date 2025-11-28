import 'package:flutter/material.dart';

class AttendanceRecord {
  String studentId;
  String studentName;
  String batch;
  String stack;
  DateTime date;
  TimeOfDay time;
  bool isPresent;

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.batch,
    required this.stack,
    required this.date,
    required this.time,
    required this.isPresent,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'batch': batch,
      'stack': stack,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'isPresent': isPresent ? 1 : 0,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    return AttendanceRecord(
      studentId: map['studentId'],
      studentName: map['studentName'],
      batch: map['batch'] ?? '',
      stack: map['stack'] ?? '',
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      isPresent: map['isPresent'] == 1,
    );
  }
}
