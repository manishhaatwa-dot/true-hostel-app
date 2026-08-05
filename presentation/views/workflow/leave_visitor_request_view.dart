import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/workflow_provider.dart';
import '../../../data/models/workflow_models.dart';

class LeaveVisitorRequestView extends ConsumerStatefulWidget {
  final String hostelId;
  final String currentUserId;
  final String currentUserName;
  final bool isManagementRole;

  const LeaveVisitorRequestView({
    super.key,
    required this.hostelId,
    required this.currentUserId,
    required this.currentUserName,
    required this.isManagementRole,
  });

  @override
  ConsumerState<LeaveVisitorRequestView> createState() => _LeaveVisitorRequestViewState();
}

class _LeaveVisitorRequestViewState extends ConsumerState<LeaveVisitorRequestView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _reasonController = TextEditingController();
  final _visitorController = TextEditingController();
  final _relationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () {
      ref.read(workflowProvider.notifier).listenToHostelWorkflow(widget.hostelId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    _visitorController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  void _dispatchLeave() {
    if (_reasonController.text.isNotEmpty) {
      final leave = LeaveRequestModel(
        id: const Uuid().v4(),
        hostelId: widget.hostelId,
        studentId: widget.currentUserId,
        studentName: widget.currentUserName,
        reason: _reasonController.text.trim(),
        startDate: '2026-08-10', // Standard target projection vectors simulation
        endDate: '2026-08-15',
        status: 'Pending',
      );
      ref.read(workflowProvider.notifier).submitLeaveRequest(leave);
      _reasonController.clear();
      Navigator.pop(context);
    }
  }

  void _dispatchVisitorPass() {
    if (_visitorController.text.isNotEmpty && _relationController.text.isNotEmpty) {
      final pass = VisitorPassModel(
        id: const Uuid().v4(),
        hostelId: widget.hostelId,
        studentId: widget.currentUserId,
        studentName: widget.currentUserName,
        visitorName: _visitorController.text.trim(),
        relationship: _relationController.text.trim(),
        entryTime: '10:00 AM',
        exitTime: '04:00 PM',
        status: 'Pending',
      );
      ref.read(workflowProvider.notifier).requestVisitorPass(pass);
      _visitorController.clear();
      _relationController.clear();
      Navigator.pop(context);
    }
  }

  void _showLeaveForm() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Apply for Leave Pass', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _reasonController, decoration: const InputDecoration(labelText: 'Reason for Leave Outline')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _dispatchLeave, child: const Text('File Application Link'))
          ],
        ),
      ),
    );
  }

  void _showVisitorForm() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Register Visitor Pass Node', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _visitorController, decoration: const InputDecoration(labelText: 'Full Name of Visitor')),
            const SizedBox(height: 4),
            TextField(controller: _relationController, decoration: const InputDecoration(labelText: 'Relationship Context')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _dispatchVisitorPass, child: const Text('Generate Gate Pass Token'))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passes & Clearances Station'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Leave Manifests'), Tab(text: 'Visitor Clearances')],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Leave Requests Management Matrix
          Scaffold(
            floatingActionButton: widget.isManagementRole ? null : FloatingActionButton(onPressed: _showLeaveForm, child: const Icon(Icons.flight_takeoff)),
            body: ListView.builder(
              itemCount: workflowState.leaves.length,
              itemBuilder: (context, i) {
                final item = workflowState.leaves[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('${item.studentName} - ${item.reason}'),
                    subtitle: Text('Timeline Scope: ${item.startDate} to ${item.endDate}'),
                    trailing: widget.isManagementRole && item.status == 'Pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => ref.read(workflowProvider.notifier).updateLeaveStatus(item.id, 'Approved')),
                              IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => ref.read(workflowProvider.notifier).updateLeaveStatus(item.id, 'Rejected')),
                            ],
                          )
                        : Chip(label: Text(item.status)),
                  ),
                );
              },
            ),
          ),
          // Visitor Clearances Matrix
          Scaffold(
            floatingActionButton: widget.isManagementRole ? null : FloatingActionButton(onPressed: _showVisitorForm, child: const Icon(Icons.door_sliding)),
            body: ListView.builder(
              itemCount: workflowState.visitors.length,
              itemBuilder: (context, i) {
                final item = workflowState.visitors[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Visitor: ${item.visitorName} [${item.relationship}]'),
                    subtitle: Text('Host Student Element: ${item.studentName}\nWindow Schedule: ${item.entryTime} - ${item.exitTime}'),
                    trailing: widget.isManagementRole && item.status == 'Pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.gpp_good, color: Colors.green), onPressed: () => ref.read(workflowProvider.notifier).processVisitorStatus(item.id, 'Approved')),
                              IconButton(icon: const Icon(Icons.gpp_bad, color: Colors.red), onPressed: () => ref.read(workflowProvider.notifier).processVisitorStatus(item.id, 'Denied')),
                            ],
                          )
                        : Chip(label: Text(item.status)),
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