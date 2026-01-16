import 'package:apq_m1/Class/ClassObject.dart';
import 'package:apq_m1/Pages/Setting/SettingNode.dart';
import 'package:apq_m1/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/ProviderAuth.dart';
import '../Provider/ProviderLanguage.dart';
import '../localization/app_localizations.dart';
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
    final currentLang = context.watch<ProviderLanguage>().locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// 🔤 ปุ่มเปลี่ยนภาษา (อยู่บน)
            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: currentLang == 'en'
            //               ? Colors.blue
            //               : Colors.grey[300],
            //           foregroundColor: currentLang == 'en'
            //               ? Colors.white
            //               : Colors.black,
            //         ),
            //         onPressed: () {
            //           context.read<ProviderLanguage>().changeLanguage('en');
            //         },
            //         child: const Text('English'),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: currentLang == 'th'
            //               ? Colors.blue
            //               : Colors.grey[300],
            //           foregroundColor: currentLang == 'th'
            //               ? Colors.white
            //               : Colors.black,
            //         ),
            //         onPressed: () {
            //           context.read<ProviderLanguage>().changeLanguage('th');
            //         },
            //         child: const Text('ไทย'),
            //       ),
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 16),

            /// 📜 เนื้อหาที่เลื่อน
            Expanded(
              child: ListView(
                children: const [Settingprinter(), Settingnode()],
              ),
            ),

            const SizedBox(height: 24),

            /// 🔴 Logout
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
                      title: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 28,
                      ),
                      content: const Text(
                        'Do you want to log out??\n'
                        'You will need to log in again.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
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
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                AppLocalizations.of(context).translate('Logout'),
                style: const TextStyle(fontWeight: FontWeight.bold , color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
