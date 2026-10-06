import 'package:flutter/material.dart';
import 'payment_auth_screen.dart';

// ============================================================
// ECpay Dark Neumorphic Theme
// ============================================================

const Color kBackground = Color.fromARGB(255, 47, 209, 109);
const Color kDark = Color.fromRGBO(8, 8, 8, 1);
const Color kSurface = Color.fromARGB(255, 11, 145, 138);
const Color kWhite = Color(0xFFF7F7F7);
const Color kTextGrey = Color(0xFF92959A);

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
              offset: Offset(5, 5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.white10,
              offset: Offset(-3, -3),
              blurRadius: 8,
            ),
          ],
  );
}

// ============================================================
// Confirm Payment Screen
// ============================================================

class ConfirmPaymentScreen extends StatelessWidget {
  final String mobileNumber;
  final String amount;

  const ConfirmPaymentScreen({
    super.key,
    required this.mobileNumber,
    required this.amount,
  });

  // ==========================================================
  // Receiver Card
  // ==========================================================

  Widget _receiverCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: neumorphicDecoration(
        radius: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: neumorphicDecoration(
              radius: 16,
              pressed: true,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: kWhite,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Receiver",
                  style: TextStyle(
                    color: kTextGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  mobileNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 32,
            height: 32,
            decoration: neumorphicDecoration(
              radius: 11,
              pressed: true,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: kWhite,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // Build
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,

      // ======================================================
      // App Bar
      // ======================================================

      appBar: AppBar(
        title: const Text(
          "Confirm Payment",
          style: TextStyle(
            color: kWhite,
            fontSize: 21,
            fontWeight: FontWeight.w800,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 28,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =================================================
                      // Wallet Icon
                      // =================================================

                      Center(
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: neumorphicDecoration(
                            radius: 39,
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: neumorphicDecoration(
                              radius: 30,
                              pressed: true,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: kWhite,
                              size: 34,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =================================================
                      // Heading
                      // =================================================

                      const Center(
                        child: Text(
                          "Confirm Your Payment",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Center(
                        child: Text(
                          "Review the details before proceeding",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kTextGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // Paying To
                      // =================================================

                      const Text(
                        "Paying To",
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 9),

                      _receiverCard(),

                      const SizedBox(height: 18),

                      // =================================================
                      // Amount
                      // =================================================

                      const Text(
                        "Amount",
                        style: TextStyle(
                          color: kTextGrey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: neumorphicDecoration(
                          radius: 17,
                          pressed: true,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 43,
                              height: 43,
                              decoration: neumorphicDecoration(
                                radius: 13,
                              ),
                              child: const Icon(
                                Icons.currency_rupee_rounded,
                                color: kWhite,
                                size: 21,
                              ),
                            ),

                            const SizedBox(width: 13),

                            Expanded(
                              child: Text(
                                "₹ $amount",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: kWhite,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =================================================
                      // Security Information
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: neumorphicDecoration(
                          radius: 15,
                          pressed: true,
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.security_outlined,
                              color: kWhite,
                              size: 20,
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Please verify the receiver and amount before continuing.",
                                style: TextStyle(
                                  color: kTextGrey,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // This Spacer only uses available extra space.
                      // SingleChildScrollView prevents overflow.
                      const Spacer(),

                      const SizedBox(height: 22),

                      // =================================================
                      // Confirm Button
                      // =================================================

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PaymentAuthScreen(
                                  mobileNumber: mobileNumber,
                                  amount: amount,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kWhite,
                            foregroundColor: kDark,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(17),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                "Confirm Payment",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              SizedBox(width: 8),

                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // =================================================
                      // Bottom Text
                      // =================================================

                      const Center(
                        child: Text(
                          "🔒 Secure payment with ECpay",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kTextGrey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}