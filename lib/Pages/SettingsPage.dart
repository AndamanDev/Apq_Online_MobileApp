import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text("Printer Settings")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Settingprinter(),
        ],
      ),
    );
  }
}
