import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ClassDialog {
  static Future<void> success(
    BuildContext context,
    String message, {
    VoidCallback? onOk,
  }) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: false,
      body: _dialogBody(
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green,
        title: 'สำเร็จ',
        message: message,
      ),
      btnOkText: 'ตกลง',
      btnOkColor: Colors.green,
      btnOkOnPress: () {
        onOk?.call();
      },
    ).show();
  }

  static Future<void> error(
    BuildContext context,
    String message,
  ) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: false,
      body: _dialogBody(
        icon: Icons.error_rounded,
        iconColor: Colors.red,
        title: 'เกิดข้อผิดพลาด',
        message: message,
      ),
      btnOkText: 'ปิด',
      btnOkColor: Colors.red,
      btnOkOnPress: () {},
    ).show();
  }

  /// reusable body
  static Widget _dialogBody({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 72),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
