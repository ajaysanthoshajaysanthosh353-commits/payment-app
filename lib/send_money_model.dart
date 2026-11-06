class SendMoneyModel {
  final String receiverName;
  final String mobileNumber;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  SendMoneyModel({
    required this.receiverName,
    required this.mobileNumber,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'receiverName': receiverName,
      'mobileNumber': mobileNumber,
      'amount': amount,
      'currency': currency,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SendMoneyModel.fromMap(Map<String, dynamic> map) {
    return SendMoneyModel(
      receiverName: map['receiverName'] as String? ?? '',
      mobileNumber: map['mobileNumber'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'INR',
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
