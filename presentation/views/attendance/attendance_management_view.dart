import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import '../../../data/models/attendance_model.dart';

class AttendanceManagementView extends ConsumerStatefulWidget {
  final String hostelId;
  final String currentWardenName;

  const AttendanceManagementView({
    super.key,
    required this.hostelId,
    required this.currentWardenName,
  });

  @override
  ConsumerState<AttendanceManagementView> createState() => _AttendanceManagementViewState();
}

class _AttendanceManagementViewState extends ConsumerState<AttendanceManagementView> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _tempStatusMap = {}; // Tracks studentId -> Status mapping

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchTargetDataState();
    });
  }

  void _fetchTargetDataState() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    ref.read(studentProvider.notifier).listenToStudents(widget.hostelId);
    ref.read(attendanceProvider.notifier).listenToAttendanceByDate(widget.hostelId, dateStr);
  }

  void _processAndSubmitRegister() {
    final studentState = ref.read(studentProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    List<AttendanceModel> batchRecords = [];

    for (var student in studentState.students) {
      final status = _tempStatusMap[student.id] ?? 'Present';
      final recordId = '${widget.hostelId}_${student.id}_$dateStr';

      batchRecords.add(
        AttendanceModel(
          id: recordId,
          hostelId: widget.hostelId,
          studentId: student.id,
          studentName: student.name,
          roomNumber: student.roomNumber,
          date: dateStr,
          status: status,
          markedBy: widget.currentWardenName,
        ),
      );
    }

    if (batchRecords.isNotEmpty) {
      ref.read(attendanceProvider.notifier).submitBulkAttendance(batchRecords).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance Log Uploaded Successfully Node.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);
    final attendanceState = ref.watch(attendanceProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Sync state map variables with existing logs if already saved on Firestore
    for (var record in attendanceState.attendanceRecords) {
      _tempStatusMap[record.studentId] = record.status;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operational Attendance Register'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_as),
            onPressed: _processAndSubmitRegister,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date Framework: $dateStr',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                      _fetchTargetDataState();
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Change Date'),
                )
              ],
            ),
          ),
          Expanded(
            child: studentState.isLoading || attendanceState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : studentState.students.isEmpty
                    ? const Center(child: Text('No active structural profiles registered to pull logs.'))
                    : ListView.builder(
                        itemCount: studentState.students.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final student = studentState.students[index];
                          final currentStatus = _tempStatusMap[student.id] ?? 'Present';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        Text('Room Assignment: ${student.roomNumber}'),
                                      ],
                                    ),
                                  ),
                                  SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment(value: 'Present', label: Text('P'), icon: Icon(Icons.check, size: 14)),
                                      ButtonSegment(value: 'Absent', label: Text('A'), icon: Icon(Icons.close, size: 14)),
                                      ButtonSegment(value: 'Leave', label: Text('L'), icon: Icon(Icons.time_to_leave, size: 14)),
                                    ],
                                    selected: {currentStatus},
                                    onSelectionChanged: (newSelection) {
                                      setState(() {
                                        _tempStatusMap[student.id] = newSelection.first;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}