import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants.dart';
import 'scan_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isNavigating = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isNavigating) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isNavigating = true);
        
        final String userId = barcode.rawValue!;
        controller.stop(); // Pause Camera

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(userId: userId),
          ),
        ).then((_) {
          // Resume when coming back
          setState(() => _isNavigating = false);
          controller.start();
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("OPTICAL SCANNER"),
        backgroundColor: Colors.black54,
        iconTheme: const IconThemeData(color: AppConstants.accentCyan),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: SizedBox.expand(),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "ALIGN QR DATA MATRIX",
                style: TextStyle(
                  color: AppConstants.accentCyan.withOpacity(0.8),
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Re-using the Painter from before
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.8)..style = PaintingStyle.fill;
    const double scanSize = 280;
    final double left = (size.width - scanSize) / 2;
    final double top = (size.height - scanSize) / 2;
    final rect = Rect.fromLTWH(left, top, scanSize, scanSize);
    
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height))..addRect(rect);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    final borderPaint = Paint()..color = AppConstants.accentCyan..style = PaintingStyle.stroke..strokeWidth = 3;
    final double len = 30;
    
    // Draw corners (Simplified for brevity)
    canvas.drawLine(Offset(left, top), Offset(left + len, top), borderPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + len), borderPaint);
    canvas.drawLine(Offset(left + scanSize, top), Offset(left + scanSize - len, top), borderPaint);
    canvas.drawLine(Offset(left + scanSize, top), Offset(left + scanSize, top + len), borderPaint);
    // Add bottom corners similarly...
    canvas.drawLine(Offset(left, top + scanSize), Offset(left + len, top + scanSize), borderPaint);
    canvas.drawLine(Offset(left, top + scanSize), Offset(left, top + scanSize - len), borderPaint);
    canvas.drawLine(Offset(left + scanSize, top + scanSize), Offset(left + scanSize - len, top + scanSize), borderPaint);
    canvas.drawLine(Offset(left + scanSize, top + scanSize), Offset(left + scanSize, top + scanSize - len), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}