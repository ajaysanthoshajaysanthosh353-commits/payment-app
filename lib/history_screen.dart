import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

// ============================================================
// ECPAY COLORS
// ============================================================

const Color kBackground =
    Color.fromRGBO(13, 233, 112, 0.815);

const Color kDark = Color(0xFF000000);

const Color kSurface =
    Color.fromRGBO(10, 104, 65, 1);

const Color kLightSurface =
    Color.fromARGB(255, 0, 158, 34);

const Color kWhite =
    Color.fromARGB(255, 188, 233, 205);

const Color kTextGrey =
    Color.fromARGB(255, 206, 197, 197);

// ============================================================
// HISTORY SCREEN
// ============================================================

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  Future<void> deleteTransaction(
    BuildContext context,
    String transactionId,
    String receiver,
    String amount,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: kWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete Transaction?',
            style: TextStyle(
              color: kDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete the '
            '₹$amount transaction to $receiver?',
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: kDark,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaction deleted successfully',
          ),
          backgroundColor: kSurface,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete transaction: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // HISTORY SCREEN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: kBackground,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: kDark,
        foregroundColor: kWhite,
        elevation: 0,
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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

      body: user == null
          ? const Center(
              child: Text(
                'Please login to view transaction history',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : Column(
              children: [
                // ==================================================
                // SEARCH BOX
                // ==================================================

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(
                      color: kDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search receiver...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: kSurface,
                      ),
                      suffixIcon: searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: kSurface,
                              ),
                              onPressed: () {
                                searchController.clear();

                                setState(() {
                                  searchText = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: kWhite,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: kSurface,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: kDark,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText =
                            value.toLowerCase().trim();
                      });
                    },
                  ),
                ),

                // ==================================================
                // FIRESTORE LIST
                // ==================================================

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('transactions')
                        .where(
                          'userId',
                          isEqualTo: user.uid,
                        )
                        .snapshots(),
                    builder:
                        (context, snapshot) {
                      // ============================================
                      // LOADING
                      // ============================================

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child:
                              CircularProgressIndicator(
                            color: kWhite,
                          ),
                        );
                      }

                      // ============================================
                      // ERROR
                      // ============================================

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(20),
                            child: Text(
                              'Error loading transactions:\n'
                              '${snapshot.error}',
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                color: kWhite,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }

                      // ============================================
                      // DOCUMENTS
                      // ============================================

                      final docs =
                          snapshot.data?.docs ?? [];

                      // ============================================
                      // EMPTY
                      // ============================================

                      if (docs.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons
                                    .receipt_long_outlined,
                                size: 70,
                                color: kWhite,
                              ),
                              SizedBox(height: 15),
                              Text(
                                'No transactions yet',
                                style: TextStyle(
                                  color: kWhite,
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Your payment history will appear here.',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  color:
                                      Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ============================================
                      // SORT NEWEST FIRST
                      // ============================================

                      final transactions =
                          List<QueryDocumentSnapshot>
                              .from(docs);

                      transactions.sort(
                        (a, b) {
                          final aData =
                              a.data()
                                  as Map<String, dynamic>;

                          final bData =
                              b.data()
                                  as Map<String, dynamic>;

                          final aTimestamp =
                              aData['timestamp'];

                          final bTimestamp =
                              bData['timestamp'];

                          if (aTimestamp == null &&
                              bTimestamp == null) {
                            return 0;
                          }

                          if (aTimestamp == null) {
                            return 1;
                          }

                          if (bTimestamp == null) {
                            return -1;
                          }

                          if (aTimestamp is Timestamp &&
                              bTimestamp is Timestamp) {
                            return bTimestamp.compareTo(
                              aTimestamp,
                            );
                          }

                          return 0;
                        },
                      );

                      // ============================================
                      // SEARCH FILTER
                      // ============================================

                      final filtered =
                          transactions.where((doc) {
                        final data =
                            doc.data()
                                as Map<String, dynamic>;

                        final receiver =
                            data['receiver']
                                    ?.toString()
                                    .toLowerCase() ??
                                '';

                        return receiver.contains(
                          searchText,
                        );
                      }).toList();

                      // ============================================
                      // NO SEARCH RESULT
                      // ============================================

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 65,
                                color: kWhite,
                              ),
                              SizedBox(height: 15),
                              Text(
                                'No matching transactions',
                                style: TextStyle(
                                  color: kWhite,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ============================================
                      // LIST
                      // ============================================

                      return ListView.builder(
                        padding:
                            const EdgeInsets.only(
                          bottom: 20,
                        ),
                        itemCount: filtered.length,
                        itemBuilder:
                            (context, index) {
                          final doc =
                              filtered[index];

                          final data =
                              doc.data()
                                  as Map<String, dynamic>;

                          // Existing Firestore document ID
                          final String transactionId =
                              doc.id;

                          final String receiver =
                              data['receiver']
                                      ?.toString() ??
                                  'Unknown';

                          final String amount =
                              data['amount']
                                      ?.toString() ??
                                  '0';

                          final String status =
                              data['status']
                                      ?.toString() ??
                                  'Success';

                          final dynamic timestamp =
                              data['timestamp'];

                          // ==========================================
                          // DATE
                          // ==========================================

                          String dateText =
                              'Date unavailable';

                          if (timestamp
                              is Timestamp) {
                            final date =
                                timestamp.toDate();

                            dateText =
                                '${date.day.toString().padLeft(2, '0')}/'
                                '${date.month.toString().padLeft(2, '0')}/'
                                '${date.year}';
                          }

                          // ==========================================
                          // TRANSACTION CARD
                          // ==========================================

                          return Card(
                            margin:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            elevation: 5,
                            color: kWhite,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),

                              // ====================================
                              // ICON
                              // ====================================

                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration:
                                    const BoxDecoration(
                                  color: kSurface,
                                  shape:
                                      BoxShape.circle,
                                ),
                                child:
                                    const Icon(
                                  Icons.payment,
                                  color: kWhite,
                                  size: 25,
                                ),
                              ),

                              // ====================================
                              // RECEIVER
                              // ====================================

                              title: Text(
                                receiver,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color: kDark,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              // ====================================
                              // STATUS + DATE
                              // ====================================

                              subtitle: Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  top: 5,
                                ),
                                child: Text(
                                  '$dateText • $status',
                                  style: TextStyle(
                                    color: status
                                                .toLowerCase() ==
                                            'success'
                                        ? kSurface
                                        : Colors.red,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),

                              // ====================================
                              // AMOUNT + DELETE
                              // ====================================

                              trailing: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Text(
                                    '₹$amount',
                                    style:
                                        const TextStyle(
                                      color: kDark,
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon:
                                        const Icon(
                                      Icons
                                          .delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      deleteTransaction(
                                        context,
                                        transactionId,
                                        receiver,
                                        amount,
                                      );
                                    },
                                  ),
                                ],
                              ),

                              // ====================================
                              // OPEN DETAILS
                              // ====================================

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            TransactionDetailsScreen(
                                      transactionId:
                                          transactionId,
                                      receiver:
                                          receiver,
                                      amount:
                                          amount,
                                      status:
                                          status,
                                      date:
                                          dateText,
                                    ),
                                  ),
                                );
                              },
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

class TransactionDetailsScreen
    extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final bool isSuccess =
        status.toLowerCase() == 'success';

    // ==========================================================
    // SHARE MESSAGE
    // ==========================================================

    final String message =
        '''
ECpay Payment Transaction Details

Transaction ID: $transactionId
Receiver: $receiver
Amount: ₹$amount
Status: $status
Date: $date

Thank you for using ECpay Payment App!
''';

    return Scaffold(
      backgroundColor: kBackground,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Transaction Details',
        ),
        centerTitle: true,
        backgroundColor: kDark,
        foregroundColor: kWhite,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==================================================
            // STATUS SECTION
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 35,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: isSuccess
                    ? Colors.green
                    : Colors.red,
                borderRadius:
                    const BorderRadius.only(
                  bottomLeft:
                      Radius.circular(30),
                  bottomRight:
                      Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    isSuccess
                        ? 'Payment Successful'
                        : 'Payment Failed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // TRANSACTION INFORMATION
            // ==================================================

            Card(
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              elevation: 4,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  // Transaction ID
                  Row(
                    children: [
                      Expanded(
                        child: _detailRow(
                          Icons.receipt_long,
                          'Transaction ID',
                          transactionId,
                        ),
                      ),
                      IconButton(
                        tooltip:
                            'Copy Transaction ID',
                        icon:
                            const Icon(Icons.copy),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: transactionId,
                            ),
                          );

                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Transaction ID copied to clipboard',
                              ),
                              backgroundColor:
                                  kSurface,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  _detailRow(
                    Icons.person,
                    'Receiver',
                    receiver,
                  ),

                  _detailRow(
                    Icons.currency_rupee,
                    'Amount',
                    '₹$amount',
                  ),

                  _detailRow(
                    isSuccess
                        ? Icons.check_circle
                        : Icons.cancel,
                    'Status',
                    status,
                  ),

                  _detailRow(
                    Icons.calendar_today,
                    'Date',
                    date,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // BACK BUTTON
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                  label: const Text(
                    'Back to History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: kDark,
                    foregroundColor: kWhite,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SHARE BUTTON
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child:
                    OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await SharePlus.instance
                          .share(
                        ShareParams(
                          text: message,
                          subject:
                              'ECpay Payment Transaction',
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unable to share transaction: $e',
                          ),
                          backgroundColor:
                              Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.share,
                  ),
                  label: const Text(
                    'Share Transaction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: kDark,
                      width: 2,
                    ),
                    foregroundColor: kDark,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.green,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}