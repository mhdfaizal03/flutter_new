import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:students_record/view_model/student_add_provider.dart';
import 'package:students_record/views/attendance_report_page.dart';
import 'student_add_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Map<int, bool> attendanceMap = {}; // studentIndex -> attendance
  late DateTime currentDate;
  late TimeOfDay currentTime;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    currentTime = TimeOfDay.now();
    context.read<StudentAddProvider>().loadStudents();
    context.read<StudentAddProvider>().loadAttendanceRecords();
    _initializeTabController();
  }

  void _initializeTabController() {
    final provider = context.read<StudentAddProvider>();
    final batches = _getUniqueBatches(provider.studentList);
    _tabController = TabController(
      length: batches.isEmpty ? 1 : batches.length,
      vsync: this,
    );
  }

  List<String> _getUniqueBatches(List students) {
    final Set<String> batches = {};
    for (var student in students) {
      batches.add(student.batch);
    }
    return batches.toList()..sort();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentAddProvider>(
      builder: (context, provider, child) {
        final batches = _getUniqueBatches(provider.studentList);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Students Attendance'),
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.assessment),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceReportPage(),
                    ),
                  );
                },
                tooltip: 'Attendance Report',
              ),
            ],
            bottom: batches.isNotEmpty
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: batches.map((batch) => Tab(text: batch)).toList(),
                      indicatorColor: Colors.white,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
          ),
          body: batches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Students Added',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add students using the + button',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: batches.map((batch) {
                    return _buildBatchView(provider, batch);
                  }).toList(),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentAddPage()),
              ).then((_) {
                setState(() {
                  _initializeTabController();
                });
              });
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBatchView(StudentAddProvider provider, String batch) {
    final batchStudents = provider.studentList
        .where((s) => s.batch == batch)
        .toList();

    if (batchStudents.isEmpty) {
      return Center(child: Text('No students in $batch'));
    }

    final presentCount = attendanceMap.values.where((p) => p).length;
    final absentCount = batchStudents.length - presentCount;

    return Column(
      children: [
        // Date and Time Selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Column(
            children: [
              // Date Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${currentDate.day}/${currentDate.month}/${currentDate.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: currentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          currentDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Time Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time: ${currentTime.format(context)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: currentTime,
                      );
                      if (picked != null) {
                        setState(() {
                          currentTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // Header with attendance summary
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    batchStudents.length.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    presentCount.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Present',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    absentCount.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    'Absent',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Students List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: batchStudents.length,
            itemBuilder: (context, index) {
              final student = batchStudents[index];
              final isPresent = attendanceMap[index] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Student Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue[100],
                        ),
                        child: Center(
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Student Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Age: ${student.age}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Subject: ${student.stack}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Attendance Switch
                      Column(
                        children: [
                          Transform.scale(
                            scale: 1.2,
                            child: Switch(
                              value: isPresent,
                              onChanged: (value) {
                                setState(() {
                                  attendanceMap[index] = value;
                                });
                              },
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ),
                          Text(
                            isPresent ? 'Present' : 'Absent',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isPresent ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteDialog(context, provider, index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Save Attendance Button
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _saveAttendance(provider, batchStudents);
              },
              child: const Text(
                'Save Attendance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveAttendance(StudentAddProvider provider, List batchStudents) {
    provider.saveAttendance(
      attendanceMap,
      currentDate,
      currentTime,
      batchStudents.cast(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Attendance saved for ${currentDate.day}/${currentDate.month}/${currentDate.year} at ${currentTime.format(context)}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      attendanceMap.clear();
    });
  }

  void _showDeleteDialog(
    BuildContext context,
    StudentAddProvider provider,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeStudent(index);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
