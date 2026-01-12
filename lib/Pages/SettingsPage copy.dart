import 'dart:io';
import 'package:apq_m1/Class/ClassObject.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _info = "";
  String _msj = "";
  bool connected = false;
  bool _progress = false;
  String _msjprogress = "";

  List<BluetoothInfo> items = [];

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];

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
        _msj = enabled
            ? "Bluetooth ready"
            : "Bluetooth is disabled";
      });
    } catch (e) {
      _msj = "Bluetooth error";
    }
  }

  // ================= SEARCH =================
  Future<void> getBluetoots() async {
    await PrintBluetoothThermal.disconnect;
    connected = false;

    setState(() {
      _progress = true;
      _msjprogress = "Searching...";
      items = [];
    });

    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      _progress = false;
      items = listResult;
      _msj = listResult.isEmpty
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

    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    setState(() {
      connected = result;
      _progress = false;
      _msj = result ? "Connected" : "Connection failed";
    });
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
      _msj = "Disconnected";
    });
  }

  // ================= PRINT =================
  Future<void> printTest() async {
    bool status = await PrintBluetoothThermal.connectionStatus;
    if (!status) {
      _msj = "Printer not connected";
      setState(() {});
      return;
    }

    List<int> ticket = await testTicket();
    await PrintBluetoothThermal.writeBytes(ticket);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Printer Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              color: connected
                  ? Colors.green
                  : Colors.red,
              child: ListTile(
                leading: Icon(
                  connected ? Icons.print : Icons.print_disabled,
                  color: connected ? Colors.white : Colors.white,
                ),
                title: Text(
                  connected ? "Printer Connected" : "No Printer Connected",
                  style:  TextStyle(color: AppColors.white),
                ),
                subtitle: Text(_msj , style: TextStyle(color: AppColors.white),),
              ),
            ),

            const SizedBox(height: 10),

            // PAPER SIZE
            Card(
              child: ListTile(
                title: const Text("Paper Size"),
                trailing: DropdownButton<String>(
                  value: optionprinttype,
                  items: options.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (v) => setState(() => optionprinttype = v!),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: getBluetoots,
                 
                    label: Text(_progress ? _msjprogress : "Search"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: connected ? disconnect : null,
           
                    label: const Text("Disconnect"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: connected ? printTest : null,
                   
                    label: const Text("Test"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // DEVICE LIST
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        "No printers",
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final d = items[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.bluetooth),
                            title: Text(d.name),
                            subtitle: Text(d.macAdress),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => connect(d.macAdress),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ESC POS =================
  Future<List<int>> testTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];

    bytes += generator.text("QUEUE SYSTEM",
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    bytes += generator.hr();
    bytes += generator.text("Printer test successful",
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.feed(2);
    return bytes;
  }
}
