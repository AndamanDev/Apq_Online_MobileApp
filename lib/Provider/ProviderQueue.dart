import 'package:flutter/material.dart';

import '../Api/MobileQueueController/ActionCallQueue.dart';
import '../Api/MobileQueueController/ActionClearQueue.dart';
import '../Api/MobileQueueController/ActionCreateQueue.dart';
import '../Api/MobileQueueController/ActionQueueBinding.dart';
import '../Api/MobileQueueController/ActionServiceQueueBinding.dart';
import '../Api/MobileQueueController/ActionUpdateQueue.dart';
import '../Api/MobileQueueController/ActionUpdateQueueTabsHold.dart';
import '../Class/ClassSocket.dart';
import '../Class/ClassToast.dart';
import '../Models/ModelsQueueBinding.dart';
import '../Models/ModelsServiceQueueBinding.dart';
import '../Models/ModeslQueueWithService.dart';

class ProviderQueue extends ChangeNotifier {
  final int branchId;
  ProviderQueue(this.branchId);

  /// ================= DATA =================
  List<ModelsServiceQueueBinding> serviceList = [];

  List<ModelsQueueBinding> waitingQueueList = [];
  List<ModelsQueueBinding> callingQueueList = [];
  List<ModelsQueueBinding> holdingQueueList = [];
  List<ModelsQueueBinding> allingQueueList = [];

  List<QueueWithService> waitingQueues = [];
  List<QueueWithService> callingQueues = [];
  List<QueueWithService> holdingQueues = [];
  List<QueueWithService> allingQueues = [];

  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;

    try {
      final results = await Future.wait([
        ActionServiceQueueBinding(branchId: branchId),
        ActionQueueBinding(branchId: branchId, type: 1),
        ActionQueueBinding(branchId: branchId, type: 2),
        ActionQueueBinding(branchId: branchId, type: 3),
        ActionQueueBinding(branchId: branchId, type: 0),
      ]);

      serviceList = results[0] as List<ModelsServiceQueueBinding>;
      waitingQueueList = results[1] as List<ModelsQueueBinding>;
      callingQueueList = results[2] as List<ModelsQueueBinding>;
      holdingQueueList = results[3] as List<ModelsQueueBinding>;
      allingQueueList = results[4] as List<ModelsQueueBinding>;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> loadQueuesOnly() async {
    try {
      final results = await Future.wait([
        ActionQueueBinding(branchId: branchId, type: 1),
        ActionQueueBinding(branchId: branchId, type: 2),
        ActionQueueBinding(branchId: branchId, type: 3),
        ActionQueueBinding(branchId: branchId, type: 0),
      ]);

      waitingQueueList = results[0] as List<ModelsQueueBinding>;
      callingQueueList = results[1] as List<ModelsQueueBinding>;
      holdingQueueList = results[2] as List<ModelsQueueBinding>;
      allingQueueList = results[3] as List<ModelsQueueBinding>;

      notifyListeners();
    } catch (_) {}
  }

  /// ================= UPDATE SERVICE เฉพาะจุด =================
  void _updateService(ModelsServiceQueueBinding service) {
    final index = serviceList.indexWhere(
      (e) => e.serviceId == service.serviceId,
    );
    if (index == -1) return;

    serviceList[index] = service;
    notifyListeners();
  }

  /// ================= CREATE QUEUE (ไม่ rebuild ทั้งหน้า) =================
  Future<void> createQueue({
    required int pax,
    required ModelsServiceQueueBinding service,
  }) async {
    try {
      await ActionCreateQueue(pax: pax, serviceDetail: service).CreateQueue();

      final services = await ActionServiceQueueBinding(branchId: branchId);
      final updated = services.firstWhere(
        (s) => s.serviceId == service.serviceId,
      );

      _updateService(updated);
      ClassToast.success("สร้างคิวสำเร็จ");
      await loadQueuesOnly();
      await ClassSocket().createQueue(service);
    } catch (e) {
      ClassToast.error("สร้างคิวล้มเหลว");
    }
  }

  /// ================= CALL QUEUE =================
  Future<void> callQueue({required ModelsServiceQueueBinding service}) async {
    try {
      await ActionCallQueue(serviceDetail: service).CallQueue();

      final services = await ActionServiceQueueBinding(branchId: branchId);
      final updated = services.firstWhere(
        (s) => s.serviceId == service.serviceId,
      );

      _updateService(updated);
      ClassToast.success("เรียกคิว ${updated.nextQueueNo ?? ''} สำเร็จ");
      await loadQueuesOnly();
    } catch (e) {
      if (e.toString() == "Exception: มีรายการคิวที่ถูกเรียกอยู่") {
        ClassToast.error("เรียกคิวไม่สำเร็จ ${e.toString()}");
        await load();
      } else {
        ClassToast.error("เรียกคิวไม่สำเร็จ เนื่องจากไม่มีคิวรอเรียก");
        await load();
      }
    }
  }

  /// ================= UPDATE QUEUE STATUS =================
  Future<void> updateQueue({
    required ModelsServiceQueueBinding service,
    required String statusQueue,
    required String statusQueueNote,
  }) async {
    try {

        await ActionUpdateQueueTabsHold(
        service: service,
        statusQueue: statusQueue,
        statusQueueNote: statusQueueNote,
      ).updateQueue();

      // await ActionUpdateQueue(
      //   service: service,
      //   statusQueue: statusQueue,
      //   statusQueueNote: statusQueueNote,
      // ).updateQueue();

      final services = await ActionServiceQueueBinding(branchId: branchId);
      final updated = services.firstWhere(
        (s) => s.serviceId == service.serviceId,
      );
      _updateService(updated);
      ClassToast.success("อัพเดตคิว ${updated.callerQueueNo ?? ''} สำเร็จ");
      await loadQueuesOnly();
      // await ClassSocket().updateQueue(updated, statusQueue, statusQueueNote);
    } catch (e) {
      ClassToast.error("อัพเดตคิวล้มเหลว");
    }
  }

  /// ================= CLEAR QUEUE (ยอม reload ได้) =================
  Future<void> clearQueue({required int branchid}) async {
    try {
      await ActionClearqueue(branchId: branchid);

      waitingQueueList = [];
      callingQueueList = [];
      holdingQueueList = [];
      allingQueueList = [];

      serviceList = serviceList.map((s) {
        return s.copyWith(
          qWait: 0,
          nextQueueNo: '',
          nextQueueNoNumberPax: 0,
          callerQueueNo: null,
          isInCaller: false,
          callerQueueNoNumberPax: 0,
        );
      }).toList();
      ClassToast.success("ล้างคิวทั้งหมดสำเร็จ");
      notifyListeners();
      await load();
    } catch (e) {
      ClassToast.error("ล้างคิวล้มเหลว");
    }
  }
}
