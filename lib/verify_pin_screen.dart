import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyPinScreen extends StatefulWidget {
  final String receiver;
  final String amount;

  const VerifyPinScreen({
    super.key,
    required this.receiver,
    required this.amount,
  });

  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  final TextEditingController pinController = TextEditingController();

  bool hidePin = true;
  bool isLoading = false;

  // Green and black theme
  static const Color backgroundColor = Color.fromARGB(255, 12, 202, 12);
  static const Color primaryGreen = Color.fromARGB(255, 8, 187, 8);
  static const Color cardColor = Color(0xFF1B2520);
  static const Color textColor = Colors.white;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  // Verify PIN format
  Future<void> verifyPin() async {
    final String pin = pinController.text.trim();

    // Check that the PIN contains exactly four digits.
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid 4-digit PIN.',
            style: GoogleFonts.abel(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // IMPORTANT:
      // This checks only the PIN format.
      // Actual PIN verification must be implemented securely
      // using your Firebase Cloud Function.

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PIN format accepted. Actual PIN verification is not configured.',
            style: GoogleFonts.abel(),
          ),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
        ),
      );

      // Do not authorize or complete the payment here until
      // the PIN has been verified by your secure backend.
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: const Color.fromRGBO(255, 240, 240, 1),
        elevation: 0,
        title: Text(
          'Verify PIN',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(42)),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Lock icon
              const Icon(
                CupertinoIcons.lock_fill,
                color: Color.fromRGBO(204, 255, 204, 1),
                size: 75,
              ),

              const SizedBox(height: 20),

              // Heading
              Text(
                'Enter Your PIN',
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter your 4-digit PIN to verify your payment.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Payment details card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryGreen.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withValues(alpha: 0.08),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Text(
                      'Payment Details',
                      style: GoogleFonts.abel(
                        color: primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Receiver
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.person_fill,
                          color: primaryGreen,
                          size: 25,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Receiver',
                                style: GoogleFonts.abel(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                widget.receiver,
                                style: GoogleFonts.abel(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Divider(color: Colors.white24),

                    SizedBox(height: 15),

                    // Amount
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee_rounded,
                          color: primaryGreen,
                          size: 28,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Amount',
                                style: GoogleFonts.abel(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '₹${widget.amount}',
                                style: GoogleFonts.abel(
                                  color: primaryGreen,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // PIN label
              Text(
                '4-Digit PIN',
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // PIN input field
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: hidePin,
                maxLength: 4,

                style: GoogleFonts.abel(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 12,
                  fontWeight: FontWeight.bold,
                ),

                decoration: InputDecoration(
                  counterText: '',

                  hintText: 'Enter PIN',
                  hintStyle: GoogleFonts.abel(
                    color: Colors.white38,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),

                  filled: true,
                  fillColor: cardColor,

                  prefixIcon: const Icon(
                    CupertinoIcons.lock_fill,
                    color: primaryGreen,
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePin = !hidePin;
                      });
                    },
                    icon: Icon(
                      hidePin
                          ? CupertinoIcons.eye_slash_fill
                          : CupertinoIcons.eye_fill,
                      color: primaryGreen,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Verify button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : verifyPin,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.green.shade900,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Done',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Security message
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.shield_lefthalf_fill,
                    color: primaryGreen,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      'Your payment PIN should remain private.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoFlex(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
