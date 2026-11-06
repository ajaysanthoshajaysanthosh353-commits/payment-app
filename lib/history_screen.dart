import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

// ============================================================
// ECPAY COLORS
// ============================================================

const Color kBackground = Color.fromRGBO(10, 156, 71, 0.816);
const Color kDark = Color(0xFF000000);
const Color kSurface = Color.fromRGBO(10, 104, 65, 1);
const Color kLightSurface = Color.fromARGB(255, 0, 158, 34);
const Color kWhite = Color.fromARGB(255, 188, 233, 205);
const Color kTextGrey = Color.fromARGB(255, 206, 197, 197);

// ============================================================
// HISTORY SCREEN
// ============================================================

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // DELETE TRANSACTION
  // ==========================================================

  Future<void> deleteTransaction(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(documentId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted successfully'),
          backgroundColor: kSurface,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // DELETE CONFIRMATION
  // ==========================================================

  void showDeleteDialog(String documentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text(
            'Are you sure you want to delete this transaction?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteTransaction(documentId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  String getTransactionDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final DateTime date = timestamp.toDate();

      final String day = date.day.toString().padLeft(2, '0');
      final String month = date.month.toString().padLeft(2, '0');
      final String year = date.year.toString();

      final String hour = (date.hour % 12 == 0 ? 12 : date.hour % 12)
          .toString()
          .padLeft(2, '0');

      final String minute = date.minute.toString().padLeft(2, '0');
      final String period = date.hour >= 12 ? 'PM' : 'AM';

      return '$day/$month/$year $hour:$minute $period';
    }

    return 'Date unavailable';
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Transaction History', style: GoogleFonts.abel()),
          centerTitle: true,
          backgroundColor: kDark,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Please login to view transaction history'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(143, 29, 179, 16),

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        centerTitle: true,
        backgroundColor: kDark,
        foregroundColor: Colors.white,
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: Column(
        children: [
          // ====================================================
          // SEARCH
          // ====================================================
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search receiver...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          searchController.clear();

                          setState(() {
                            searchText = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color.fromARGB(255, 0, 0, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ====================================================
          // FIRESTORE TRANSACTIONS
          // ====================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                List<QueryDocumentSnapshot> transactions = snapshot.data!.docs
                    .toList();

                // ============================================
                // SORT NEWEST FIRST
                // ============================================

                transactions.sort((a, b) {
                  final dynamic aTimestamp = a['timestamp'];
                  final dynamic bTimestamp = b['timestamp'];

                  if (aTimestamp is Timestamp && bTimestamp is Timestamp) {
                    return bTimestamp.compareTo(aTimestamp);
                  }

                  return 0;
                });

                // ============================================
                // SEARCH FILTER
                // ============================================

                transactions = transactions.where((doc) {
                  final Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;

                  final String receiver = (data['receiver'] ?? '')
                      .toString()
                      .toLowerCase();

                  return receiver.contains(searchText);
                }).toList();

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final doc = transactions[index];

                    final Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    final String transactionId = doc.id;

                    final String receiver = (data['receiver'] ?? 'Unknown')
                        .toString();

                    final String amount = (data['amount'] ?? '0').toString();

                    final String status = (data['status'] ?? 'Unknown')
                        .toString();

                    final String date = getTransactionDate(data['timestamp']);

                    final bool isSuccess =
                        status.toLowerCase() == 'success' ||
                        status.toLowerCase() == 'successful' ||
                        status.toLowerCase() == 'completed';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailsScreen(
                                transactionId: transactionId,
                                receiver: receiver,
                                amount: amount,
                                status: status,
                                date: date,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // =================================
                              // ICON
                              // =================================
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: isSuccess
                                    ? const Color.fromARGB(255, 5, 12, 5)
                                    : const Color.fromARGB(255, 51, 30, 30),
                                child: Icon(
                                  isSuccess
                                      ? Icons.check_circle
                                      : Icons.payment,
                                  color: isSuccess ? Colors.green : Colors.red,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(width: 14),

                              // =================================
                              // DETAILS
                              // =================================
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      receiver,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 22, 2, 2),
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSuccess
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // =================================
                              // AMOUNT + DELETE
                              // =================================
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹$amount',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDeleteDialog(transactionId);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TRANSACTION DETAILS SCREEN
// ============================================================

class TransactionDetailsScreen extends StatelessWidget {
  final String transactionId;
  final String receiver;
  final String amount;
  final String status;
  final String date;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
    required this.receiver,
    required this.amount,
    required this.status,
    required this.date,
  });

  // ==========================================================
  // COPY TRANSACTION ID
  // ==========================================================

  Future<void> copyTransactionId(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: transactionId));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction ID copied'),
        backgroundColor: kSurface,
      ),
    );
  }

  // ==========================================================
  // SHARE TRANSACTION
  // ==========================================================

  Future<void> shareTransaction(BuildContext context) async {
    final String message =
        '''
ECpay Payment Receipt

Transaction ID: $transactionId
Receiver: $receiver
Amount: ₹$amount
Status: $status
Date: $date

Thank you for using ECpay.
''';

    try {
      await SharePlus.instance.share(
        ShareParams(text: message, subject: 'ECpay Payment Transaction'),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to share transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuccess =
        status.toLowerCase() == 'success' ||
        status.toLowerCase() == 'successful' ||
        status.toLowerCase() == 'completed';

    return Scaffold(
      backgroundColor: const Color.fromARGB(208, 17, 155, 12),

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        title: Text(
          'Transaction Details',
          style: GoogleFonts.robotoFlex(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        centerTitle: true,
        backgroundColor: kDark,
        foregroundColor: Colors.white,
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ==================================================
            // STATUS ICON
            // ==================================================
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                size: 60,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              isSuccess ? 'Payment Successful' : status,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSuccess
                    ? const Color.fromARGB(255, 201, 223, 202)
                    : Colors.red.shade800,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // DETAILS CARD
            // ==================================================
            Card(
              elevation: 5,
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ==========================================
                    // AMOUNT
                    // ==========================================
                    Text(
                      'Amount',
                      style: GoogleFonts.robotoSerif(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '₹$amount',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const Divider(height: 35, color: Colors.white24),

                    // ==========================================
                    // RECEIVER
                    // ==========================================
                    detailRow(
                      icon: CupertinoIcons.person,
                      title: 'Receiver',
                      value: receiver,
                    ),

                    const SizedBox(height: 20),

                    // ==========================================
                    // STATUS
                    // ==========================================
                    detailRow(
                      icon: CupertinoIcons.check_mark_circled,
                      title: 'Status',
                      value: status,
                    ),

                    const SizedBox(height: 20),

                    // ==========================================
                    // DATE
                    // ==========================================
                    detailRow(
                      icon: CupertinoIcons.calendar_today,
                      title: 'Date',
                      value: date,
                    ),

                    const SizedBox(height: 20),

                    // ==========================================
                    // TRANSACTION ID
                    // ==========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.receipt_long, color: kSurface),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transaction ID',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                transactionId,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            copyTransactionId(context);
                          },
                          icon: const Icon(Icons.copy, color: kSurface),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SHARE TRANSACTION
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  shareTransaction(context);
                },
                icon: const Icon(CupertinoIcons.share),
                label: const Text(
                  'Share Transaction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget detailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kSurface),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
