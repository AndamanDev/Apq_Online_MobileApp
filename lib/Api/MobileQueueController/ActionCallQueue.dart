import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Class/ClassSocket.dart';
import '../../Models/ModelsServiceQueueBinding.dart';
import '../ApiConfig.dart';

class ActionCallQueue {
  final ModelsServiceQueueBinding serviceDetail;

  ActionCallQueue({required this.serviceDetail});

  Future<void> CallQueue() async {
    final uri = Uri.parse(ApiConfig.callQueue);

    final body = {
      "SearchQueue": [
        {
          "queue_id": serviceDetail.queueId,
          "branch_service_group_id": serviceDetail.branchServiceGroupId,
        },
      ],
      'TicketKioskDetail': {
        'branch_service_group_id': serviceDetail.branchServiceGroupId,
        'queue_id': serviceDetail.queueId,
      },
      'Branch': {'branch_id': serviceDetail.branchId},
      'Kiosk': {'kiosk_id': serviceDetail.tKioskId},
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body);

      if (json['data']?['success'] != true) {
        throw Exception(json['data']?['message'] ?? 'ไม่สามารถเรียกคิวได้');
      }

      final int callerId = json['data']['data']['caller']['caller_id'];
      await ClassSocket().callQueue(serviceDetail, callerId);
    } catch (e, stack) {
      debugPrint("======= CALL QUEUE ERROR =======");
      debugPrint(e.toString());
      debugPrint(stack.toString());
      rethrow;
    }
  }
}
