import 'package:flutter/material.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  bool hidePin = true;
  bool hideConfirmPin = true;

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  void setPin() {
    final pin = pinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 4-digit PIN')),
      );
      return;
    }

    if (pin != confirmPin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN numbers do not match')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'PIN format accepted. Secure PIN saving is not configured yet.',
        ),
      ),
    );
  }

  Widget pinField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: obscureText,
      maxLength: 4,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        letterSpacing: 12,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFF202A25),
        suffixIcon: IconButton(
          onPressed: toggleVisibility,
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101714),
      appBar: AppBar(
        title: const Text('Set PIN Number'),
        backgroundColor: const Color(0xFF101714),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            const Icon(Icons.lock_outline, color: Colors.greenAccent, size: 75),

            const SizedBox(height: 20),

            const Text(
              'Create Your PIN',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Create a 4-digit app PIN for your ECpay demo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),

            const SizedBox(height: 35),

            pinField(
              label: 'Enter 4-digit PIN',
              controller: pinController,
              obscureText: hidePin,
              toggleVisibility: () {
                setState(() => hidePin = !hidePin);
              },
            ),

            const SizedBox(height: 20),

            pinField(
              label: 'Confirm 4-digit PIN',
              controller: confirmPinController,
              obscureText: hideConfirmPin,
              toggleVisibility: () {
                setState(() {
                  hideConfirmPin = !hideConfirmPin;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: setPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Set PIN',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
