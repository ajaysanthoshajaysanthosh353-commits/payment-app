import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<void> shareTransaction(String transactionDetails) async {
  try {
    await Clipboard.setData(ClipboardData(text: transactionDetails));
    debugPrint('Transaction details copied to clipboard.');
  } catch (e) {
    debugPrint('Failed to copy transaction details: $e');
  }
}