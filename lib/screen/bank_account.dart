import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payment_app/link_bank_screen.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  bool isBankLinked = false;
  bool isLoading = true;
  bool isUpdating = false;
  String? bankName;
  String? accountHolderName;
  String? accountLastFour;
  String? loadError;

  // ECpay colors
  static const Color primaryGreen = Color.fromARGB(255, 0, 194, 0);
  static const Color darkGreen = Color.fromARGB(255, 0, 0, 0);
  static const Color backgroundColor = Color(0xFFF5FFF8);

  @override
  void initState() {
    super.initState();
    loadBankAccount();
  }

  Future<void> loadBankAccount() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        loadError = 'Please log in to manage your bank account.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final Map<String, dynamic>? data = snapshot.data();
      final dynamic storedBankName = data?['bankName'];
      final dynamic storedAccountHolder = data?['accountHolderName'];
      final dynamic storedLastFour = data?['bankAccountLastFour'];
      if (!mounted) return;
      setState(() {
        isBankLinked = data?['bankSetupDemoComplete'] == true;
        bankName = storedBankName is String ? storedBankName : null;
        accountHolderName = storedAccountHolder is String
            ? storedAccountHolder
            : null;
        accountLastFour = storedLastFour is String ? storedLastFour : null;
      });
    } catch (error) {
      debugPrint('Failed to load bank account: $error');
      if (!mounted) return;
      setState(() {
        loadError = 'Could not load your bank account. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> manageBankAccount() async {
    if (isBankLinked) {
      await unlinkBankAccount();
      return;
    }

    final bool? linked = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const LinkBankScreen()),
    );
    if (linked == true) {
      await loadBankAccount();
    }
  }

  Future<void> unlinkBankAccount() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink bank account?'),
        content: const Text(
          'This removes the saved bank-link status from your ECpay profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showMessage('Please log in first.');
      return;
    }

    setState(() {
      isUpdating = true;
    });
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'bankSetupDemoComplete': false,
        'bankName': FieldValue.delete(),
        'accountHolderName': FieldValue.delete(),
        'bankAccountLastFour': FieldValue.delete(),
        'bankLinkedAt': FieldValue.delete(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {
        isBankLinked = false;
        bankName = null;
        accountHolderName = null;
        accountLastFour = null;
      });
      showMessage('Bank account unlinked.');
    } on FirebaseException catch (error) {
      if (!mounted) return;
      showMessage(
        'Could not unlink bank account: ${error.message ?? error.code}',
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: Text(
          'Bank Account',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Heading
              Text(
                'Manage Your Bank',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Manage your linked bank account securely '
                'with ECpay.',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 25),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (loadError != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        loadError!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(color: Colors.redAccent),
                      ),
                      TextButton(
                        onPressed: loadBankAccount,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              // Bank account card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryGreen.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withValues(alpha: 0.10),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank icon and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: darkGreen,
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bankName ?? 'ECpay Bank Account',
                                style: GoogleFonts.roboto(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                isBankLinked
                                    ? '${accountHolderName ?? 'Account holder'}'
                                          '${accountLastFour == null ? '' : ' •••• $accountLastFour'}'
                                    : 'No bank account details saved',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    const Divider(),

                    const SizedBox(height: 15),

                    // Account status
                    Row(
                      children: [
                        Icon(
                          isBankLinked
                              ? Icons.check_circle
                              : Icons.account_balance_outlined,
                          color: isBankLinked ? primaryGreen : Colors.orange,
                          size: 23,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            isLoading
                                ? 'Loading account status'
                                : isBankLinked
                                ? 'Account details linked'
                                : 'No Account Linked',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isBankLinked
                                  ? darkGreen
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isBankLinked
                                ? primaryGreen.withValues(alpha: 0.12)
                                : Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isBankLinked ? 'LINKED' : 'NOT LINKED',
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isBankLinked
                                  ? darkGreen
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Security information
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: darkGreen,
                            size: 23,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              'Secure account management. '
                              'Keep your banking information private.',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Link / unlink button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isLoading || isUpdating || loadError != null
                            ? null
                            : manageBankAccount,

                        icon: Icon(
                          isUpdating
                              ? Icons.hourglass_top
                              : isBankLinked
                              ? Icons.link_off
                              : Icons.add_link,
                          color: Colors.white,
                        ),

                        label: Text(
                          isUpdating
                              ? 'Please wait...'
                              : isBankLinked
                              ? 'Unlink Account'
                              : 'Link Bank Account',
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBankLinked
                              ? Colors.redAccent
                              : primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Information card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 28,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important Information',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'This demo validates account details format only. '
                            'It does not connect to a bank or verify account '
                            'ownership. Full account numbers are not stored '
                            'in ECpay.',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
