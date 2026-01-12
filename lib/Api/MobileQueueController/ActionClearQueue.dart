import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';

Future<void> ActionClearqueue({
  required BuildContext context,
  required int branchId,
}) async {
  final uri = Uri.parse(
    ApiConfig.claerQueue(context),
  ).replace(queryParameters: {'branchid': branchId.toString()});

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
    
    } else {
   
    }
  } catch (e) {
    print(e);
  }
}
