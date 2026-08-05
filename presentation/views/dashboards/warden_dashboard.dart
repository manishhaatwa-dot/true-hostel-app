import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class WardenDashboard extends ConsumerWidget {
  const WardenDashboard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warden Ground Control'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(authProvider.notifier).logout()),
      ]),
      body: const Center(child: Text('Warden Attendance & Log Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    );
  }
}