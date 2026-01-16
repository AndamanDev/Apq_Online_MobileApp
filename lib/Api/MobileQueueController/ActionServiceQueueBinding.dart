import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/ModelsServiceQueueBinding.dart';
import '../ApiConfig.dart';

Future<List<ModelsServiceQueueBinding>> ActionServiceQueueBinding({
  required int branchId,
}) async {
  final uri = Uri.parse(
    ApiConfig.serviceBinding,
  ).replace(queryParameters: {'bid': branchId.toString()});

  try {
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return [];
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (json['success'] != true) {
      return [];
    }

    final List list = json['data'];

    if (list.isEmpty) {
      return [];
    }

    return list.map((e) => ModelsServiceQueueBinding.fromJson(e)).toList();
  } catch (e) {
    print('ServiceQueueBinding error: $e');
    return [];
  }
}
