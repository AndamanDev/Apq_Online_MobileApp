import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart';
import 'package:http/http.dart' as http;
import 'package:charset_converter/charset_converter.dart';
import 'package:image/image.dart' as img;

import '../Api/ApiConfig.dart';

class Classticket {
  String paperSize = "58 mm";

  Future<List<int>> printQueueTicket(Map<String, dynamic> json) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paperSize == "58 mm" ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> ticket = [];

    // Init printer
    ticket.addAll([27, 116, 255]);

    // ================= LOGO FROM SERVER =================
    final String? base = json['data']['branch']['picture_base_url'];
    final String? path = json['data']['branch']['picture_path'];

    if (base != null && path != null) {
      final imageUrl = base + path;
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final image = decodeImage(response.bodyBytes);
          if (image != null) {
            final paperWidth = paperSize == "58 mm" ? 384 : 576;
            final centered = centerImage(image, paperWidth);
            ticket.addAll(generator.image(centered).toList());
          }
        }
      } catch (e) {
        print("Image load error: $e");
      }
    }

    final uri = Uri.parse(ApiConfig.scanqueue)
      .replace(queryParameters: {'id':  json['data']['queue']['queue_id'].toString()});
    final qrUrl = uri.toString();

    // ================= LOCAL LOGO =================
    final ByteData data = await rootBundle.load('assets/logo/A2.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final Image? image = decodeImage(bytes);

    final ByteData data1 = await rootBundle.load('assets/logo/A3.png');
    final Uint8List bytes1 = data1.buffer.asUint8List();
    final Image? image1 = decodeImage(bytes1);

    final ByteData data2 = await rootBundle.load('assets/logo/A5.png');
    final Uint8List bytes2 = data2.buffer.asUint8List();
    final Image? image2 = decodeImage(bytes2);

    // ================= DATE =================
    ticket.addAll(
      generator
          .text(
            json['data']['queue']['queue_date'] ?? '',
            styles: const PosStyles(bold: true, align: PosAlign.center),
          )
          .toList(),
    );

    ticket.addAll(generator.feed(1).toList());

    // ================= QUEUE NO =================
    ticket.addAll(
      generator
          .text(
            json['data']['queue']['queue_no'] ?? '',
            styles: const PosStyles(
              bold: true,
              align: PosAlign.center,
              height: PosTextSize.size3,
              width: PosTextSize.size3,
            ),
          )
          .toList(),
    );

    ticket.addAll(generator.feed(1).toList());

    // ================= PAX =================
    ticket.addAll(
      generator
          .text(
            "${json['data']['queue']['number_pax']} PAX",
            styles: const PosStyles(bold: true, align: PosAlign.center),
          )
          .toList(),
    );

    if (image != null) {
      final paperWidth = paperSize == "58 mm" ? 384 : 576;
      final centered = centerImage(image, paperWidth);
      ticket.addAll(generator.image(centered).toList());

      final centered1 = centerImage(image1!, paperWidth);
      ticket.addAll(generator.image(centered1).toList());

      ticket.addAll(generator.qrcode(qrUrl).toList());

      final centered2 = centerImage(image2!, paperWidth);
      ticket.addAll(generator.image(centered2).toList());
    }

    ticket.addAll(generator.cut().toList());

    return ticket;
  }

  // Thai encoding if needed
  Future<Uint8List> _thai(String text) async {
    final bytes = await CharsetConverter.encode("TIS-620", text);
    return Uint8List.fromList(bytes);
  }

  img.Image centerImage(img.Image src, int paperWidth) {
    // Resize ถ้ารูปกว้างเกินกระดาษ
    if (src.width > paperWidth) {
      src = img.copyResize(src, width: paperWidth);
    }

    // ขยาย canvas ให้กว้างเท่ากระดาษ และวางรูปไว้ตรงกลาง
    return img.copyExpandCanvas(
      src,
      newWidth: paperWidth,
      newHeight: src.height,
      position: img.ExpandCanvasPosition.center,
      backgroundColor: img.ColorRgb8(255, 255, 255),
    );
  }
}
