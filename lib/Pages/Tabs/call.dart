import 'package:apq_m1/Class/ClassObject.dart';
import 'package:apq_m1/Models/ModelsServiceQueueBinding.dart';
import 'package:apq_m1/Provider/ProviderQueue.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Class/ClassOthersDialog.dart';
import '../../Class/ClassSocket.dart';
import '../../Widgets/WidgetNumpad.dart';
import '../../Models/ModelsQueueBinding.dart';

class CallTab extends StatelessWidget {
  const CallTab({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<ProviderQueue>();

    final serviceList = queue.serviceList;
    final callingQueueList = queue.callingQueueList;

    if (queue.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (serviceList.isEmpty) {
      return const Center(child: Text('ไม่มีข้อมูลงานบริการ'));
    }

    return ListView.builder(
      itemCount: serviceList.length,
      itemBuilder: (context, index) {
        final item = serviceList[index];

        final currentQueues = callingQueueList
            .where((q) => q.serviceId == item.serviceId)
            .toList();

        final ModelsQueueBinding? currentQueue = currentQueues.isNotEmpty
            ? currentQueues.last
            : null;

        final bool isCurrentQueueMatch = currentQueue != null;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Row(
                  children: [
                    /// Service
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Service',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.serviceGroupName ?? "-",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    /// Waiting
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Waiting',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${item.qWait ?? 0}',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    /// Next
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Next',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.nextQueueNo != ''
                                ? '${item.nextQueueNo}(${item.nextQueueNoNumberPax})'
                                : "-",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    /// Current Queue
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          currentQueue?.queueNo ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAddQueueNumpad(context, item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text("ADD Q"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isCurrentQueueMatch
                            ? () async {
                                await context.read<ProviderQueue>().updateQueue(
                                  service: item,
                                  statusQueue: 'Finishing',
                                  statusQueueNote: '1',
                                );
                              }
                            : null,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          disabledBackgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text("ARRIVED"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isCurrentQueueMatch
                            ? () => ClassOthersDialog.show(context, item , "2")
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          disabledBackgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text("OTHERS"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          isCurrentQueueMatch
                              ? ClassSocket().recallQueue(currentQueue)
                              : await context.read<ProviderQueue>().callQueue(
                                  context: context,
                                  service: item,
                                );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(isCurrentQueueMatch ? "RECALL" : "CALL"),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddQueueNumpad(
    BuildContext parentContext,
    ModelsServiceQueueBinding item,
  ) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: controller,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'จำนวนลูกค้า | Pax Qty',
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Widgetnumpad(
                    currentValue: controller.text,
                    onNumberTap: (value) {
                      setState(() {
                        controller.text += value;
                      });
                    },
                    onDelete: () {
                      setState(() {
                        if (controller.text.isNotEmpty) {
                          controller.text = controller.text.substring(
                            0,
                            controller.text.length - 1,
                          );
                        }
                      });
                    },
                    onClear: () {
                      setState(() {
                        controller.clear();
                      });
                    },
                    onSubmit: () async {
                      if (controller.text.isEmpty) return;

                      final int pax = int.parse(controller.text);
                      Navigator.pop(context);

                      await parentContext.read<ProviderQueue>().createQueue(
                        context: context,
                        pax: pax,
                        service: item,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
