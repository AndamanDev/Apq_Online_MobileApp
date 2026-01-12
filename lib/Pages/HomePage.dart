import 'package:apq_m1/Pages/SettingsPage.dart';
import 'package:apq_m1/Pages/Tabs/all.dart';
import 'package:apq_m1/Pages/Tabs/hold.dart';
import 'package:apq_m1/Pages/Tabs/wait.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/ProviderQueue.dart';
import 'Tabs/call.dart';

class Homepage extends StatefulWidget {
  final int branchId;

  const Homepage({super.key, required this.branchId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderQueue>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<ProviderQueue>();

    if (queue.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (queue.error != null) {
      return Scaffold(body: Center(child: Text(queue.error!)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          queue.serviceList.isNotEmpty
              ? queue.branchId.toString() ?? ''
              : 'Homepage',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Queue',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text('ยืนยันการล้างคิว'),
                    content: const Text(
                      'คุณต้องการลบคิวทั้งหมดในสาขานี้ใช่หรือไม่?\nการกระทำนี้ไม่สามารถย้อนกลับได้',
                    ),
                    actions: [
                      TextButton(
                        child: const Text('ยกเลิก'),
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('ลบทั้งหมด'),
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await context.read<ProviderQueue>().clearQueue(
                  context: context,
                  branchid: queue.branchId,
                );
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(text: 'Call'),
            Tab(text: 'Wait (${queue.waitingQueueList.length})'),
            Tab(text: 'Hold (${queue.holdingQueueList.length})'),
            Tab(text: 'Total (${queue.allingQueueList.length})'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [CallTab(), WaitTab(), HoldTab(), AllTab()],
      ),
    );
  }
}
