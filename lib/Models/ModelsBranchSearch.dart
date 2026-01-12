import '../Class/ClassJsonHelper.dart';

class Modelsbranchsearch {
  final int branchId;
  final String branchName;
  final int branchStatus;
  final String branchPhone;
  final String picturePath;
  final String pictureBaseUrl;
  final String branchEndDate;

  Modelsbranchsearch({
    required this.branchId,
    required this.branchName,
    required this.branchStatus,
    required this.branchPhone,
    required this.picturePath,
    required this.pictureBaseUrl,
    required this.branchEndDate,
  });

  factory Modelsbranchsearch.fromJson(Map<String, dynamic> json) {
    return Modelsbranchsearch(
      branchId: JsonHelper.toInt(json['branch_id']),
      branchName: JsonHelper.toStringValue(json['branch_name']),
      branchStatus: JsonHelper.toInt(json['branch_status']),
      branchPhone: JsonHelper.toStringValue(json['branch_phone']),
      picturePath: JsonHelper.toStringValue(json['picture_path']),
      pictureBaseUrl: JsonHelper.toStringValue(json['picture_base_url']),
      branchEndDate: JsonHelper.toStringValue(json['branch_end_date']),
    );
  }
}
