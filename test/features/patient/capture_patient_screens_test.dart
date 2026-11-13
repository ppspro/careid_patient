import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:careid_patient_app/features/patient/data/models/digital_health_card_models.dart';
import 'package:careid_patient_app/features/patient/data/models/patient_profile_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/qr_dashboard_screen.dart';

Future<void> captureWidget(WidgetTester tester, Widget screen, String filename, {Size physicalSize = const Size(390, 844)}) async {
  print('--> Starting $filename');
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = 1.0;

  final key = GlobalKey();

  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RepaintBoundary(
      key: key,
      child: screen,
    ),
  ));
  tester.takeException();
  await tester.pump(const Duration(milliseconds: 100));
  tester.takeException();
  await tester.pump(const Duration(milliseconds: 100));
  tester.takeException();

  final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final bytes = byteData!.buffer.asUint8List();

  final outDir = Directory(r'C:\Users\PABANI\.gemini\antigravity\brain\940411e7-b698-4c49-9373-7dd07e8651b0\scratch');
  final rawFile = File('${outDir.path}/${filename.replaceAll('.png', '.raw')}');
  final header = Uint8List(8);
  final bdata = ByteData.sublistView(header);
  bdata.setUint32(0, image.width);
  bdata.setUint32(4, image.height);

  final fullData = Uint8List(8 + bytes.length);
  fullData.setRange(0, 8, header);
  fullData.setRange(8, 8 + bytes.length, bytes);
  rawFile.writeAsBytesSync(fullData, flush: true);
  print('--> Saved $filename (${rawFile.path})');
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    FlutterError.onError = (details) {};
  });

  testWidgets('Capture P-4: QR Dashboard Screen', (WidgetTester tester) async {
    const dummyCard = HealthCardDto(
      id: 'hc-9928',
      cardNumber: 'CID-9928',
      status: 'ACTIVE',
      qrPayload: 'HVQR-9596203EE8FF1D57',
    );
    const dummyProfile = PatientProfileDto(
      id: 'p-9928',
      firstName: 'Eliza V.',
      lastName: 'Reed',
    );
    await captureWidget(
      tester,
      const QrDashboardScreen(
        language: 'en',
        initialHealthCard: dummyCard,
        initialProfile: dummyProfile,
      ),
      'actual_patient_qr_dashboard.png',
    );
  });
}
