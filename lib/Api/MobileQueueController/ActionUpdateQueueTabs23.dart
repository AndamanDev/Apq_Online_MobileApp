import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/ModelsServiceQueueBinding.dart';
import '../ApiConfig.dart';

class ActionUpdateQueueTabs23 {
  final ModelsServiceQueueBinding service;
  final String statusQueue;
  final String statusQueueNote;
  final String statustabs;
  final int? callerme;

  ActionUpdateQueueTabs23({
    required this.service,
    required this.statusQueue,
    required this.statusQueueNote,
    required this.statustabs,
    required this.callerme,
  });
  Future<Map<String, dynamic>?> updateQueue() async {
    final uri = Uri.parse(ApiConfig.updateQueue);

    final body = {
      'SearchQueue': [
        {
          // 'caller_id': statustabs == "2"
          //     ? null
          //     : statustabs == "3"
          //     ? (service.callerId == null || service.callerId == 0
          //           ? null
          //           : callerme)
          //     : service.callerId,
          'caller_id': statustabs == "2"
            ? null
            : statustabs == "3"
                ? (statusQueue == 'Calling'
                    ? callerme
                    : ((service.callerId == 0 || service.callerId == null ) ? null : service.callerId))
                : service.callerId,
          'queue_id': service.queueId,
        },
      ],
      'StatusQueue': jsonEncode(statusQueue),
      'StatusQueueNote': jsonEncode(statusQueueNote),
    };

    try {
      // ================= INPUT =================
      debugPrint('========== UPDATE QUEUE INPUT ==========');
      debugPrint('service.queueId      : ${service.queueId}');
      debugPrint('service.callerId     : ${service.callerId}');
      debugPrint('callerme             : $callerme');
      debugPrint('statustabs           : $statustabs');
      debugPrint('statusQueue          : $statusQueue');
      debugPrint('statusQueueNote      : $statusQueueNote');

      // ================= REQUEST =================
      debugPrint('========== UPDATE QUEUE REQUEST ==========');
      debugPrint('URL: $uri');
      debugPrint('Headers: {Content-Type: application/json}');
      debugPrint('Body:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(body));

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // ================= RESPONSE =================
      debugPrint('========== UPDATE QUEUE RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Raw Body:');
      debugPrint(response.body);

      final decoded = jsonDecode(response.body);

      // ================= PARSED JSON =================
      debugPrint('========== PARSED JSON ==========');
      debugPrint(const JsonEncoder.withIndent('  ').convert(decoded));

      // ================= CHECK RESULT =================
      debugPrint('success   : ${decoded['success']}');
      debugPrint('statuscode: ${decoded['statuscode']}');
      debugPrint('message   : ${decoded['message']}');

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Update queue error');
      }

      return decoded;
      // return null;
    } catch (e, stack) {
      debugPrint('======= UPDATE QUEUE ERROR =======');
      debugPrint('ERROR: $e');
      debugPrint('ERROR TYPE: ${e.runtimeType}');
      debugPrint('STACK TRACE:\n$stack');
      debugPrint('=================================');
      rethrow;
    }
  }
}
