import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/workflow_provider.dart';
import '../../../data/models/workflow_models.dart';

class ComplaintBoxView extends ConsumerStatefulWidget {
  final String hostelId;
  final String currentUserId;
  final String currentUserName;
  final bool isManagementRole; // Admin or Warden trigger flags context

  const ComplaintBoxView({
    super.key,
    required this.hostelId,
    required this.currentUserId,
    required this.currentUserName,
    required this.isManagementRole,
  });

  @override
  ConsumerState<ComplaintBoxView> createState() => _ComplaintBoxViewState();
}

class _ComplaintBoxViewState extends ConsumerState<ComplaintBoxView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(workflowProvider.notifier).listenToHostelWorkflow(widget.hostelId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _dispatchComplaint() {
    if (_titleController.text.isNotEmpty && _descController.text.isNotEmpty) {
      final complaint = ComplaintModel(
        id: const Uuid().v4(),
        hostelId: widget.hostelId,
        studentId: widget.currentUserId,
        studentName: widget.currentUserName,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        status: 'Pending',
        reply: '',
      );
      ref.read(workflowProvider.notifier).logComplaint(complaint);
      _titleController.clear();
      _descController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddComplaintSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Log New Infrastructure Complaint', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Issue Subject Header')),
            const SizedBox(height: 8),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Detailed Explanation Matrix'), maxLines: 3),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _dispatchComplaint, child: const Text('Submit Ticket Node')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showResolutionDialog(String complaintId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Core Ticket Item'),
        content: TextField(controller: _replyController, decoration: const InputDecoration(labelText: 'Action / Response Summary')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_replyController.text.isNotEmpty) {
                ref.read(workflowProvider.notifier).resolveComplaint(complaintId, 'Resolved', _replyController.text.trim());
                _replyController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Close Ticket'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Infrastructure Support Ledger')),
      floatingActionButton: widget.isManagementRole ? null : FloatingActionButton(
        onPressed: _showAddComplaintSheet,
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
      body: workflowState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : workflowState.complaints.isEmpty
              ? const Center(child: Text('No complaints or tickets are registered on this node.'))
              : ListView.builder(
                  itemCount: workflowState.complaints.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final ticket = workflowState.complaints[index];
                    return Card(
                      child: ListTile(
                        title: Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Logged By: ${ticket.studentName}'),
                            Text('Description: ${ticket.description}'),
                            if (ticket.reply.isNotEmpty) Text('Resolution Code: ${ticket.reply}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        trailing: widget.isManagementRole && ticket.status != 'Resolved'
                            ? ElevatedButton(onPressed: () => _showResolutionDialog(ticket.id), child: const Text('Resolve'))
                            : Chip(
                                label: Text(ticket.status),
                                backgroundColor: ticket.status == 'Resolved' ? Colors.green.shade1.withOpacity(0.2) : Colors.amber.shade1.withOpacity(0.2),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}