import 'dart:async';
import 'dart:convert';
import 'package:apq_m1/Class/ClassReTicket.dart';
import 'package:intl/intl.dart';
import 'package:apq_m1/Class/ClassObject.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';
import '../../Class/ClassJsonHelper.dart';
import '../../Class/ClassOthersDialog.dart';
import '../../Class/ClassTicket.dart';
import '../../Class/ClassToast.dart';
import '../../Models/ModelsServiceQueueBinding.dart';
import '../../Models/ModeslQueueWithService.dart';
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
        child: Text(
          'ไม่มีคิวในวันนี้',
          style: TextStyle(color: AppColors.white),
        ),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 1),

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
                            title: "Stataus",
                            value: "${item.servicestatusName}",
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final status =
                                await PrintBluetoothThermal.connectionStatus;
                            if (!status) {
                              ClassToast.error("Printer not connected");
                              return;
                            }

                            final service = ModelsServiceQueueBinding.fromQueue(
                              item,
                              context.read<ProviderQueue>().serviceList,
                            );

                            final data = QueueWithService(
                              queue: item,
                              service: service,
                            );

                            ClassToast.success("Reprint เรียบร้อย");

                            final ticket = await Classreticket()
                                .reprintQueueTicket(data);

                            await PrintBluetoothThermal.writeBytes(ticket);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "REPRINT",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
