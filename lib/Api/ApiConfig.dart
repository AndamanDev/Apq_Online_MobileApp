import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/ProviderAuth.dart';

class ApiConfig {
  // =========================
  // Domain จาก Provider
  // =========================
  static String domain(BuildContext context) {
    final d = context.read<ProviderAuth>().domain;
    if (d == null || d.isEmpty) {
      throw Exception("Domain is null (user not logged in)");
    }
    return d;
  }

  // =========================
  // Base URL
  // =========================
  static String baseUrl(BuildContext context) {
    return 'https://${domain(context)}';
  }

  // =========================
  // Endpoints
  // =========================
  static String counterSearch(BuildContext context) {
    return '${baseUrl(context)}/api/v1/mobile-queue/counter-search';
  }

  static String BranchSearch(BuildContext context) {
    return '${baseUrl(context)}/api/v1/mobile-queue/branch-search';
  }

 static String callQueue(BuildContext context) {
    return '${baseUrl(context)}/api/v1/queue-mobile/call-queue';
  }

   static String updateQueue(BuildContext context) {
    return '${baseUrl(context)}/api/v1/queue-mobile/update-queue';
  }

   static String recallQueue(BuildContext context) {
    return '${baseUrl(context)}/api/v1/mobile-queue/recall-queue';
  }
  static String createQueue(BuildContext context) {
    return '${baseUrl(context)}/api/v1/mobile-queue/create-queue';
  }

  static String queueBinding(BuildContext context) {
    return '${baseUrl(context)}/api/v1/mobile-queue/queue-binding';
  }
 static String claerQueue(BuildContext context) {
    return '${baseUrl(context)}/api/v1/queue-mobile/mid-night';
  }
    static String servicequeueBinding(BuildContext context) {
    return '${baseUrl(context)}/api/v1/mobile-queue/service-queue-binding';
  }
}
