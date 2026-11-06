import 'package:flutter/material.dart';
import 'paymentsuccess_screen.dart';
import 'package:google_fonts/google_fonts.dart';
// ============================================================
// ECpay - Dark Neumorphic Theme
// ============================================================

const Color kBackground = Color.fromARGB(255, 40, 156, 84);
const Color kDark = Color.fromARGB(255, 11, 12, 10);
const Color kSurface = Color.fromARGB(255, 28, 136, 69);
const Color kLightSurface = Color.fromARGB(255, 223, 229, 235);
const Color kWhite = Color(0xFFF7F7F7);
const Color kTextGrey = Color.fromARGB(255, 200, 205, 212);

// ============================================================
// Neumorphic Decoration
// ============================================================

BoxDecoration neumorphicDecoration({
  double radius = 18,
  bool pressed = false,
}) {
  return BoxDecoration(
    color: pressed ? kDark : kSurface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: pressed
        ? const [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white10,
              offset: Offset(-2, -2),
              blurRadius: 6,
            ),
          ]
        : const [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(6, 6),
              blurRadius: 12,
            ),
            BoxShadow(
              color: Colors.white10,
              offset: Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
  );
}

// ============================================================
// Payment Authorization Screen
// ============================================================

class PaymentAuthScreen extends StatefulWidget {
  final String mobileNumber;
  final String amount;

  const PaymentAuthScreen({
    super.key,
    required this.mobileNumber,
    required this.amount,
  });

  @override
  State<PaymentAuthScreen> createState() => _PaymentAuthScreenState();
}

class _PaymentAuthScreenState extends State<PaymentAuthScreen> {
  bool isProcessing = false;

  // ==========================================================
  // Authorize Payment
  // ==========================================================

  void authorizePayment() {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Payment Authorized Successfully",
            style: TextStyle(
              color: kWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: kLightSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentsuccessScreen(
            mobileNumber: widget.mobileNumber,
            amount: widget.amount,
          ),
        ),
      );
    });
  }

  // ==========================================================
  // Detail Row
  // ==========================================================

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
    bool isAmount = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: neumorphicDecoration(
            radius: 14,
            pressed: true,
          ),
          child: Icon(
            icon,
            color: kWhite,
            size: 21,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kTextGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                isAmount ? "₹$value" : value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kWhite,
                  fontSize: isAmount ? 20 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // Build
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 45, 240, 120),

      // ======================================================
      // App Bar
      // ======================================================

      appBar: AppBar(
        title: Text(
          "Authorize Payment",
          style: GoogleFonts.oswald(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: kWhite,
          ),
        ),
        centerTitle: true,
        backgroundColor: kBackground,
        foregroundColor: kWhite,
        elevation: 0,
      ),

      // ======================================================
      // Body
      // ======================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            25,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =================================================
              // Lock Icon
              // =================================================

              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: neumorphicDecoration(
                    radius: 48,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: neumorphicDecoration(
                      radius: 38,
                      pressed: true,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 40,
                      color: kWhite,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // Title
              // =================================================

              const Text(
                "Authorize Payment",
                textAlign: TextAlign.center,
                style: TextStyle(
                  
                  color: kWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Review the payment details before continuing",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // =================================================
              // Payment Details Card
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: neumorphicDecoration(
                  radius: 22,
                ),
                child: Column(
                  children: [
                    _detailRow(
                      icon: Icons.phone_android_rounded,
                      title: "Mobile Number",
                      value: widget.mobileNumber,
                    ),

                    const SizedBox(height: 18),

                    Container(
                      height: 1,
                      color: Colors.white10,
                    ),

                    const SizedBox(height: 18),

                    _detailRow(
                      icon: Icons.currency_rupee_rounded,
                      title: "Payment Amount",
                      value: widget.amount,
                      isAmount: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // Security Information
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: neumorphicDecoration(
                  radius: 16,
                  pressed: true,
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: kWhite,
                      size: 22,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Your payment is securely processed through ECpay.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kTextGrey,
                          fontSize: 12,
                          height: 1.4,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // =================================================
              // Continue Button
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : authorizePayment,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWhite,
                    disabledBackgroundColor: kLightSurface,
                    foregroundColor: kDark,
                    disabledForegroundColor: kTextGrey,
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: isProcessing
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: kDark,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            SizedBox(width: 10),

                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 21,
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 14),

              // =================================================
              // Bottom Security Text
              // =================================================

              const Text(
                "🔒 Secure payment authorization",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}