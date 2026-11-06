import 'package:flutter/material.dart';

// ============================================================
// ECPAY COLORS
// ============================================================

const Color kBackground = Color.fromRGBO(13, 233, 112, 0.815);

const Color kDark = Color(0xFF000000);

const Color kSurface = Color.fromRGBO(17, 90, 53, 1);

const Color kLightSurface = Color.fromARGB(255, 255, 238, 238);

const Color kWhite = Color.fromARGB(255, 236, 255, 250);

const Color kTextGrey = Color.fromARGB(255, 206, 197, 197);

// ============================================================
// TRANSACTION DETAILS SCREEN
// ============================================================

class TransactionDetailsScreen extends StatelessWidget {
  final String receiver;
  final String amount;
  final String status;
  final String date;

  const TransactionDetailsScreen({
    super.key,
    required this.receiver,
    required this.amount,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // TRANSACTION ID
    // ==========================================================

    final String transactionId = 'ECP${DateTime.now().millisecondsSinceEpoch}';

    final bool isSuccess = status.toLowerCase() == 'success';

    return Scaffold(
      backgroundColor: kBackground,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: kWhite),
        ),
        centerTitle: true,

        backgroundColor: kDark,
        foregroundColor: kWhite,

        elevation: 0,

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            const SizedBox(height: 20),

            // ==================================================
            // TRANSACTION ICON
            // ==================================================
            CircleAvatar(
              radius: 45,

              backgroundColor: kSurface,

              child: Icon(
                isSuccess ? Icons.check_circle : Icons.payment,

                size: 60,

                color: kWhite,
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // PAYMENT STATUS
            // ==================================================
            Text(
              isSuccess ? 'Payment Successful' : 'Payment $status',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: isSuccess ? kWhite : Colors.red[700],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // DETAILS CARD
            // ==================================================
            Card(
              elevation: 5,

              color: kWhite,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Column(
                children: [
                  // ============================================
                  // TRANSACTION ID
                  // ============================================
                  _detailRow(
                    icon: Icons.receipt_long,
                    title: 'Transaction ID',
                    value: transactionId,
                  ),

                  const Divider(height: 1),

                  // ============================================
                  // RECEIVER
                  // ============================================
                  _detailRow(
                    icon: Icons.person,
                    title: 'Receiver',
                    value: receiver,
                  ),

                  const Divider(height: 1),

                  // ============================================
                  // AMOUNT
                  // ============================================
                  _detailRow(
                    icon: Icons.currency_rupee,
                    title: 'Amount',
                    value: '₹$amount',
                    valueBold: true,
                  ),

                  const Divider(height: 1),

                  // ============================================
                  // STATUS
                  // ============================================
                  _detailRow(
                    icon: isSuccess ? Icons.check_circle : Icons.cancel,
                    iconColor: isSuccess ? kSurface : Colors.red,
                    title: 'Status',
                    value: status,
                    valueColor: isSuccess ? kSurface : Colors.red,
                  ),

                  const Divider(height: 1),

                  // ============================================
                  // DATE
                  // ============================================
                  _detailRow(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    value: date,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // BACK BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const Icon(Icons.arrow_back),

                label: const Text(
                  'Back to History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: kDark,
                  foregroundColor: kWhite,

                  elevation: 5,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,

    Color iconColor = kSurface,
    Color valueColor = kDark,

    bool valueBold = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      leading: Icon(icon, color: iconColor, size: 27),

      title: Text(
        title,
        style: const TextStyle(
          color: kDark,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),

        child: Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
