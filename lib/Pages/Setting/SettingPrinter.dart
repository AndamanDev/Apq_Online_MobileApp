import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class AppColors {
  static const white = Colors.white;
}

class Settingprinter extends StatefulWidget {
  const Settingprinter({super.key});

  @override
  State<Settingprinter> createState() => _SettingprinterState();
}

class _SettingprinterState extends State<Settingprinter> {
  // ===== Printer Status =====
  bool connected = false;
  String printerMessage = "";
  bool _progress = false;
  String _msjprogress = "";

  // ===== Paper Size =====
  String paperSize = "58 mm";
  List<String> paperOptions = ["58 mm", "80 mm"];

  // ===== Bluetooth Devices =====
  List<BluetoothInfo> devices = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // ================= INIT =================
  Future<void> initPlatformState() async {
    try {
      final bool enabled = await PrintBluetoothThermal.bluetoothEnabled;
      final bool status = await PrintBluetoothThermal.connectionStatus;

      setState(() {
        connected = status;
        printerMessage = enabled ? "Bluetooth ready" : "Bluetooth is disabled";
      });
    } catch (e) {
      printerMessage = "Bluetooth error";
    }
  }

  // ================= SEARCH =================
  Future<void> getBluetooths() async {
    await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
      _progress = true;
      _msjprogress = "Searching...";
      devices = [];
    });

    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      _progress = false;
      devices = listResult;
      printerMessage = listResult.isEmpty
          ? "No paired printer found"
          : "Tap printer to connect";
    });
  }

  // ================= CONNECT =================
  Future<void> connect(String mac) async {
    setState(() {
      _progress = true;
      _msjprogress = "Connecting...";
      connected = false;
    });

    final bool result = await PrintBluetoothThermal.connect(
      macPrinterAddress: mac,
    );

    setState(() {
      connected = result;
      _progress = false;
      printerMessage = result ? "Connected" : "Connection failed";
    });
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
      printerMessage = "Disconnected";
    });
  }

  // ================= PRINT =================
  Future<void> printTest() async {
    bool status = await PrintBluetoothThermal.connectionStatus;
    if (!status) {
      setState(() => printerMessage = "Printer not connected");
      return;
    }

    List<int> ticket = await testTicket();
    await PrintBluetoothThermal.writeBytes(ticket);
  }

  // ================= ESC POS TEST TICKET =================
  Future<List<int>> testTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paperSize == "58 mm" ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];
    bytes += generator.text(
      "QUEUE SYSTEM",
      styles: const PosStyles(
        bold: true,
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.hr();
    bytes += generator.text(
      "Printer test successful",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    return bytes;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      children: [
        ExpansionTile(
          leading: Icon(
            Icons.print,
            color: connected ? Colors.green : Colors.red,
          ),
          title: const Text("Printer Settings"),
          childrenPadding: const EdgeInsets.all(12),
          children: [
            // Printer Status Card
            Card(
              color: connected ? Colors.green : Colors.red,
              child: ListTile(
                leading: Icon(
                  connected ? Icons.print : Icons.print_disabled,
                  color: AppColors.white,
                ),
                title: Text(
                  connected ? "Printer Connected" : "No Printer Connected",
                  style: const TextStyle(color: AppColors.white),
                ),
                subtitle: Text(
                  printerMessage,
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: getBluetooths,
                    child: Text(_progress ? _msjprogress : "Search"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: connected ? disconnect : null,
                    child: const Text("Disconnect"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: connected ? printTest : null,
                    child: const Text("Test"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Paper Size Dropdown
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButton<String>(
                value: paperSize,
                isExpanded: true,
                items: paperOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => paperSize = v!),
              ),
            ),

            const SizedBox(height: 10),

            // Paired Printers List
            devices.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "No printers found",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : Column(
                    children: devices.map((d) {
                      return ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(d.name),
                        subtitle: Text(d.macAdress),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => connect(d.macAdress),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ],
    );
  }
}
