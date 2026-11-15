import 'package:koini/models/koini_data.dart';

class TransactionTotals {
  const TransactionTotals({
    required this.income,
    required this.expense,
    required this.saved,
  });

  factory TransactionTotals.fromEntries(Iterable<MoneyEntry> entries) {
    var income = 0;
    var expense = 0;
    var saved = 0;
    for (final entry in entries) {
      income += entry.income;
      expense += entry.expense;
      saved += entry.changes[Jar.tabung] ?? 0;
    }
    return TransactionTotals(income: income, expense: expense, saved: saved);
  }

  final int income;
  final int expense;
  final int saved;
}
