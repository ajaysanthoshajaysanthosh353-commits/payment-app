import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    setState(() => loading = true);

    try {
      final allowed = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      if (!mounted) return;

      if (allowed != PermissionStatus.granted) {
        setState(() => permissionDenied = true);
        return;
      }

      final result = await FlutterContacts.getAll();

      if (!mounted) return;

      setState(() {
        contacts = result;
        filteredContacts = result;
      });
    } catch (e) {
      debugPrint('Contact error: $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

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

  void selectContact(Contact contact) {
    if (contact.phones.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No phone number found')));
      return;
    }

    setState(() {
      nameController.text = contact.displayName ?? '';
      mobileController.text = contact.phones.first.number;
    });
  }

  void continuePayment() {
    final name = nameController.text.trim();
    final mobile = mobileController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = amountController.text.trim();

    final normalizedMobile = mobile.length > 10
        ? mobile.substring(mobile.length - 10)
        : mobile;

    final parsedAmount = double.tryParse(amount);

    if (name.isEmpty ||
        !RegExp(r'^[6-9][0-9]{9}$').hasMatch(normalizedMobile) ||
        parsedAmount == null ||
        !parsedAmount.isFinite ||
        parsedAmount <= 0 ||
        parsedAmount != parsedAmount.roundToDouble()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid recipient and whole-rupee amount'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmPaymentScreen(
          personName: name,
          mobileNumber: normalizedMobile,
          amount: parsedAmount.toInt(),
        ),
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFF35D66F)),
        filled: true,
        fillColor: const Color(0xFF202820),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101510),
      appBar: AppBar(
        title: const Text('Send Money'),
        backgroundColor: const Color(0xFF101510),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find a person',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              inputField(
                controller: searchController,
                hint: 'Search contacts',
                icon: CupertinoIcons.search,
              ),

              const SizedBox(height: 16),

              inputField(
                controller: nameController,
                hint: 'Person name',
                icon: CupertinoIcons.person,
              ),

              const SizedBox(height: 12),

              inputField(
                controller: mobileController,
                hint: 'Mobile number',
                icon: CupertinoIcons.phone,
                keyboard: TextInputType.phone,
              ),

              const SizedBox(height: 12),

              inputField(
                controller: amountController,
                hint: 'Amount in ₹',
                icon: CupertinoIcons.money_dollar_circle,
                keyboard: TextInputType.number,
              ),

              const SizedBox(height: 20),

              const Text(
                'Phone Contacts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF35D66F),
                        ),
                      )
                    : permissionDenied
                    ? Center(
                        child: TextButton(
                          onPressed: loadContacts,
                          child: const Text('Allow contact access / Try again'),
                        ),
                      )
                    : ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchController,
                        builder: (context, value, child) {
                          return ListView.builder(
                            itemCount: filteredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = filteredContacts[index];

                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF263B2B),
                                  child: Icon(
                                    CupertinoIcons.person,
                                    color: Color(0xFF35D66F),
                                  ),
                                ),
                                title: Text(
                                  contact.displayName ?? 'Unnamed contact',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  contact.phones.isNotEmpty
                                      ? contact.phones.first.number
                                      : 'No phone number',
                                  style: const TextStyle(color: Colors.white60),
                                ),
                                onTap: () => selectContact(contact),
                              );
                            },
                          );
                        },
                      ),
              ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: continuePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35D66F),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
