import 'package:apq_m1/Class/ClassObject.dart';
import 'package:apq_m1/Pages/Setting/SettingNode.dart';
import 'package:apq_m1/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/ProviderAuth.dart';
import 'InitPage.dart';
import 'Setting/SettingPrinter.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // เนื้อหา scroll ได้
            Expanded(
              child: ListView(
                children: const [Settingprinter(), Settingnode()],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: const [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 28,
                          ),
                          // SizedBox(width: 8),
                          // Text(
                          //   'ยืนยันการออกจากระบบ',
                          //   style: TextStyle(fontWeight: FontWeight.bold),
                          // ),
                        ],
                      ),
                      content: const Text(
                        'คุณต้องการออกจากระบบใช่หรือไม่?\n\n'
                        'คุณจะต้องเข้าสู่ระบบใหม่อีกครั้ง',
                        style: TextStyle(fontSize: 15),
                      ),
                      actionsPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text(
                            'ยกเลิก',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'ออกจากระบบ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await context.read<ProviderAuth>().logout();
                  if (!mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const InitPage()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                padding: const EdgeInsets.all(12),
              ),
              child: const Text(
                "LOGOUT",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
