import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../Class/ClassSocket.dart';
import '../../Class/ClassTicket.dart';
import '../../Class/ClassToast.dart';
import '../../Models/ModelsServiceQueueBinding.dart';
import '../ApiConfig.dart';

class ActionCreateQueue {
  final int pax;
  final ModelsServiceQueueBinding serviceDetail;

  ActionCreateQueue({required this.pax, required this.serviceDetail});

  Future<void> CreateQueue() async {
    final uri = Uri.parse(ApiConfig.createQueue);

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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Create queue failed');
      }

      final json = jsonDecode(response.body);

      if (json['success'] != true) {
        throw Exception(json['message'] ?? 'Create queue error');
      }

      bool status = await PrintBluetoothThermal.connectionStatus;
      ClassToast.success("กำลังออกบัตรคิว");
      if (status) {
        final ticket = await Classticket().printQueueTicket(json);
        await PrintBluetoothThermal.writeBytes(ticket);
      }
    } catch (e) {
      print('ActionCreateQueue error: $e');
      rethrow;
    }
  }
}


