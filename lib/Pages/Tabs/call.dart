import 'package:apq_m1/Class/ClassObject.dart';
import 'package:apq_m1/Models/ModelsServiceQueueBinding.dart';
import 'package:apq_m1/Provider/ProviderQueue.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Class/ClassOthersDialog.dart';
import '../../Widgets/WidgetNumpad.dart';

class CallTab extends StatelessWidget {
  const CallTab({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<ProviderQueue>();

    final serviceList = queue.serviceList;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: serviceList.length,
      itemBuilder: (context, index) {
        final item = serviceList[index];
        final bool isCurrentQueueMatch =
            item.callerQueueNo != null && item.callerQueueNo!.trim().isNotEmpty;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                /// ===== TOP INFO =====
                Row(
                  children: [
                    _info('Service', item.serviceGroupName ?? '-'),
                    _info('Waiting', '${item.qWait ?? 0}'),
                    _info(
                      'Next',
                      item.nextQueueNo != ''
                          ? '${item.nextQueueNo}(${item.nextQueueNoNumberPax})'
                          : '-',
                    ),

                    /// CURRENT QUEUE
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
                          item.callerQueueNo ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// ===== ACTION BUTTONS =====
                Row(
                  children: [
                    _btn(
                      label: 'ADD Q',
                      color: AppColors.primary,
                      onPressed: () => _showAddQueueNumpad(context, item),
                    ),
                    _gap(),
                    _btn(
                      label: 'ARRIVED',
                      color: AppColors.green,
                      onPressed: isCurrentQueueMatch
                          ? () => context.read<ProviderQueue>().updateQueue(
                              service: item,
                              statusQueue: 'Finishing',
                              statusQueueNote: '1',
                            )
                          : null,
                    ),
                    _gap(),
                    _btn(
                      label: 'OTHERS',
                      color: AppColors.orange,
                      onPressed: isCurrentQueueMatch
                          ? () => ClassOthersDialog.show(context, item, "1")
                          : null,
                    ),
                    _gap(),
                    _btn(
                      label: isCurrentQueueMatch ? 'RECALL' : 'CALL',
                      color: AppColors.primary,
                      onPressed: () async {
                        isCurrentQueueMatch
                            ? await context.read<ProviderQueue>().updateQueue(
                                service: item,
                                statusQueue: 'Recalling',
                                statusQueueNote: '',
                              )
                            : await context.read<ProviderQueue>().callQueue(
                                service: item,
                              );
                      },
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

  /// ===== helper widgets =====

  Widget _info(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _btn({
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: FittedBox(child: Text(label)),
      ),
    );
  }

  Widget _gap() => const SizedBox(width: 6);

  /// ===== ADD QUEUE =====

  void _showAddQueueNumpad(
    BuildContext parentContext,
    ModelsServiceQueueBinding item,
  ) {
    final controller = TextEditingController();

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
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                  Widgetnumpad(
                    currentValue: controller.text,
                    onNumberTap: (v) => setState(() => controller.text += v),
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
                    onClear: () => setState(controller.clear),
                    onSubmit: () async {
                      if (controller.text.isEmpty) return;

                      final pax = int.parse(controller.text);
                      Navigator.pop(context);

                      await parentContext.read<ProviderQueue>().createQueue(
                        // context: context,
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
