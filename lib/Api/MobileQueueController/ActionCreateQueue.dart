import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Class/ClassSocket.dart';
import '../../Models/ModelsServiceQueueBinding.dart';
import '../ApiConfig.dart';

class ActionCreateQueue {
  final BuildContext context;
  final int pax;
  final ModelsServiceQueueBinding serviceDetail;

  ActionCreateQueue({
    required this.context,
    required this.pax,
    required this.serviceDetail,
  });

  Future<void> CreateQueue() async {
    final uri = Uri.parse(ApiConfig.createQueue(context),);

    final body = {
      'Pax': pax,
      'Customername': '',
      'Customerphone': '',
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
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Create queue failed');
      }

      final json = jsonDecode(response.body);

      if (json['success'] != true) {
        throw Exception(json['message'] ?? 'Create queue error');
      }

    } catch (e) {
      print('ActionCreateQueue error: $e');
      rethrow;
    }
  }
}
