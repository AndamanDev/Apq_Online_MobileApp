import '../Class/ClassJsonHelper.dart';
import 'ModelsQueueBinding.dart';

class ModelsServiceQueueBinding {
  final String? branchName;
  final int? tKioskId;
  final int? branchId;
  final String? tKioskName;

  final int? tKioskDetailId;
  final int? branchServiceGroupId;
  final int? tKioskBtnSeq;
  final String? tKioskBtnName;

  final int? serviceId;

  final int? serviceGroupId;
  final String? serviceGroupName;

  final int? prefixId;
  final String? prefixCode;

  final int? branchServiceId;

  final int? queueId;
  final String? queueNo;
  final String? queueDate;
  final int? qWait;

  final String? nextQueueNo;
  final int? nextQueueNoNumberPax;

  final int? callerQueueId;
  final int? callerId;
  final String? callerQueueNo;
  final bool isInCaller;

  ModelsServiceQueueBinding({
    this.branchName,
    this.tKioskId,
    this.branchId,
    this.tKioskName,
    this.tKioskDetailId,
    this.branchServiceGroupId,
    this.tKioskBtnSeq,
    this.tKioskBtnName,
    this.serviceGroupId,
    this.serviceId,
    this.serviceGroupName,
    this.prefixId,
    this.prefixCode,
    this.branchServiceId,
    this.queueId,
    this.queueNo,
    this.queueDate,
    this.qWait,
    this.nextQueueNo,
    this.nextQueueNoNumberPax,
    this.callerQueueId,
    this.callerId,
    this.callerQueueNo,
    required this.isInCaller,
  });

  factory ModelsServiceQueueBinding.fromJson(Map<String, dynamic> json) {
    return ModelsServiceQueueBinding(
      branchName: JsonHelper.toStringValue(json['branch_name']),
      tKioskId: JsonHelper.toInt(json['t_kiosk_id']),
      branchId: JsonHelper.toInt(json['branch_id']),
      tKioskName: JsonHelper.toStringValue(json['t_kiosk_name']),

      tKioskDetailId: JsonHelper.toInt(json['t_kiosk_detail_id']),
      branchServiceGroupId: JsonHelper.toInt(json['branch_service_group_id']),
      tKioskBtnSeq: JsonHelper.toInt(json['t_kiosk_btn_seq']),
      tKioskBtnName: JsonHelper.toStringValue(json['t_kiosk_btn_name']),

      serviceId: JsonHelper.toInt(json['service_id']),
      serviceGroupId: JsonHelper.toInt(json['service_group_id']),
      serviceGroupName: JsonHelper.toStringValue(json['service_group_name']),

      prefixId: JsonHelper.toInt(json['prefix_id']),
      prefixCode: JsonHelper.toStringValue(json['prefix_code']),

      branchServiceId: JsonHelper.toInt(json['branch_service_id']),

      queueId: JsonHelper.toInt(json['queue_id']),
      queueNo: JsonHelper.toStringValue(json['queue_no']),
      queueDate: JsonHelper.toStringValue(json['queue_date']),
      qWait: JsonHelper.toInt(json['q_wait']),

      nextQueueNo: JsonHelper.toStringValue(json['next_queue_no']),
      nextQueueNoNumberPax: JsonHelper.toInt(json['next_queue_no_number_pax']),

      callerQueueId: JsonHelper.toInt(json['caller_queue_id']),
      callerId: JsonHelper.toInt(json['caller_id']),
      callerQueueNo: JsonHelper.toStringValue(json['caller_queue_no']),
      isInCaller: JsonHelper.toBool(json['is_in_caller']),
    );
  }

  factory ModelsServiceQueueBinding.fromQueue(
    ModelsQueueBinding q,
    List<ModelsServiceQueueBinding> serviceList,
  ) {
    final service = serviceList.firstWhere((s) => s.serviceId == q.serviceId);

    return ModelsServiceQueueBinding(
      // ===== Branch / Kiosk =====
      branchName: service.branchName,
      tKioskId: service.tKioskId,
      branchId: service.branchId,
      tKioskName: service.tKioskName,
      tKioskDetailId: service.tKioskDetailId,
      branchServiceGroupId: service.branchServiceGroupId,
      tKioskBtnSeq: service.tKioskBtnSeq,
      tKioskBtnName: service.tKioskBtnName,

      // ===== Service =====
      serviceId: q.serviceId, // จาก queue
      serviceGroupId: service.serviceGroupId,
      serviceGroupName: service.serviceGroupName,

      // ===== Prefix =====
      prefixId: service.prefixId,
      prefixCode: service.prefixCode,

      // ===== Branch Service =====
      branchServiceId: service.branchServiceId,

      // ===== Queue =====
      queueId: q.queueId, // จาก queue
      queueNo: q.queueNo, // จาก queue
      queueDate: service.queueDate,
      qWait: service.qWait,

      // ===== Next Queue =====
      nextQueueNo: service.nextQueueNo,
      nextQueueNoNumberPax: service.nextQueueNoNumberPax,

      // ===== Caller =====
      callerQueueId: service.callerQueueId,
      callerId: service.callerId,
      callerQueueNo: service.callerQueueNo,

      // ===== Status =====
      isInCaller: true,
    );
  }
}
