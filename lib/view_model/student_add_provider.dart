import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:students_record/models/student_model.dart';
import 'package:students_record/models/attendance_model.dart';

class StudentAddProvider extends ChangeNotifier {
  List<StudentModel> studentList = [];
  List<AttendanceRecord> attendanceRecords = [];

  void loadStudents() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? studentStringList = prefs.getStringList('students');
    if (studentStringList != null) {
      studentList = studentStringList.map((studentString) {
        Map<String, dynamic> studentMap = jsonDecode(studentString);
        return StudentModel.fromMap(studentMap);
      }).toList();
      notifyListeners();
    }
  }

  void loadAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? attendanceStringList = prefs.getStringList('attendance');
    if (attendanceStringList != null) {
      attendanceRecords = attendanceStringList.map((attendanceString) {
        Map<String, dynamic> attendanceMap = jsonDecode(attendanceString);
        return AttendanceRecord.fromMap(attendanceMap);
      }).toList();
      notifyListeners();
    }
  }

  void saveStudents() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> studentStringList = studentList
        .map((student) => jsonEncode(student.toMap()))
        .toList();
    await prefs.setStringList('students', studentStringList);
  }

  void saveAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> attendanceStringList = attendanceRecords
        .map((record) => jsonEncode(record.toMap()))
        .toList();
    await prefs.setStringList('attendance', attendanceStringList);
  }

  void addStudent(StudentModel student) {
    studentList.add(student);
    saveStudents();
    notifyListeners();
  }

  void updateStudent(int index, StudentModel student) {
    studentList[index] = student;
    saveStudents();
    notifyListeners();
  }

  void removeStudent(int index) {
    studentList.removeAt(index);
    saveStudents();
    notifyListeners();
  }

  void clearStudents() {
    studentList.clear();
    saveStudents();
    notifyListeners();
  }

  void saveAttendance(
    Map<int, bool> attendanceMap,
    DateTime date,
    TimeOfDay time,
    List<StudentModel> batchStudents,
  ) {
    for (int i = 0; i < batchStudents.length; i++) {
      final isPresent = attendanceMap[i] ?? false;
      final student = batchStudents[i];

      // Remove existing record for this student on this date
      attendanceRecords.removeWhere(
        (record) =>
            record.studentId == student.id.toString() &&
            record.date.year == date.year &&
            record.date.month == date.month &&
            record.date.day == date.day,
      );

      // Add new record with batch, stack, and time
      attendanceRecords.add(
        AttendanceRecord(
          studentId: student.id.toString(),
          studentName: student.name,
          batch: student.batch,
          stack: student.stack,
          date: date,
          time: time,
          isPresent: isPresent,
        ),
      );
    }
    saveAttendanceRecords();
    notifyListeners();
  }

  // Get attendance records for a specific date
  List<AttendanceRecord> getAttendanceByDate(DateTime date) {
    return attendanceRecords
        .where(
          (record) =>
              record.date.year == date.year &&
              record.date.month == date.month &&
              record.date.day == date.day,
        )
        .toList();
  }

  // Get attendance records for a specific month
  List<AttendanceRecord> getAttendanceByMonth(int year, int month) {
    return attendanceRecords
        .where(
          (record) => record.date.year == year && record.date.month == month,
        )
        .toList();
  }

  // Get unique dates with attendance records
  List<DateTime> getUniqueDates() {
    final Set<String> uniqueDates = {};
    final List<DateTime> dates = [];

    for (var record in attendanceRecords) {
      final dateString =
          '${record.date.year}-${record.date.month}-${record.date.day}';
      if (!uniqueDates.contains(dateString)) {
        uniqueDates.add(dateString);
        dates.add(
          DateTime(record.date.year, record.date.month, record.date.day),
        );
      }
    }

    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }
}
