import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/features/transactions/viewmodels/transaction_viewmodel.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/models/transaction_totals.dart';
import 'package:koini/services/koini_store.dart';

class TransactionHistoryViewModel extends StoreViewModel {
  TransactionHistoryViewModel(this._store) : super(_store);
  final KoiniStore _store;

  TransactionTotals get totals => TransactionTotals.fromEntries(week);
  List<MoneyEntry> get week => _store.thisWeek;
  Map<DateTime, List<MoneyEntry>> get byDate {
    final groups = <DateTime, List<MoneyEntry>>{};
    for (final entry in _store.entries) {
      (groups[dayStart(entry.date)] ??= []).add(entry);
    }
    return groups;
  }

  String labelFor(DateTime date) =>
      date == dayStart(_store.now) ? 'Hari ini' : dateLabel(date);
}

class StructuredHistoryViewModel extends TransactionHistoryViewModel {
  StructuredHistoryViewModel(super.store);

  EntryKind? _filter;
  EntryKind? get filter => _filter;
  DateTime get firstDay => weekStart(_store.now);

  void select(EntryKind? value) {
    _filter = value;
    changed();
  }

  Iterable<MoneyEntry> get visibleEntries => week.where(
    (entry) =>
        filter == null ||
        (filter == EntryKind.income ? entry.income > 0 : entry.kind == filter),
  );

  Iterable<({EntryKind kind, Jar jar, int amount, int planned, double ratio})>
  get summaries sync* {
    final period = week;
    for (final (kind, jar) in [
      (EntryKind.spend, Jar.jajan),
      (EntryKind.save, Jar.tabung),
      (EntryKind.give, Jar.berbagi),
    ]) {
      if (filter != null && filter != kind) continue;
      final amount = kind == EntryKind.save
          ? _store.netSavings(period)
          : _store.amountFor(kind, period);
      final planned = _store.split[jar]!;
      yield (
        kind: kind,
        jar: jar,
        amount: amount,
        planned: planned,
        ratio: planned == 0 ? 0 : (amount / planned).clamp(0, 1),
      );
    }
  }

  Map<String, int> get spendingByCategory {
    final amounts = <String, int>{};
    for (final entry in week.where((entry) => entry.kind == EntryKind.spend)) {
      final name = entry.category ?? 'Tanpa kategori';
      amounts.update(
        name,
        (value) => value + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }
    return {
      for (final category in [...categories, 'Tanpa kategori'])
        if (amounts.containsKey(category)) category: amounts[category]!,
    };
  }
}
