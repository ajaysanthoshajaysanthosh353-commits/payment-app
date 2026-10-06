
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payment_app/confirm_payment_screen.dart';

final user = FirebaseAuth.instance.currentUser;

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // Modern dark charcoal colors
  static const Color charcoal = Color.fromARGB(255, 8, 70, 32);
  static const Color darkCharcoal = Color.fromARGB(255, 0, 192, 42);
  static const Color softWhite = Color(0xFFF7F7F7);
  static const Color textGrey = Color.fromARGB(255, 165, 240, 199);

  @override
  void dispose() {
    mobileController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: charcoal,

      // --------------------------------------------------
      // APP BAR
      // --------------------------------------------------
      appBar: AppBar(
        backgroundColor: darkCharcoal,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 75,

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),

        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),

          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 21, 22, 24),
            borderRadius: BorderRadius.circular(18),

            boxShadow: [
              // Neumorphic dark shadow
              const BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: Offset(5, 5),
              ),

              // Soft light shadow
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(-4, -4),
              ),
            ],
          ),

          child: const Text(
            "Send Payment",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color.fromARGB(255, 255, 226, 226),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),

      // --------------------------------------------------
      // BODY
      // --------------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              const SizedBox(height: 10),

              // --------------------------------------------------
              // MAIN NEUMORPHIC CARD
              // --------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: charcoal,
                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    // Bottom-right dark shadow
                    const BoxShadow(
                      color: Colors.black,
                      blurRadius: 20,
                      offset: Offset(8, 8),
                    ),

                    // Top-left light shadow
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(-7, -7),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // --------------------------------------------------
                    // TITLE
                    // --------------------------------------------------
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,

                          decoration: BoxDecoration(
                            color: charcoal,
                            borderRadius: BorderRadius.circular(16),

                            boxShadow: [
                              const BoxShadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(5, 5),
                              ),

                              BoxShadow(
                                color: Colors.white.withValues(
                                  alpha: 0.06,
                                ),
                                blurRadius: 10,
                                offset: const Offset(-4, -4),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),

                        const SizedBox(width: 16),

                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Send Money",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 0.2,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Enter receiver details",
                              style: TextStyle(
                                color: textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // --------------------------------------------------
                    // MOBILE NUMBER
                    // --------------------------------------------------
                    const Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: darkCharcoal,
                        borderRadius: BorderRadius.circular(16),

                        boxShadow: [
                          // Inner-looking dark shadow
                          const BoxShadow(
                            color: Colors.black,
                            blurRadius: 8,
                            offset: Offset(4, 4),
                          ),

                          BoxShadow(
                            color: Colors.white.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 8,
                            offset: const Offset(-3, -3),
                          ),
                        ],
                      ),

                      child: TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),

                        decoration: InputDecoration(
                          counterText: "",

                          hintText: "Enter 10-digit mobile number",

                          hintStyle: const TextStyle(
                            color: textGrey,
                            fontSize: 14,
                          ),

                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: Colors.white,
                          ),

                          filled: true,
                          fillColor: Colors.transparent,

                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 15,
                          ),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter mobile number";
                          }

                          if (!RegExp(r'^[0-9]+$')
                              .hasMatch(value)) {
                            return "Only numbers are allowed";
                          }

                          if (value.length != 10) {
                            return "Enter a valid 10-digit number";
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --------------------------------------------------
                    // AMOUNT
                    // --------------------------------------------------
                    const Text(
                      "Amount",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: darkCharcoal,
                        borderRadius: BorderRadius.circular(16),

                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black,
                            blurRadius: 8,
                            offset: Offset(4, 4),
                          ),

                          BoxShadow(
                            color: Colors.white.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 8,
                            offset: const Offset(-3, -3),
                          ),
                        ],
                      ),

                      child: TextFormField(
                        controller: amountController,

                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),

                        decoration: InputDecoration(
                          hintText: "Enter amount",

                          hintStyle: const TextStyle(
                            color: textGrey,
                            fontSize: 14,
                          ),

                          prefixIcon: const Icon(
                            Icons.currency_rupee,
                            color: Colors.white,
                          ),

                          filled: true,
                          fillColor: Colors.transparent,

                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 15,
                          ),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter amount";
                          }

                          final amount =
                              double.tryParse(value);

                          if (amount == null) {
                            return "Enter a valid amount";
                          }

                          if (amount <= 0) {
                            return "Amount must be greater than 0";
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 35),

                    // --------------------------------------------------
                    // CONTINUE BUTTON
                    // --------------------------------------------------
                    Center(
                      child: SizedBox(
                        width: 230,
                        height: 58,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: softWhite,
                            foregroundColor: darkCharcoal,

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),

                          onPressed: () {
                            if (_formKey.currentState!
                                .validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ConfirmPaymentScreen(
                                    mobileNumber:
                                        mobileController.text
                                            .trim(),

                                    amount:
                                        amountController.text
                                            .trim(),
                                  ),
                                ),
                              );
                            }
                          },

                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: darkCharcoal,
                                ),
                              ),

                              SizedBox(width: 12),

                              Icon(
                                Icons.arrow_forward_rounded,
                                color: darkCharcoal,
                                size: 23,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // --------------------------------------------------
                    // SECURITY TEXT
                    // --------------------------------------------------
                    Center(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: const [
                          Icon(
                            Icons.lock_outline,
                            size: 15,
                            color: textGrey,
                          ),

                          SizedBox(width: 6),

                          Text(
                            "Secure payment",
                            style: TextStyle(
                              fontSize: 12,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Bottom information
              const Text(
                "ECpay • Fast & Secure Payments",
                style: TextStyle(
                  color: textGrey,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
