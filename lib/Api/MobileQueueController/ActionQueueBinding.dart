import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/ModelsQueueBinding.dart';
import '../ApiConfig.dart';

Future<List<ModelsQueueBinding>> ActionQueueBinding({
  required int branchId,
  required int type,
}) async {
  final uri = Uri.parse(ApiConfig.queueBinding)
      .replace(
        queryParameters: {'bid': branchId.toString(), 'type': type.toString()},
      );

  try {
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return [];
    }

    final dynamic decoded = jsonDecode(response.body);

    List list;

    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        list = decoded['data'];
      } else {
        list = [decoded];
      }
    } else {
      return [];
    }
    
    return list.map((e) => ModelsQueueBinding.fromJson(e)).toList();
  } catch (e) {
    print('QueueBinding error: $e');
    return [];
  }
}
