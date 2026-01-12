import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Models/ModelsLoginResult.dart';

Future<Modelsloginresult> ActionLogin({
  required String domain,
  required String username,
  required String password,
}) async {
  final uri = Uri.parse(
    'https://$domain/api/v1/mobile-queue/login',
  ).replace(queryParameters: {'u': username, 'p': password});

  try {
    final response = await http.get(uri);

    // server error
    if (response.statusCode != 200) {
      return Modelsloginresult(
        success: false,
        message: 'Username หรือ Password ไม่ถูกต้อง',
      );
    }

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      return Modelsloginresult(success: true, message: 'เข้าสู่ระบบได้' , data: data['data']);
    }

    return Modelsloginresult(
      success: false,
      message: 'Username หรือ Password ไม่ถูกต้อง',
    );
  } catch (e) {
    return Modelsloginresult(success: false, message: 'เกิดข้อผิดพลาด: $e');
  }
}
