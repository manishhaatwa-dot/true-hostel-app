import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/student_provider.dart';
import '../../../data/models/student_model.dart';

class StudentManagementView extends ConsumerStatefulWidget {
  final String hostelId;
  const StudentManagementView({super.key, required this.hostelId});

  @override
  ConsumerState<StudentManagementView> createState() => _StudentManagementViewState();
}

class _StudentManagementViewState extends ConsumerState<StudentManagementView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roomController = TextEditingController();
  final _bedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(studentProvider.notifier).listenToStudents(widget.hostelId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roomController.dispose();
    _bedController.dispose();
    super.dispose();
  }

  void _registerStudentOnboard() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final room = _roomController.text.trim();
    final bed = _bedController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && room.isNotEmpty && bed.isNotEmpty) {
      final studentId = const Uuid().v4();
      final parentId = const Uuid().v4(); // Auto linked tracking profile entity

      final newStudent = StudentModel(
        id: studentId,
        hostelId: widget.hostelId,
        name: name,
        email: email,
        roomNumber: room,
        bedNumber: bed,
        parentId: parentId,
        isActive: true,
      );

      ref.read(studentProvider.notifier).onboardNewStudent(newStudent);

      _nameController.clear();
      _emailController.clear();
      _roomController.clear();
      _bedController.clear();
      Navigator.of(context).pop();
    }
  }

  void _showOnboardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Onboard New Student Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 8),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Identity Email Address'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 8),
              TextField(controller: _roomController, decoration: const InputDecoration(labelText: 'Allocated Room Number')),
              const SizedBox(height: 8),
              TextField(controller: _bedController, decoration: const InputDecoration(labelText: 'Allocated Bed Code')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: _registerStudentOnboard, child: const Text('Register Profile')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Student Directory Directory')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOnboardDialog,
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: studentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentState.students.isEmpty
              ? const Center(child: Text('No structural student profiles mapped yet. Click + to onboard.'))
              : ListView.builder(
                  itemCount: studentState.students.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final item = studentState.students[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1E3A8A),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Email: ${item.email}\nRoom Assignment: ${item.roomNumber} [Bed: ${item.bedNumber}]'),
                        trailing: Icon(
                          item.isActive ? Icons.check_circle : Icons.cancel,
                          color: item.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}