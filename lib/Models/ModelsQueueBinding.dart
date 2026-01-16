import '../Class/ClassJsonHelper.dart';
import 'ModelsServiceQueueBinding.dart';

class ModelsQueueBinding {
  final int queueId;
  final String queueNo;
  final String servicestatusName;
  final int serviceId;
  final int numberPax;
  final DateTime? createAt;

  ModelsServiceQueueBinding? service;

  ModelsQueueBinding({
    required this.queueId,
    required this.queueNo,
    required this.servicestatusName,
    required this.serviceId,
    required this.numberPax,
    required this.createAt,
     this.service,
  });

  factory ModelsQueueBinding.fromJson(Map<String, dynamic> json) {
    return ModelsQueueBinding(
      queueId: JsonHelper.toInt(json['queue_id']) ?? 0,
      queueNo: JsonHelper.toStringValue(json['queue_no']) ?? '',
      servicestatusName: JsonHelper.toStringValue(json['service_status_name']) ?? '',
      serviceId: JsonHelper.toInt(json['service_id']) ?? 0,
      numberPax: JsonHelper.toInt(json['number_pax']) ?? 0,
      createAt: JsonHelper.parseDateTime(json['created_at'])!,
    );
  }
}
