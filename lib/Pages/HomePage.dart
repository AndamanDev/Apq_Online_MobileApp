import 'package:apq_m1/Class/ClassPrinterService.dart';
import 'package:apq_m1/Pages/Setting/SettingPrinter.dart';
import 'package:apq_m1/Pages/SettingsPage.dart';
import 'package:apq_m1/Pages/Tabs/all.dart';
import 'package:apq_m1/Pages/Tabs/hold.dart';
import 'package:apq_m1/Pages/Tabs/wait.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Class/ClassObject.dart';
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

    final printer = Classprinterservice.instance;

    if (!printer.connected) {
      debugPrint("Printer not connected");
    } else {
      debugPrint("Printer ready");
    }

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
    final serviceList = queue.serviceList;
    if (queue.loading) {
      // return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (queue.error != null) {
      return Scaffold(body: Center(child: Text(queue.error!)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          queue.serviceList.isNotEmpty
              ? serviceList[0].branchName ?? ''
              : 'Homepage',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Clear Queue',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ยืนยันการล้างคิว',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    content: const Text(
                      'คุณต้องการลบคิวทั้งหมดในสาขานี้ใช่หรือไม่?\n\n'
                      '⚠ การกระทำนี้ไม่สามารถย้อนกลับได้',
                      style: TextStyle(fontSize: 15),
                    ),
                    actionsPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text(
                          'ยกเลิก',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text(
                          'ลบทั้งหมด',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await context.read<ProviderQueue>().clearQueue(
                  // context: context,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Consumer<ProviderQueue>(
            builder: (_, queue, __) {
              return TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.white,
                indicatorColor: AppColors.white,
                indicatorWeight: 3,

                tabs: [
                  const Tab(text: 'Call'),
                  Tab(text: 'Wait (${queue.waitingQueueList.length})'),
                  Tab(text: 'Hold (${queue.holdingQueueList.length})'),
                  Tab(text: 'Total (${queue.allingQueueList.length})'),
                ],
              );
            },
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [CallTab(), WaitTab(), HoldTab(), AllTab()],
      ),
    );
  }
}
