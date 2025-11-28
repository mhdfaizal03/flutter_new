import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:students_record/view_model/student_add_provider.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<StudentAddProvider>(
        builder: (context, provider, child) {
          return _buildByStudentView(provider);
        },
      ),
    );
  }

  Widget _buildByStudentView(StudentAddProvider provider) {
    if (provider.studentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Students',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return StudentAttendanceView(
      students: provider.studentList,
      attendanceRecords: provider.attendanceRecords,
    );
  }
}

class StudentAttendanceView extends StatefulWidget {
  final List students;
  final List attendanceRecords;

  const StudentAttendanceView({
    Key? key,
    required this.students,
    required this.attendanceRecords,
  }) : super(key: key);

  @override
  State<StudentAttendanceView> createState() => _StudentAttendanceViewState();
}

class _StudentAttendanceViewState extends State<StudentAttendanceView> {
  late int selectedStudentIndex;
  late DateTime displayedMonth;

  @override
  void initState() {
    super.initState();
    selectedStudentIndex = 0;
    displayedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.students.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedStudent = widget.students[selectedStudentIndex];

    return Column(
      children: [
        // Student Dropdown and Month Selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Dropdown
              Text(
                'Select Student',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: selectedStudentIndex,
                isExpanded: true,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedStudentIndex = newValue;
                    });
                  }
                },
                items: List.generate(
                  widget.students.length,
                  (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      '${widget.students[index].name} (${widget.students[index].batch})',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Month Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getMonthName(displayedMonth.month)} ${displayedMonth.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            displayedMonth = DateTime(
                              displayedMonth.year,
                              displayedMonth.month - 1,
                            );
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            displayedMonth = DateTime(
                              displayedMonth.year,
                              displayedMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Calendar Grid
        Expanded(child: _buildCalendarGrid(selectedStudent)),
      ],
    );
  }

  Widget _buildCalendarGrid(dynamic selectedStudent) {
    final daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final date = DateTime(displayedMonth.year, displayedMonth.month, day);

        // Find attendance record for this date
        final records = widget.attendanceRecords
            .where(
              (r) =>
                  r.studentId == selectedStudent.id.toString() &&
                  r.date.year == date.year &&
                  r.date.month == date.month &&
                  r.date.day == date.day,
            )
            .toList();

        final record = records.isNotEmpty ? records.first : null;
        final isPresent = record != null && record.isPresent;
        final hasRecord = record != null;

        return Container(
          decoration: BoxDecoration(
            color: hasRecord
                ? (isPresent ? Colors.green[100] : Colors.red[100])
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasRecord
                  ? (isPresent ? Colors.green : Colors.red)
                  : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: hasRecord
                        ? (isPresent ? Colors.green : Colors.red)
                        : Colors.grey[600],
                  ),
                ),
                if (hasRecord)
                  Icon(
                    isPresent ? Icons.check : Icons.close,
                    color: isPresent ? Colors.green : Colors.red,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
