import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../providers/notice_provider.dart';
import '../../../data/models/notice_model.dart';

class NoticeBoardView extends ConsumerStatefulWidget {
  final String hostelId;
  final String currentUserName;
  final bool isManagementRole;

  const NoticeBoardView({
    super.key,
    required this.hostelId,
    required this.currentUserName,
    required this.isManagementRole,
  });

  @override
  ConsumerState<NoticeBoardView> createState() => _NoticeBoardViewState();
}

class _NoticeBoardViewState extends ConsumerState<NoticeBoardView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedTargetRole = 'All';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(noticeProvider.notifier).listenToHostelNotices(widget.hostelId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _publishNoticeToTenantNode() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      final noticeId = const Uuid().v4();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final notice = NoticeModel(
        id: noticeId,
        hostelId: widget.hostelId,
        title: title,
        content: content,
        postedBy: widget.currentUserName,
        dateString: dateStr,
        targetRole: _selectedTargetRole,
      );

      ref.read(noticeProvider.notifier).dispatchNoticeBroadcast(notice);

      _titleController.clear();
      _contentController.clear();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice Broadcast Multi-Cast Protocol Executed Successfully.')),
      );
    }
  }

  void _showPublishNoticeDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Broadcast Official Notice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Notice Headline Topic')),
                const SizedBox(height: 8),
                TextField(controller: _contentController, decoration: const InputDecoration(labelText: 'Detailed Broadcast Message'), maxLines: 4),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedTargetRole,
                  decoration: const InputDecoration(labelText: 'Target Visibility Vector'),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Members')),
                    DropdownMenuItem(value: 'Student', child: Text('Students Only')),
                    DropdownMenuItem(value: 'Warden', child: Text('Wardens Only')),
                    DropdownMenuItem(value: 'Parent', child: Text('Parents Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        _selectedTargetRole = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(onPressed: _publishNoticeToTenantNode, child: const Text('Transmit Broadcast')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noticeState = ref.watch(noticeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Official Bulletin Station')),
      floatingActionButton: widget.isManagementRole
          ? FloatingActionButton(
              onPressed: _showPublishNoticeDialog,
              backgroundColor: const Color(0xFF1E3A8A),
              child: const Icon(Icons.campaign, color: Colors.white),
            )
          : null,
      body: noticeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : noticeState.notices.isEmpty
              ? const Center(child: Text('Notice pipeline empty. No broadcast data records synchronized.'))
              : ListView.builder(
                  itemCount: noticeState.notices.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final notice = noticeState.notices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notice.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                                  ),
                                ),
                                Chip(
                                  label: Text(notice.targetRole, style: const TextStyle(fontSize: 11)),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                )
                              ],
                            ),
                            const Divider(height: 16),
                            Text(notice.content, style: const TextStyle(fontSize: 14, height: 1.4)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Issued By: ${notice.postedBy}', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                                Text(notice.dateString, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}