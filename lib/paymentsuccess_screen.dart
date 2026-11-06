import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ============================================================
// ECpay COLORS
// ============================================================

const Color kBackground = Color.fromARGB(255, 26, 179, 77);
const Color kDark = Color.fromARGB(255, 0, 0, 0);
const Color kSurface = Color.fromARGB(134, 26, 197, 69);
const Color kLightSurface = Color.fromARGB(255, 0, 0, 0);
const Color kWhite = Color(0xFFF7F7F7);
const Color kTextGrey = Color(0xFF92959A);

// ============================================================
// NEUMORPHIC DECORATION
// ============================================================

BoxDecoration neumorphicDecoration({
  double radius = 18,
  bool pressed = false,
}) {
  return BoxDecoration(
    color: pressed ? kDark : const Color.fromARGB(14, 202, 238, 229),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: pressed
        ? [
            const BoxShadow(
              color: Colors.black54,
              offset: Offset(4, 4),
              blurRadius: 8,
            ),
            const BoxShadow(
              color: Colors.white10,
              offset: Offset(-2, -2),
              blurRadius: 6,
            ),
          ]
        : [
            const BoxShadow(
              color: Colors.black54,
              offset: Offset(6, 6),
              blurRadius: 12,
            ),
            const BoxShadow(
              color: Colors.white10,
              offset: Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
  );
}

// ============================================================
// PAYMENT SUCCESS SCREEN
// ============================================================

class PaymentsuccessScreen extends StatelessWidget {
  final String mobileNumber;
  final String amount;

  const PaymentsuccessScreen({
    super.key,
    required this.mobileNumber,
    required this.amount,
  });

  // ============================================================
  // SAVE TRANSACTION
  // ============================================================

  Future<void> _onDonePressed(BuildContext context) async {
    bool loadingShown = false;

    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      // --------------------------------------------------------
      // CHECK LOGIN
      // --------------------------------------------------------

      if (user == null) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please login first",
            ),
            backgroundColor: kSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      // --------------------------------------------------------
      // SHOW LOADING
      // --------------------------------------------------------

      if (context.mounted) {
        loadingShown = true;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: neumorphicDecoration(
                  radius: 20,
                  pressed: true,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: kWhite,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            );
          },
        );
      }

      // --------------------------------------------------------
      // SAVE TO FIRESTORE
      // --------------------------------------------------------

      await FirebaseFirestore.instance
          .collection('transactions')
          .add({
        'userId': user.uid,
        'receiver': mobileNumber,
        'amount': amount,
        'status': 'Success',
        'timestamp':
            FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------------
      // CLOSE LOADING
      // --------------------------------------------------------

      if (context.mounted && loadingShown) {
        Navigator.of(context).pop();
        loadingShown = false;
      }

      // --------------------------------------------------------
      // SUCCESS MESSAGE
      // --------------------------------------------------------

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Transaction saved successfully",
          ),
          backgroundColor: kSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // --------------------------------------------------------
      // GO TO HOME
      // --------------------------------------------------------

      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } catch (e) {
      // --------------------------------------------------------
      // CLOSE LOADING IF OPEN
      // --------------------------------------------------------

      if (context.mounted && loadingShown) {
        Navigator.of(context).pop();
        loadingShown = false;
      }

      // --------------------------------------------------------
      // ERROR MESSAGE
      // --------------------------------------------------------

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to save transaction:\n$e",
          ),
          backgroundColor: kSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  static Widget _buildRow({
    required IconData icon,
    required String title,
    required String value,
    bool isSuccess = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      child: Row(
        children: [
          // ----------------------------------------------------
          // ICON
          // ----------------------------------------------------

          Container(
            width: 44,
            height: 44,
            decoration: neumorphicDecoration(
              radius: 22,
              pressed: true,
            ),
            child: Icon(
              icon,
              color: kWhite,
              size: 21,
            ),
          ),

          const SizedBox(width: 15),

          // ----------------------------------------------------
          // TEXT
          // ----------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kTextGrey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSuccess
                        ? kWhite
                        : kWhite,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      resizeToAvoidBottomInset: true,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: kWhite,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,

        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 9,
          ),
          decoration: neumorphicDecoration(
            radius: 25,
          ),
          child: const Text(
            "Payment Status",
            style: TextStyle(
              color: kWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints constraints,
          ) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15),

                      // ==================================================
                      // SUCCESS ICON
                      // ==================================================

                      Container(
                        width: 125,
                        height: 125,
                        decoration:
                            neumorphicDecoration(
                          radius: 63,
                          pressed: true,
                        ),
                        child: Container(
                          margin:
                              const EdgeInsets.all(15),
                          decoration:
                              neumorphicDecoration(
                            radius: 48,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: kWhite,
                            size: 62,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // SUCCESS TITLE
                      // ==================================================

                      const Text(
                        "Payment Successful",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 25,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ==================================================
                      // DESCRIPTION
                      // ==================================================

                      const Text(
                        "Your payment has been processed successfully.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kTextGrey,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // PAYMENT DETAILS
                      // ==================================================

                      Container(
                        width: double.infinity,
                        decoration:
                            neumorphicDecoration(
                          radius: 22,
                        ),

                        child: Column(
                          children: [
                            _buildRow(
                              icon:
                                  Icons.phone_outlined,
                              title:
                                  "Mobile Number",
                              value:
                                  mobileNumber,
                            ),
                            SizedBox(
                              height: 12,
                            ),

                            _divider(),

                            _buildRow(
                              icon:
                                  Icons.currency_rupee,
                              title: "Amount",
                              value:
                                  "₹$amount",
                            ),
                            SizedBox(
                              height: 12,
                            ),


                            _divider(),

                            _buildRow(
                              icon: Icons
                                  .check_circle_outline,
                              title: "Status",
                              value: "Success",
                              isSuccess: true,
                            ),
                            SizedBox(
                              height: 12,
                            ),


                            _divider(),

                            _buildRow(
                              icon: Icons
                                  .calendar_today_outlined,
                              title: "Date",
                              value:
                                  "${DateTime.now().day.toString().padLeft(2, '0')}/"
                                  "${DateTime.now().month.toString().padLeft(2, '0')}/"
                                  "${DateTime.now().year}",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      // ==================================================
                      // DONE BUTTON
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 58,

                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _onDonePressed(
                            context,
                          ),

                          icon: const Icon(
                            Icons.done_rounded,
                            size: 21,
                          ),

                          label: const Text(
                            "Done",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                kWhite,
                            foregroundColor:
                                kBackground,
                            elevation: 0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // SECURITY TEXT
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons
                                .lock_outline_rounded,
                            color: kTextGrey,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Transaction securely saved",
                            style: TextStyle(
                              color: kTextGrey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
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

  // ============================================================
  // DIVIDER
  // ============================================================

  static Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      color: Colors.white10,
    );
  }
}