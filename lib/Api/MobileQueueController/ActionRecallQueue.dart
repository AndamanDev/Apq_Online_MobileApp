import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/ModelsServiceQueueBinding.dart';
import '../ApiConfig.dart';

class ActionReCallQueue {
  final ModelsServiceQueueBinding serviceDetail;

  ActionReCallQueue({required this.serviceDetail});

  Future<void> CallQueue() async {
    final uri = Uri.parse(ApiConfig.recallQueue);

    final body = {
      'ServiceDetail': {
        'branch_id': serviceDetail.branchId,
        'service_group_id': serviceDetail.serviceGroupId,
        'branch_service_group_id': serviceDetail.branchServiceGroupId,
        'service_id': serviceDetail.serviceId,
        'prefix_code': serviceDetail.prefixCode,
      },
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('ReCall queue success');
      } else if (response.statusCode == 422) {
        String MessageResponse = "มีคิวกำลังใช้งานอยู่\nQueue";
      } else if (response.statusCode == 421) {
        String MessageResponse = "ไม่มีรายการคิว\nNot Queue";
      } else {}

      if (json['success'] != true) {
        throw Exception(json['message'] ?? 'ReCall queue error');
      }
    } catch (e) {
      print('ActionReCallQueue error: $e');
      rethrow;
    }
  }
}
