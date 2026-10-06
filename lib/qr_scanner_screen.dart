import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import'qr_payment_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR"),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (scanned) return;

          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;
           Navigator.push(context, MaterialPageRoute(builder: (_)=>QrPaymentScreen(qrData: code ??"",),
              )
              );

          if (code == null) return;

          scanned = true;

          debugPrint(code);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Scanned: $code"),
            ),
          );

          // Optional: Go back with scanned value
          // Navigator.pop(context, code);
        },
      ),
    );
  }
}