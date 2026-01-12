import 'dart:convert';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import '../../Models/ModelsBranchSearch.dart';
import '../ApiConfig.dart';

Future<List<Modelsbranchsearch>> ActionBranchsearch({
  required BuildContext context,
  required dynamic branchid,
}) async {
  final uri = Uri.parse(
    ApiConfig.BranchSearch(context),
  ).replace(queryParameters: {'bid': branchid.toString()});

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

    return list.map((e) => Modelsbranchsearch.fromJson(e)).toList();
  } catch (e) {
    print('BranchSearch error: $e');
    return [];
  }
}
