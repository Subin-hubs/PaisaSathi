enum AppTransactionType  { income, expense }

class AppTransaction  {
  final String title;
  final double amount;
  final AppTransactionType  type;
  final String category;
  final DateTime date;
  final String? note;

  AppTransaction ({
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });
}