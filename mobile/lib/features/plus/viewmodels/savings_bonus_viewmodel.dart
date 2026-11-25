import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class SavingsBonusViewModel extends StoreViewModel {
  SavingsBonusViewModel(this._store, {required this.parentMode})
    : super(_store);

  final KoiniStore _store;
  final bool parentMode;

  int _bonusAmount = 5000;
  int _minSavings = 50000;
  int _durationDays = 30;

  List<SavingsBonus> get bonuses => _store.bonuses;
  int get currentTabung => _store.balance(Jar.tabung);
  int get bonusAmount => _bonusAmount;
  int get minSavings => _minSavings;
  int get durationDays => _durationDays;

  void setBonusAmount(String value) => _bonusAmount = int.tryParse(value) ?? 0;
  void setMinSavings(String value) => _minSavings = int.tryParse(value) ?? 0;

  void setDurationDays(int days) {
    _durationDays = days;
    changed();
  }

  Future<bool> create() {
    final start = dayStart(_store.now);
    final end = start.add(Duration(days: _durationDays));
    return submit(
      () => _store.addSavingsBonus(
        bonusAmount: _bonusAmount,
        minSavings: _minSavings,
        startDate: start,
        endDate: end,
      ),
    );
  }

  Future<bool> resolve(String id, {required bool succeeded}) =>
      submit(() => _store.resolveSavingsBonus(id, succeeded: succeeded));
}
