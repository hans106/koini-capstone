import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/models/transaction_totals.dart';
import 'package:koini/services/koini_store.dart';

class WeeklySummaryViewModel extends StoreViewModel {
  WeeklySummaryViewModel(this._store) : super(_store);
  final KoiniStore _store;

  TransactionTotals get totals => TransactionTotals.fromEntries(entries);
  List<MoneyEntry> get entries => _store.thisWeek;
  int amount(EntryKind kind) => kind == EntryKind.save
      ? _store.netSavings(entries)
      : _store.amountFor(kind, entries);
}
