library qr_overlay;

export 'package:mobile_scanner/mobile_scanner.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:math' as math;

class QrOverlay extends StatefulWidget {
  /// Construct a new [QrOverlay] instance.
  const QrOverlay({
    this.boxFit = BoxFit.cover,
    required this.controller,
    super.key,
    this.style = PaintingStyle.fill,
    this.defaultSize = 200,
    this.borderColor = Colors.white,
    this.strokeWidth = 4,
    this.animationDuration = const Duration(milliseconds: 300),
    this.overlayColor = const Color(0x88000000),
  });

  /// The [BoxFit] to use when painting the barcode box.
  final BoxFit boxFit;

  /// The controller that provides the barcodes to display.
  final MobileScannerController controller;

  /// The style to use when painting the barcode box.
  ///
  /// Defaults to [PaintingStyle.fill].
  final PaintingStyle style;
  final double defaultSize;
  final Color borderColor;
  final double strokeWidth;
  final Duration animationDuration;
  final Color overlayColor;

  @override
  State<QrOverlay> createState() => _QrOverlayState();
}

class _QrOverlayState extends State<QrOverlay> {
  final _textPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  @override
  void dispose() {
    _textPainter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized || !value.isRunning || value.error != null) {
          return const SizedBox();
        }

        return StreamBuilder<BarcodeCapture>(
          stream: widget.controller.barcodes,
          builder: (context, snapshot) {
            final overlays = <Widget>[
              AnimatedBarcodeOverlay(
                boxFit: widget.boxFit,
                controller: widget.controller,
                defaultSize: widget.defaultSize,
                borderColor: widget.borderColor,
                strokeWidth: widget.strokeWidth,
                animationDuration: widget.animationDuration,
                overlayColor: widget.overlayColor,
              ),
            ];

            return Stack(fit: StackFit.expand, children: overlays);
          },
        );
      },
    );
  }
}

class AnimatedBarcodeOverlay extends StatefulWidget {
  final MobileScannerController controller;
  final BoxFit boxFit;
  final double defaultSize;
  final Color borderColor;
  final double strokeWidth;
  final Duration animationDuration;
  final Color overlayColor;

  const AnimatedBarcodeOverlay({
    super.key,
    required this.controller,
    required this.boxFit,
    required this.defaultSize,
    required this.borderColor,
    required this.strokeWidth,
    required this.animationDuration,
    required this.overlayColor,
  });

  @override
  State<AnimatedBarcodeOverlay> createState() => _AnimatedBarcodeOverlayState();
}

class _AnimatedBarcodeOverlayState extends State<AnimatedBarcodeOverlay> {
  Rect? _targetRect;
  late final StreamSubscription<BarcodeCapture> _barcodeSubscription;

  @override
  void initState() {
    super.initState();

    _barcodeSubscription = widget.controller.barcodes.listen((capture) {
      if (!mounted || capture.barcodes.isEmpty) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;

        final size = box.size;
        final rect = _computeTargetRect(capture, size);
        setState(() {
          _targetRect = rect;
        });
      });
    });
  }

  @override
  void dispose() {
    _barcodeSubscription.cancel();
    super.dispose();
  }

  Rect _computeTargetRect(BarcodeCapture capture, Size size) {
    final previewSize = capture.size;
    final corners = capture.barcodes.first.corners;
    final ratios = calculateBoxFitRatio(widget.boxFit, previewSize, size);

    final dx = (previewSize.width * ratios.widthRatio - size.width) / 2;
    final dy = (previewSize.height * ratios.heightRatio - size.height) / 2;

    final mapped = corners.map((pt) => Offset(pt.dx * ratios.widthRatio - dx, pt.dy * ratios.heightRatio - dy));
    final xs = mapped.map((o) => o.dx);
    final ys = mapped.map((o) => o.dy);

    return Rect.fromLTRB(xs.reduce(math.min), ys.reduce(math.min), xs.reduce(math.max), ys.reduce(math.max));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final defaultRect = Rect.fromCenter(
        center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
        width: widget.defaultSize,
        height: widget.defaultSize,
      );

      final endRect = _targetRect ?? defaultRect;

      return TweenAnimationBuilder<Rect?>(
        tween: RectTween(begin: defaultRect, end: endRect),
        duration: widget.animationDuration,
        builder: (ctx, rect, child) {
          final r = rect ?? defaultRect;
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MaskPainter(rect: r, color: widget.overlayColor),
                ),
              ),
              Positioned.fromRect(
                rect: r,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: widget.borderColor, width: widget.strokeWidth),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

class _MaskPainter extends CustomPainter {
  final Rect rect;
  final Color color;

  _MaskPainter({required this.rect, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));
    final path = Path.combine(PathOperation.difference, overlay, cutout);
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _MaskPainter old) => old.rect != rect || old.color != color;
}
