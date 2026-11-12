import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Render PNG images for all four Patient App QR screens', () async {
    const scratchDir = 'C:/Users/PABANI/.gemini/antigravity/brain/940411e7-b698-4c49-9373-7dd07e8651b0/scratch';
    final dir = Directory(scratchDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final testCases = <String, Map<String, dynamic>>{
      'screen1_health_card': {
        'payload': 'HVQR-9596203EE8FF1D57',
        'color': const Color(0xFF0F172A),
        'size': 300.0,
      },
      'screen2_dependent_card': {
        'payload': 'HC-DEP-2026-0001',
        'color': const Color(0xFF2E006A),
        'size': 300.0,
      },
      'screen3_qr_preview': {
        'payload': 'HVQR-9596203EE8FF1D57',
        'color': const Color(0xFF1E1B4B),
        'size': 300.0,
      },
      'screen4_qr_dashboard': {
        'payload': 'HVQR-CID9928',
        'color': const Color(0xFF6D28D9),
        'size': 300.0,
      },
      'screen1_canonical_json': {
        'payload': '{"v":"1.0","type":"CAREID_HEALTH_CARD","token":"HVQR-9596203EE8FF1D57","cardNumber":"HC-CAREID-2026-0004"}',
        'color': const Color(0xFF0F172A),
        'size': 400.0,
      },
    };

    for (final entry in testCases.entries) {
      final name = entry.key;
      final payload = entry.value['payload'] as String;
      final color = entry.value['color'] as Color;
      final size = entry.value['size'] as double;

      final painter = QrPainter(
        data: payload,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: color,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: color,
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      // Draw pure white quiet zone & background matching Flutter UI container
      canvas.drawRect(Rect.fromLTWH(0, 0, size, size), Paint()..color = Colors.white);
      // Add margin for quiet zone (16px)
      const margin = 16.0;
      canvas.save();
      canvas.translate(margin, margin);
      painter.paint(canvas, Size(size - margin * 2, size - margin * 2));
      canvas.restore();

      final pic = recorder.endRecording();
      final img = await pic.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      expect(byteData, isNotNull, reason: 'Failed to generate PNG for $name');

      final bytes = byteData!.buffer.asUint8List();
      final outFile = File('$scratchDir/$name.png');
      outFile.writeAsBytesSync(bytes);
      print('Wrote $name.png (${bytes.length} bytes) encoding: $payload');
      expect(outFile.existsSync(), isTrue);
    }
  });
}
