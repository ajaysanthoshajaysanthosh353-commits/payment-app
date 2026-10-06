class TransactionModel {
  final String receiver;
  final String amount;
  final DateTime date;
  final String status;

  TransactionModel({
    required this.receiver,
    required this.amount,
    DateTime? date,
    this.status = "Success",
  }) : date = date ?? DateTime.now();
}