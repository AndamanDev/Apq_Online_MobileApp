import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Classprinterservice {
  static const String _printerKey = "SAVED_PRINTER_MAC";

  static final Classprinterservice instance = Classprinterservice._internal();
  Classprinterservice._internal();

  bool connected = false;
  String? savedMac;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    savedMac = prefs.getString(_printerKey);

    if (savedMac != null) {
      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: savedMac!);
      connected = result;
    }
  }

  Future<bool> connect(String mac) async {
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    if (result) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_printerKey, mac);
      savedMac = mac;
      connected = true;
    }
    return result;
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_printerKey);

    savedMac = null;
    connected = false;
  }
}
