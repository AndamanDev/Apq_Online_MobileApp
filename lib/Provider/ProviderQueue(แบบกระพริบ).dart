import 'package:apq_m1/Api/MobileQueueController/ActionCallQueue.dart';
import 'package:apq_m1/Api/MobileQueueController/ActionClearQueue.dart';
import 'package:apq_m1/Api/MobileQueueController/ActionUpdateQueue.dart';
import 'package:flutter/material.dart';
import '../Api/MobileQueueController/ActionCreateQueue.dart';
import '../Api/MobileQueueController/ActionQueueBinding.dart';
import '../Api/MobileQueueController/ActionServiceQueueBinding.dart';
import '../Class/ClassSocket.dart';
import '../Class/ClassToast.dart';
import '../Models/ModelsQueueBinding.dart';
import '../Models/ModelsServiceQueueBinding.dart';
import '../Models/ModeslQueueWithService.dart';

class ProviderQueue extends ChangeNotifier {
  final int branchId;
  ProviderQueue(this.branchId);

  List<ModelsServiceQueueBinding> serviceList = [];
  List<ModelsQueueBinding> waitingQueueList = [];
  List<ModelsQueueBinding> callingQueueList = [];
  List<ModelsQueueBinding> holdingQueueList = [];
  List<ModelsQueueBinding> allingQueueList = [];

  List<QueueWithService> waitingQueues = [];
  List<QueueWithService> callingQueues = [];
  List<QueueWithService> holdingQueues = [];

  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;

    serviceList = [];
    waitingQueueList = [];
    callingQueueList = [];
    holdingQueueList = [];
    allingQueueList = [];

    notifyListeners();

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

      final serviceMap = {for (var s in serviceList) s.serviceId: s};

      waitingQueues = waitingQueueList
          .where((q) => serviceMap.containsKey(q.serviceId))
          .map(
            (q) =>
                QueueWithService(queue: q, service: serviceMap[q.serviceId]!),
          )
          .toList();

      callingQueues = callingQueueList
          .where((q) => serviceMap.containsKey(q.serviceId))
          .map(
            (q) =>
                QueueWithService(queue: q, service: serviceMap[q.serviceId]!),
          )
          .toList();

      holdingQueues = holdingQueueList
          .where((q) => serviceMap.containsKey(q.serviceId))
          .map(
            (q) =>
                QueueWithService(queue: q, service: serviceMap[q.serviceId]!),
          )
          .toList();
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> createQueue({
    required BuildContext context,
    required int pax,
    required ModelsServiceQueueBinding service,
  }) async {
    try {
      loading = true;
      notifyListeners();

      await ActionCreateQueue(pax: pax, serviceDetail: service).CreateQueue();

      await load();

      // await ClassSocket().createQueue(service);
      ClassToast.success("สร้างคิว  สำเร็จ");
    } catch (e) {
      error = e.toString();
      ClassToast.success("สร้างคิว  ล้มเหลว ${error}");
      print("สร้างคิว  ล้มเหลว ${error}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> clearQueue({
    required BuildContext context,
    required int branchid,
  }) async {
    try {
      loading = true;
      notifyListeners();

      await ActionClearqueue(branchId: branchid);
      await load();
    } catch (e) {
      final msg = e.toString().replaceAll("Exception:", "").trim();
      ClassToast.error(msg);
      print("Exception: ${msg}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> callQueue({required ModelsServiceQueueBinding service}) async {
    try {
      loading = true;
      notifyListeners();

      await ActionCallQueue(serviceDetail: service).CallQueue();

      await load();

      ClassToast.success("เรียกคิว ${service.nextQueueNo ?? ''} สำเร็จ");
      print("เรียกคิว ${service.nextQueueNo ?? ''} สำเร็จ");
    } catch (e) {
      final msg = e.toString().replaceAll("Exception:", "").trim();
      ClassToast.error(msg);
      print("Exception: ${msg}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateQueue({
    required ModelsServiceQueueBinding service,
    required String statusQueue,
    required String statusQueueNote,
  }) async {
    try {
      loading = true;
      notifyListeners();

      await ActionUpdateQueue(
        service: service,
        statusQueue: statusQueue,
        statusQueueNote: statusQueueNote,
      ).updateQueue();

      await load();

      await ClassSocket().updateQueue(service, statusQueue, statusQueueNote);
      ClassToast.success("อัพเดตคิว ${service.callerQueueNo ?? ''} สำเร็จ");
      print("อัพเดตคิว ${service.callerQueueNo ?? ''} สำเร็จ");
    } catch (e) {
      final msg = e.toString().replaceAll("Exception:", "").trim();
      ClassToast.error(msg);
      print("Exception: ${msg}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
