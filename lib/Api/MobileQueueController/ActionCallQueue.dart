import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Class/ClassSocket.dart';
import '../../Models/ModelsServiceQueueBinding.dart';
import '../ApiConfig.dart';

class ActionCallQueue {
  final BuildContext context;
  final ModelsServiceQueueBinding serviceDetail;

  ActionCallQueue({required this.context, required this.serviceDetail});

  Future<void> CallQueue() async {
    final uri = Uri.parse(ApiConfig.callQueue(context));

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

    debugPrint("BODY:");
    debugPrint(const JsonEncoder.withIndent('  ').convert(body));

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      //   debugPrint("======= CALL QUEUE RESPONSE =======");
      //   debugPrint("STATUS CODE: ${response.statusCode}");
      //   debugPrint("RAW BODY:");
      //   debugPrint(response.body);

      final json = jsonDecode(response.body);

      //   debugPrint("PARSED JSON:");
      //   debugPrint(const JsonEncoder.withIndent('  ').convert(json));

      if (response.statusCode != 200 || json['success'] != true) {
        throw Exception(json['message'] ?? 'Call queue error');
      }

      final int callerId = json['data']['data']['caller']['caller_id'];

      debugPrint("CALLER ID: $callerId");

      await ClassSocket().callQueue(serviceDetail, callerId);

      // debugPrint("Socket callQueue sent successfully");
    } catch (e, stack) {
      debugPrint("======= CALL QUEUE ERROR =======");
      debugPrint(e.toString());
      debugPrint(stack.toString());
      rethrow;
    }
  }
}
