import 'package:apq_m1/Class/ClassObject.dart';
import 'package:apq_m1/Models/ModelsQueueBinding.dart';
import 'package:apq_m1/Models/ModelsServiceQueueBinding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/ProviderQueue.dart';

class ClassOthersDialog {
  static const List<Map<String, dynamic>> reasons = [
    {'reason_id': 1, 'reason_note': 'เข้ารับบริการ\nGet in Service'},
    {'reason_id': 0, 'reason_note': 'พักคิว\nHold Queue'},
    {
      'reason_id': 3,
      'reason_note': 'ยกเลิก:ไม่รอ(คืนคิว)\nCancel : Return Queue',
    },
    {'reason_id': 4, 'reason_note': 'ยกเลิก : ไม่กลับมา\nCancel : Absent'},
    {'reason_id': 5, 'reason_note': 'ยกเลิก : ออกคิวผิด\nCancel : Wrong Queue'},
    {'reason_id': '', 'reason_note': 'ปิดหน้าต่าง\nClose'},
  ];

  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    ModelsServiceQueueBinding item,
    String statustabs,
  ) {
    final filteredReasons = (statustabs == "3")
        ? reasons.where((r) => r['reason_id'] != 0).toList()
        : reasons;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Queue Number",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "${item.callerQueueNo}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...List.generate(filteredReasons.length, (index) {
                final reason = filteredReasons[index];
                final reasonId = reason['reason_id'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(reason);

                        if (reasonId == 0) {
                          context.read<ProviderQueue>().updateQueue(
                            service: item,
                            statusQueue: 'Holding',
                            statusQueueNote: '',
                          );
                        } else if (reasonId != '') {
                          var ReasonNote = (reasonId == 1)
                              ? 'Finishing'
                              : 'Ending';
                          context.read<ProviderQueue>().updateQueue(
                            service: item,
                            statusQueue: ReasonNote,
                            statusQueueNote: reasonId.toString(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: reasonId == ''
                            ? const Color.fromARGB(255, 255, 0, 0)
                            : reasonId == 0
                            ? const Color(0xFFF1C40F)
                            : reasonId == 1
                            ? const Color.fromARGB(255, 24, 177, 4)
                            : const Color.fromARGB(255, 219, 118, 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      child: Text(
                        reason['reason_note'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
