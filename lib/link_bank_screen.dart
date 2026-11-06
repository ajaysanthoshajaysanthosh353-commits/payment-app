import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class LinkBankScreen extends StatefulWidget {
  const LinkBankScreen({super.key});

  @override
  State<LinkBankScreen> createState() => _LinkBankScreenState();
}

class _LinkBankScreenState extends State<LinkBankScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController confirmAccountController =
      TextEditingController();
  final TextEditingController ifscController = TextEditingController();

  String? selectedBank;
  bool isLoading = false;

  // Visibility toggles for masked fields
  bool _obscureAccountNumber = true;
  bool _obscureConfirmAccountNumber = true;

  // ECpay colors
  static const Color backgroundColor = Color.fromARGB(255, 12, 97, 23);
  static const Color darkColor = Colors.black;
  static const Color primaryGreen = Color.fromARGB(255, 39, 173, 34);
  static const Color lightGreen = Colors.greenAccent;

  // Bank list
  final List<String> banks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Punjab National Bank',
    'Canara Bank',
    'Indian Bank',
    'Other / Co-operative Bank',
  ];

  // ------------------------------------------------------------
  // SHOW MESSAGE
  // ------------------------------------------------------------

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ------------------------------------------------------------
  // VALIDATE BANK ACCOUNT THROUGH PYTHON BACKEND
  // ------------------------------------------------------------

  Future<bool> validateBankAccount() async {
    final String ifsc = ifscController.text.trim().toUpperCase();
    const String configuredApiBaseUrl = String.fromEnvironment(
      'BANK_API_BASE_URL',
    );
    final String defaultHost =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    final String apiBaseUrl = configuredApiBaseUrl.isEmpty
        ? 'http://$defaultHost:8000'
        : configuredApiBaseUrl;
    final Uri url = Uri.parse(
      '${apiBaseUrl.replaceFirst(RegExp(r'/$'), '')}/validate-bank-account',
    );

    final Map<String, dynamic> body = {
      'account_holder_name': nameController.text.trim(),
      'bank_name': selectedBank,
      'account_number': accountController.text.trim(),
      'confirm_account_number': confirmAccountController.text.trim(),
      'ifsc_code': ifsc,
    };

    try {
      final http.Response response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return false;

      dynamic decodedResponse;
      try {
        decodedResponse = jsonDecode(response.body);
      } catch (_) {
        decodedResponse = null;
      }

      // Check if backend returned an error status code
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final String serverErrorMsg = (decodedResponse is Map)
            ? (decodedResponse['message'] ??
                  decodedResponse['detail'] ??
                  'Validation failed.')
            : 'Bank validation failed (${response.statusCode}).';
        showMessage(serverErrorMsg, isError: true);
        return false;
      }

      if (decodedResponse is! Map<String, dynamic>) {
        showMessage(
          'Invalid response from the bank validation server.',
          isError: true,
        );
        return false;
      }

      final String message =
          decodedResponse['message']?.toString() ??
          'Bank validation completed.';
      final bool success = decodedResponse['success'] == true;

      showMessage(message, isError: !success);
      return success;
    } catch (error) {
      showMessage(
        'Cannot connect to bank validation service. Check backend connection.',
        isError: true,
      );
      debugPrint('Bank validation error: $error');
      return false;
    }
  }

  // ------------------------------------------------------------
  // LINK BANK ACCOUNT
  // ------------------------------------------------------------

  Future<void> linkBank() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedBank == null) {
      showMessage('Please select a bank.', isError: true);
      return;
    }

    final String accountNum = accountController.text.trim();
    final String confirmAccountNum = confirmAccountController.text.trim();

    if (accountNum != confirmAccountNum) {
      showMessage('Account numbers do not match.', isError: true);
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showMessage('Please log in first.', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 1. Validate via backend
      final bool isValid = await validateBankAccount();
      if (!isValid) {
        return;
      }

      // 2. Safe extraction of last 4 digits (prevents RangeError)
      final String lastFour = accountNum.length >= 4
          ? accountNum.substring(accountNum.length - 4)
          : accountNum;

      // 3. Save metadata to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'bankSetupDemoComplete': true,
        'bankName': selectedBank,
        'accountHolderName': nameController.text.trim(),
        'bankAccountLastFour': lastFour,
        'bankLinkedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      showMessage('Bank account linked successfully!');
      Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      showMessage(
        'Firebase error: ${error.message ?? error.code}',
        isError: true,
      );
    } catch (error) {
      if (!mounted) return;
      showMessage('Something went wrong. Please try again.', isError: true);
      debugPrint('Link bank error: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // DISPOSE CONTROLLERS
  // ------------------------------------------------------------

  @override
  void dispose() {
    nameController.dispose();
    accountController.dispose();
    confirmAccountController.dispose();
    ifscController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading, // Disallow popping while request is in progress
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Link Bank Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: darkColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          // Fixed: Only round bottom corners to avoid top clipping
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Bank icon
                  const Center(
                    child: Icon(
                      Icons.account_balance_rounded,
                      size: 70,
                      color: Color.fromARGB(255, 190, 207, 188),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Heading
                  const Center(
                    child: Text(
                      'Add Your Bank Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Validate account details for ECpay',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Account holder name
                  _buildLabel('Account Holder Name'),

                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Enter account holder name',
                      Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter account holder name';
                      }
                      if (value.trim().length < 2) {
                        return 'Enter a valid name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  // Bank selection
                  _buildLabel('Select Bank'),

                  DropdownButtonFormField<String>(
                    initialValue: selectedBank,
                    isExpanded: true,
                    dropdownColor: const Color.fromARGB(255, 10, 100, 24),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: _inputDecoration(
                      'Choose your bank',
                      Icons.account_balance,
                    ),
                    items: banks.map((String bank) {
                      return DropdownMenuItem<String>(
                        value: bank,
                        child: Text(bank, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (String? value) {
                            setState(() {
                              selectedBank = value;
                            });
                          },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a bank';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  // Account number
                  _buildLabel('Account Number'),

                  TextFormField(
                    controller: accountController,
                    keyboardType: TextInputType.number,
                    obscureText: _obscureAccountNumber,
                    maxLength: 18,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Enter account number',
                      Icons.credit_card,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureAccountNumber
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureAccountNumber = !_obscureAccountNumber;
                          });
                        },
                      ),
                    ).copyWith(counterText: ''),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter account number';
                      }
                      if (!RegExp(r'^\d{9,18}$').hasMatch(value.trim())) {
                        return 'Enter 9–18 digits';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  // Confirm account number
                  _buildLabel('Confirm Account Number'),

                  TextFormField(
                    controller: confirmAccountController,
                    keyboardType: TextInputType.number,
                    obscureText: _obscureConfirmAccountNumber,
                    maxLength: 18,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Re-enter account number',
                      Icons.verified_user_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmAccountNumber
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmAccountNumber =
                                !_obscureConfirmAccountNumber;
                          });
                        },
                      ),
                    ).copyWith(counterText: ''),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Confirm account number';
                      }
                      if (value.trim() != accountController.text.trim()) {
                        return 'Account numbers do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  // IFSC code
                  _buildLabel('IFSC Code'),

                  TextFormField(
                    controller: ifscController,
                    textCapitalization: TextCapitalization.characters,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    maxLength: 11,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    ],
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Example: SBIN0001234',
                      Icons.code,
                    ).copyWith(counterText: ''),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter IFSC code';
                      }
                      final String ifsc = value.trim().toUpperCase();
                      if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
                        return 'Enter a valid 11-digit IFSC code (e.g., SBIN0001234)';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // Link bank button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : linkBank,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.link_rounded),
                                SizedBox(width: 10),
                                Text(
                                  'Link Account',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: darkColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: lightGreen.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: lightGreen),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ECpay demo: This form does not establish '
                            'a real bank connection or authorize payments.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LABEL WIDGET
  // ------------------------------------------------------------

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INPUT DECORATION
  // ------------------------------------------------------------

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      prefixIcon: Icon(icon, color: lightGreen),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: darkColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color.fromARGB(31, 231, 225, 225)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: lightGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
