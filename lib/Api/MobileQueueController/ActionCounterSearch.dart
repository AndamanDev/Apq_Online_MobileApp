import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apq_m1/Models/ModelsCounterSearch.dart';
import '../ApiConfig.dart';
import 'package:flutter/material.dart';

Future<List<Modelscountersearch>> ActionCounterSearch({
  required BuildContext context,
  required dynamic branchid,
}) async {
  final uri = Uri.parse(
   ApiConfig.counterSearch(context),
  ).replace(queryParameters: {
    'bid': branchid.toString(),
  });

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

    return list
        .map((e) => Modelscountersearch.fromJson(e))
        .toList();
  } catch (e) {
    print('CounterSearch error: $e');
    return [];
  }
}
