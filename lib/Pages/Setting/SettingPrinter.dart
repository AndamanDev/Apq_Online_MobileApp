import 'package:apq_m1/Class/ClassPrinterService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settingprinter extends StatefulWidget {
  const Settingprinter({super.key});

  @override
  State<Settingprinter> createState() => _SettingprinterState();
}

class _SettingprinterState extends State<Settingprinter> {
  static const String _printerKey = "SAVED_PRINTER_MAC";

  // ===== Printer Status =====
  bool connected = false;
  String printerMessage = "";
  bool _progress = false;
  String _msjprogress = "";
  String? selectedMac;
  // ===== Paper Size =====
  String paperSize = "58 mm";
  List<String> paperOptions = ["58 mm", "80 mm"];

  // ===== Bluetooth Devices =====
  List<BluetoothInfo> devices = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _autoConnectPrinter();
  }

  Future<void> _autoConnectPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final String? mac = prefs.getString(_printerKey);

    if (mac != null) {
      setState(() {
        _progress = true;
        _msjprogress = "Reconnecting printer...";
      });

      final bool result = await Classprinterservice.instance.connect(mac);

      setState(() {
        selectedMac = mac;
        connected = result;
        _progress = false;
        printerMessage = result
            ? "Auto connected to saved printer"
            : "Saved printer not found";
      });
    }
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
    // await PrintBluetoothThermal.disconnect;
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

    final bool result = await Classprinterservice.instance.connect(mac);

    if (result) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_printerKey, mac);
      setState(() {
        selectedMac = mac;
      });
    }

    setState(() {
      connected = result;
      _progress = false;
      printerMessage = result ? "Connected" : "Connection failed";
    });
  }

  Future<void> disconnect() async {
    await Classprinterservice.instance.disconnect();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_printerKey);

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

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            leading: Icon(
              Icons.print,
              color: connected ? Colors.green : Colors.red,
            ),
            title: const Text(
              "Printer Settings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            childrenPadding: const EdgeInsets.all(12),
            children: [
              // Printer Status Card
              Card(
                color: connected ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    connected ? Icons.print : Icons.print_disabled,
                    color: Colors.white,
                  ),
                  title: Text(
                    connected ? "Printer Connected" : "No Printer Connected",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    printerMessage,
                    style: const TextStyle(color: Colors.white),
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
                      child: const Text("Uncon"),
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

              // Paper Size
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DropdownButtonFormField<String>(
                  value: paperSize,
                  decoration: const InputDecoration(
                    labelText: "Paper size",
                    border: OutlineInputBorder(),
                  ),
                  items: paperOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => paperSize = v!),
                ),
              ),

              const SizedBox(height: 10),

              devices.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("No printers found"),
                    )
                  : Column(
                      children: devices.map((d) {
                        final bool isSelected = d.macAdress == selectedMac;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? Colors.green : Colors.black,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isSelected ? Icons.check_circle : Icons.bluetooth,
                              color: isSelected ? Colors.green : null,
                            ),
                            title: Text(d.name),
                            subtitle: Text(d.macAdress),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.verified,
                                    color: Colors.green,
                                  )
                                : const Icon(Icons.chevron_right),
                            onTap: () => connect(d.macAdress),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
