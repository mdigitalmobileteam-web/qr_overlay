import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner/custom_barcode_overlay.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  MobileScannerController? controller;

  // A scan window does work on web, but not the overlay to preview the scan
  // window. This is why we disable it here for web examples.

  Size desiredCameraResolution = const Size(1920, 1080);
  DetectionSpeed detectionSpeed = DetectionSpeed.unrestricted;
  int detectionTimeoutMs = 1000;

  bool useBarcodeOverlay = true;
  BoxFit boxFit = BoxFit.contain;
  bool enableLifecycle = false;

  /// Hides the MobileScanner widget while the MobileScannerController is
  /// rebuilding
  bool hideMobileScannerWidget = false;

  List<BarcodeFormat> selectedFormats = [];

  MobileScannerController initController() => MobileScannerController(
        autoStart: false,
        cameraResolution: desiredCameraResolution,
        detectionSpeed: detectionSpeed,
        detectionTimeoutMs: detectionTimeoutMs,
        formats: selectedFormats,
        // torchEnabled: true,
      );

  @override
  void initState() {
    super.initState();
    controller = initController();
    unawaited(controller!.start());
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller?.dispose();
    controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller == null || hideMobileScannerWidget
          ? const Placeholder()
          : Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  fit: boxFit,
                ),
                if (useBarcodeOverlay)
                  CustomBarcodeOverlay(
                    controller: controller!,
                    boxFit: boxFit,
                    style: PaintingStyle.stroke,
                    color: Colors.white,
                  ),
              ],
            ),
    );
  }
}
