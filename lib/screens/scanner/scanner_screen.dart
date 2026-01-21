import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../users/user_detail_screen.dart'; // Reuse your user detail screen

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  final ApiService _api = ApiService();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        final String scannedValue = barcode.rawValue!;
        
        // Assuming QR contains JnanagniID directly (e.g., "JGN26-XY12")
        // Or if it's a URL, extract the ID.
        
        try {
          // Call Backend: /users/scan/:jnanagniId
          final res = await _api.get('/users/scan/$scannedValue');
          
          if (res['success'] == true && mounted) {
            final userId = res['data']['_id']; // Get the Mongo ID from response
            
            // Stop camera and Navigate
            controller.stop();
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserDetailScreen(userId: userId)),
            );
            // Resume scanning when coming back
            setState(() => _isProcessing = false);
            controller.start();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Scan Error: User not found or invalid ID"), backgroundColor: Colors.red)
          );
          setState(() => _isProcessing = false);
        }
        break; 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Participant"), backgroundColor: Colors.black),
      body: MobileScanner(
        controller: controller,
        onDetect: _onDetect,
        overlayBuilder: (context, constraints) {
          return Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: CyberColors.neonCyan, width: 4),
                borderRadius: BorderRadius.circular(12)
              ),
              child: _isProcessing 
                ? const Center(child: CircularProgressIndicator(color: CyberColors.neonCyan))
                : null,
            ),
          );
        },
      ),
    );
  }
}