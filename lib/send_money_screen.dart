import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';

import 'confirm_payment_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final amountController = TextEditingController();

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];

  bool loading = false;
  bool permissionDenied = false;

  final Color green = const Color.fromARGB(255, 25, 160, 77);
  final Color background = const Color.fromARGB(255, 13, 182, 55);
  final Color cardColor = const Color.fromARGB(255, 0, 0, 0);

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  // LOAD PHONE CONTACTS
  Future<void> loadContacts() async {
    setState(() {
      loading = true;
      permissionDenied = false;
    });

    try {
      final permission = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      if (!mounted) return;

      if (permission != PermissionStatus.granted) {
        setState(() {
          permissionDenied = true;
        });
        return;
      }

      final result = await FlutterContacts.getAll(
        properties: {ContactProperty.phone},
      );

      if (!mounted) return;

      setState(() {
        contacts = result;
        filteredContacts = result;
      });
    } catch (e) {
      debugPrint('Contact loading error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load phone contacts')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // PERFECT REAL-TIME SEARCH
  void searchContacts(String query) {
    final search = query.toLowerCase().trim();

    final digits = query.replaceAll(RegExp(r'[^0-9]'), '');

    setState(() {
      filteredContacts = contacts.where((contact) {
        final name = (contact.displayName ?? '').toLowerCase();

        final phoneMatch = contact.phones.any((phone) {
          final number = phone.number.replaceAll(RegExp(r'[^0-9]'), '');

          return digits.isNotEmpty && number.contains(digits);
        });

        return name.contains(search) || phoneMatch;
      }).toList();
    });
  }

  // SELECT CONTACT
  void selectContact(Contact contact) {
    if (contact.phones.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No phone number found')));
      return;
    }

    final displayName = (contact.displayName ?? '').trim();
    final selectedPhone = contact.phones.first.number.trim();

    setState(() {
      nameController.text = displayName.isNotEmpty
          ? displayName
          : 'Unknown Contact';
      mobileController.text = selectedPhone;

      searchController.text = displayName;
      filteredContacts = contacts;
    });

    FocusScope.of(context).unfocus();
  }

  // INPUT FIELD
  Widget inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(
        color: Color.fromRGBO(241, 223, 223, 1),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromRGBO(224, 213, 213, 1)),
        prefixIcon: Icon(icon, color: Color(0xFFD2DDD6)),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 238, 217, 217).withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color.fromRGBO(255, 243, 243, 0.973),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // CUSTOM SEARCH BAR
  Widget searchBar() {
    return TextField(
      controller: searchController,
      onChanged: searchContacts,
      style: const TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Search name or mobile number',
        hintStyle: GoogleFonts.nunitoSans(
          color: Color.fromRGBO(238, 225, 225, 0.537),
          fontSize: 18,
        ),
        prefixIcon: Icon(CupertinoIcons.search, color: green),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  CupertinoIcons.clear_circled_solid,
                  color: Color.fromRGBO(0, 0, 0, 0.541),
                ),
                onPressed: () {
                  searchController.clear();
                  searchContacts('');
                  FocusScope.of(context).unfocus();
                },
              )
            : null,
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: green.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: green, width: 1.5),
        ),
      ),
    );
  }

  // CONTINUE PAYMENT
  void continuePayment() {
    final name = nameController.text.trim();

    final mobile = mobileController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final amount = amountController.text.trim();

    final normalizedMobile = mobile.length > 10
        ? mobile.substring(mobile.length - 10)
        : mobile;

    final parsedAmount = double.tryParse(amount);

    if (name.isEmpty) {
      showMessage('Please enter recipient name');
      return;
    }

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(normalizedMobile)) {
      showMessage('Enter a valid 10-digit mobile number');
      return;
    }

    if (parsedAmount == null ||
        !parsedAmount.isFinite ||
        parsedAmount <= 0 ||
        parsedAmount != parsedAmount.roundToDouble()) {
      showMessage('Enter a valid whole-rupee amount');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmPaymentScreen(
          personName: name,
          mobileNumber: normalizedMobile,
          amount: parsedAmount.toInt(),
        ),
      ),
    );
  }

  // SNACKBAR
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Text(
            'Send Money',
            style: GoogleFonts.nunitoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SEARCH BAR
              searchBar(),

              const SizedBox(height: 20),

              // RECIPIENT NAME
              inputField(
                controller: nameController,

                hint: 'Person name',

                icon: CupertinoIcons.person,
              ),

              const SizedBox(height: 12),

              // MOBILE NUMBER
              inputField(
                controller: mobileController,
                hint: 'Mobile number',
                icon: CupertinoIcons.phone,
                keyboard: TextInputType.phone,
              ),

              const SizedBox(height: 23),

              // AMOUNT
              inputField(
                controller: amountController,
                hint: 'Amount in ₹',
                icon: CupertinoIcons.money_dollar_circle,
                keyboard: const TextInputType.numberWithOptions(decimal: false),
              ),

              const SizedBox(height: 22),

              // CONTACT TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phone Contacts',
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${filteredContacts.length} Contacts',
                    style: TextStyle(color: green, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // CONTACT LIST
              Expanded(
                child: loading
                    ? Center(child: CircularProgressIndicator(color: green))
                    : permissionDenied
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.person_crop_circle_badge_exclam,
                              color: Colors.white54,
                              size: 45,
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Contact permission required',
                              style: TextStyle(color: Colors.white),
                            ),

                            TextButton(
                              onPressed: loadContacts,
                              child: Text(
                                'Try Again',
                                style: TextStyle(color: green),
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredContacts.isEmpty
                    ? const Center(
                        child: Text(
                          'No contacts found',
                          style: TextStyle(color: Colors.white54, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredContacts.length,

                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),

                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  210,
                                  255,
                                  220,
                                ),

                                child: Icon(
                                  CupertinoIcons.person_fill,
                                  color: green,
                                ),
                              ),

                              title: Text(
                                contact.displayName ?? 'Unknown contact',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              subtitle: Text(
                                contact.phones.isNotEmpty
                                    ? contact.phones.first.number
                                    : 'No phone number',

                                style: const TextStyle(color: Colors.white60),
                              ),

                              trailing: Icon(
                                CupertinoIcons.arrow_right_circle,
                                color: green,
                              ),

                              onTap: () {
                                selectContact(contact);
                              },
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 15),

              // CONFIRM PAYMENT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: CupertinoButton(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(18),

                  onPressed: continuePayment,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.check_mark_circled,
                        color: Colors.black,
                        size: 21,
                      ),

                      SizedBox(width: 10),

                      Text(
                        'Confirm ',
                        style: GoogleFonts.nunitoSans(
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    nameController.dispose();
    mobileController.dispose();
    amountController.dispose();

    super.dispose();
  }
}
