import 'dart:async';
import 'package:intl/intl.dart';
import 'package:apq_m1/Class/ClassObject.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Class/ClassJsonHelper.dart';
import '../../Class/ClassOthersDialog.dart';
import '../../Models/ModelsServiceQueueBinding.dart';
import '../../Provider/ProviderQueue.dart';

class AllTab extends StatefulWidget {
  const AllTab({super.key});
  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<ProviderQueue>();

    final serviceList = queue.serviceList;
    final allingQueueList = queue.allingQueueList;

    if (queue.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (queue.allingQueueList.isEmpty) {
      return const Center(
        child: Text('ไม่มีคิวในวันนี้', style: TextStyle(color: AppColors.white)),
      );
    }

    return ListView.builder(
      itemCount: allingQueueList.length,
      itemBuilder: (context, index) {
        final item = allingQueueList[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Queue No
                      Text(
                        item.queueNo.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          _infoItem(
                            title: "Number",
                            value: "${item.numberPax ?? 0} Pax",
                          ),
                          _infoItem(
                            title: "Queue Start",
                            value: DateFormat('HH:mm').format(item.createAt!),
                          ),
                          _infoItem(
                            title: "Wait Time",
                            valueWidget: StreamBuilder<DateTime>(
                              stream: Stream.periodic(
                                const Duration(seconds: 30),
                                (_) => DateTime.now(),
                              ),
                              builder: (context, snapshot) {
                                return Text(
                                  JsonHelper.formatWaitTime(item.createAt),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                    
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem({
    required String title,
    String? value,
    Widget? valueWidget,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          valueWidget ??
              Text(
                value ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
        ],
      ),
    );
  }
}
