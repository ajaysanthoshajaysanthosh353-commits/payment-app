import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error State
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          // Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No notifications available'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final String title =
                  data['title']?.toString() ?? 'No Title';

              final String message =
                  data['message']?.toString() ?? 'No Message';

              final String receiver =
                  data['receiver']?.toString() ?? 'N/A';

              final String amount =
                  data['amount']?.toString() ?? '0';

              final String status =
                  data['status']?.toString() ?? 'Pending';

              final Timestamp? timestamp =
                  data['timestamp'] as Timestamp?;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message),
                      const SizedBox(height: 4),
                      if (timestamp != null)
                        Text(
                          "${timestamp.toDate()}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Payment Notification',
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Receiver: $receiver'),
                            const SizedBox(height: 8),
                            Text('Amount: ₹$amount'),
                            const SizedBox(height: 8),
                            Text('Status: $status'),
                            const SizedBox(height: 8),
                            Text('Message: $message'),
                            if (timestamp != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${timestamp.toDate()}',
                              ),
                            ],
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}