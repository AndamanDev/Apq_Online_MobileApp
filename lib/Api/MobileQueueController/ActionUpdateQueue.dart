import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../Models/ModelsServiceQueueBinding.dart';
import '../ApiConfig.dart';

class ActionUpdateQueue {
  final BuildContext context;
  final ModelsServiceQueueBinding service;
  final String statusQueue;
  final String statusQueueNote;

  ActionUpdateQueue({
    required this.context,
    required this.service,
    required this.statusQueue,
    required this.statusQueueNote,
  });

  Future<Map<String, dynamic>> updateQueue() async {
    final uri = Uri.parse(ApiConfig.updateQueue(context));

    final body = {
      'SearchQueue': [
        {'caller_id': service.callerId, 'queue_id': service.queueId},
      ],
      'StatusQueue': jsonEncode(statusQueue),
      'StatusQueueNote': jsonEncode(statusQueueNote),
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode != 200 || json['success'] != true) {
      throw Exception(json['message'] ?? 'Update queue error');
    }

    return json;
  }
}
