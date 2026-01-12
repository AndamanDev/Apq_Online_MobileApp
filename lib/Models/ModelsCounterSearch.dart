import '../Class/ClassJsonHelper.dart';

class Modelscountersearch {
  final int kioskId;
  final String kioskName;
  final String kioskLabel;
  final String kioskStatus;

  Modelscountersearch({
    required this.kioskId,
    required this.kioskName,
    required this.kioskLabel,
    required this.kioskStatus,
  });

  factory Modelscountersearch.fromJson(Map<String, dynamic> json) {
    return Modelscountersearch(
      kioskId: JsonHelper.toInt(json['t_kiosk_id']),
      kioskName: JsonHelper.toStringValue(json['t_kiosk_name']),
      kioskLabel: JsonHelper.toStringValue(json['t_kiosk_label']),
      kioskStatus: JsonHelper.toStringValue(json['t_kiosk_status']),
    );
  }
}
