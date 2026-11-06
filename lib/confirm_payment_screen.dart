import 'package:flutter/material.dart';

class ConfirmPaymentScreen extends StatelessWidget {
  final String personName;
  final String mobileNumber;
  final int amount;

  const ConfirmPaymentScreen({
    super.key,
    required this.personName,
    required this.mobileNumber,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101510),

      appBar: AppBar(
        title: const Text('Confirm Payment'),
        backgroundColor: const Color(0xFF101510),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30),

              // Recipient Avatar
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF263B2B),
                child: Icon(Icons.person, size: 40, color: Color(0xFF35D66F)),
              ),

              const SizedBox(height: 16),

              // Recipient Name
              Text(
                personName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // Mobile Number
              Text(
                mobileNumber,
                style: const TextStyle(color: Colors.white60, fontSize: 15),
              ),

              const SizedBox(height: 35),

              const Text(
                'Payment amount',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),

              const SizedBox(height: 10),

              // Amount
              Text(
                '₹$amount',
                style: const TextStyle(
                  color: Color(0xFF35D66F),
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // Payment Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF202820),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    detailRow('Recipient', personName),

                    const SizedBox(height: 14),

                    detailRow('Mobile', mobileNumber),

                    const SizedBox(height: 14),

                    detailRow('Amount', '₹$amount'),

                    const SizedBox(height: 14),

                    detailRow('Payment provider', 'Cashfree'),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Information
              const Text(
                'Review the recipient and amount before proceeding.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 20),

              // Proceed Button
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Payment backend approval and PIN verification are not connected yet.',
                        ),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35D66F),
                    foregroundColor: Colors.black,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: const Text(
                    'Proceed to verification',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Payment Detail Row
  Widget detailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(title, style: const TextStyle(color: Colors.white60)),
        ),

        const SizedBox(width: 12),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
