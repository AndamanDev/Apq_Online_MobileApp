import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ClassToast {
  static void success(
    String message, {
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: alignment,
      title: const Text('สำเร็จ'),
      description: Text(message),
      icon: const Icon(Icons.check_circle),
      showIcon: true,
      primaryColor: Colors.green,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: false,
    );
  }

  static void error(
    String message, {
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: alignment,
      title: const Text('เกิดข้อผิดพลาด'),
      description: Text(message),
      icon: const Icon(Icons.error_outline),
      showIcon: true,
      primaryColor: Colors.red,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: false,
    );
  }

  static void info(
    String message, {
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: alignment,
      title: const Text('แจ้งเตือน'),
      description: Text(message),
      icon: const Icon(Icons.info_outline),
      showIcon: true,
      primaryColor: Colors.blue,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
