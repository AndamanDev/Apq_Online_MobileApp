import 'package:apq_m1/Api/MobileQueueController/ActionCallQueue.dart';
import 'package:apq_m1/Api/MobileQueueController/ActionClearQueue.dart';
import 'package:apq_m1/Api/MobileQueueController/ActionUpdateQueue.dart';
import 'package:flutter/material.dart';

import '../Api/MobileQueueController/ActionCreateQueue.dart';
import '../Api/MobileQueueController/ActionQueueBinding.dart';
import '../Api/MobileQueueController/ActionServiceQueueBinding.dart';
import '../Class/ClassSocket.dart';
import '../Models/ModelsQueueBinding.dart';
import '../Models/ModelsServiceQueueBinding.dart';
import '../Models/ModeslQueueWithService.dart';

class ProviderQueue extends ChangeNotifier {
  final BuildContext context;
  final int branchId;

  ProviderQueue(this.context, this.branchId);

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
        ActionServiceQueueBinding(context: context, branchId: branchId),
        ActionQueueBinding(context: context, branchId: branchId, type: 1),
        ActionQueueBinding(context: context, branchId: branchId, type: 2),
        ActionQueueBinding(context: context, branchId: branchId, type: 3),
        ActionQueueBinding(context: context, branchId: branchId, type: 0),
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

      await ActionCreateQueue(
        context: context,
        pax: pax,
        serviceDetail: service,
      ).CreateQueue();

      await load();

      await ClassSocket().createQueue(service);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> clearQueue({
    required BuildContext context,
    required int branchid
  }) async {
    try {
      loading = true;
      notifyListeners();

      await ActionClearqueue(
        context: context, branchId: branchid,
      );
      await load();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> callQueue({
    required ModelsServiceQueueBinding service,
    required BuildContext context,
  }) async {
    try {
      loading = true;
      notifyListeners();
      await ActionCallQueue(
        context: context,
        serviceDetail: service,
      ).CallQueue();

      await load();
    } catch (e) {
      error = e.toString();
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
        context: context,
        service: service,
        statusQueue: statusQueue,
        statusQueueNote: statusQueueNote,
      ).updateQueue();

      await load();

      await ClassSocket().updateQueue(service, statusQueue, statusQueueNote);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
