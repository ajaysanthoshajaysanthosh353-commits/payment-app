import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:payment_app/verify_pin_screen.dart';

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
      backgroundColor: Color.fromARGB(255, 12, 202, 12),

      appBar: AppBar(
        title: Text('Confirm Payment', style: GoogleFonts.nunitoSans()),
        backgroundColor: Color(0xFF101510),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42)),
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
                backgroundColor: Color.fromARGB(255, 201, 223, 206),
                child: Icon(Icons.person, size: 40, color: Color(0xFF35D66F)),
              ),

              const SizedBox(height: 16),

              // Recipient Name
              Text(
                personName,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // Mobile Number
              Text(
                mobileNumber,
                style: GoogleFonts.nunitoSans(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              Text(
                'Payment Amount',
                style: GoogleFonts.nunitoSans(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 10),

              // Amount
              Text(
                '₹$amount',
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // Payment Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 0, 1),
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
              Text(
                'Review the recipient and amount before proceeding.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              // Proceed Button
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerifyPinScreen(
                          receiver: personName,
                          amount: amount.toString(),
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Payment backend approval and PIN verification are not connected yet.',
                          selectionColor: Colors.black,
                        ),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 4, 8, 4),
                    foregroundColor: const Color.fromRGBO(255, 236, 236, 1),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: Text(
                    'Done',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
