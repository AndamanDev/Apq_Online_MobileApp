import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/ModelsServiceQueueBinding.dart';
import '../ApiConfig.dart';

class ActionUpdateQueue {
  final ModelsServiceQueueBinding service;
  final String statusQueue;
  final String statusQueueNote;

  ActionUpdateQueue({
    required this.service,
    required this.statusQueue,
    required this.statusQueueNote,
  });

  Future<Map<String, dynamic>> updateQueue() async {
    final uri = Uri.parse(ApiConfig.updateQueue);

    final body = {
      'SearchQueue': [
        {
          'caller_id': (service.callerId == null || service.callerId == 0)
              ? null
              : service.callerId,
          'queue_id': service.queueId,
        },
      ],
      'StatusQueue': jsonEncode(statusQueue),
      'StatusQueueNote': jsonEncode(statusQueueNote),
    };

 try {
      /// ===== REQUEST DEBUG =====
      debugPrint('========== UPDATE QUEUE REQUEST ==========');
      debugPrint('URL: $uri');
      debugPrint('METHOD: POST');
      debugPrint('HEADERS: {Content-Type: application/json}');
      debugPrint('BODY (Map): $body');
      debugPrint('BODY (JSON): ${jsonEncode(body)}');
      debugPrint('StatusQueue type: ${statusQueue.runtimeType}');
      debugPrint('StatusQueueNote type: ${statusQueueNote.runtimeType}');
      debugPrint('caller_id: ${service.callerId}');
      debugPrint('queue_id: ${service.queueId}');
      debugPrint('queue_no: ${service.queueNo}');
      debugPrint('caller_id: ${service.callerId}');
      debugPrint('==========================================');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      /// ===== RESPONSE DEBUG =====
      debugPrint('========== UPDATE QUEUE RESPONSE ==========');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RAW BODY: ${response.body}');
      debugPrint('BODY TYPE: ${response.body.runtimeType}');
      debugPrint('==========================================');

      final decoded = jsonDecode(response.body);

      /// ===== DECODE DEBUG =====
      debugPrint('========== DECODED JSON ==========');
      debugPrint(decoded.toString());
      debugPrint('Decoded type: ${decoded.runtimeType}');
      debugPrint('success: ${decoded['success']}');
      debugPrint('message: ${decoded['message']}');
      debugPrint('message type: ${decoded['message']?.runtimeType}');
      debugPrint('=================================');

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Update queue error');
      }

      return decoded;
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
