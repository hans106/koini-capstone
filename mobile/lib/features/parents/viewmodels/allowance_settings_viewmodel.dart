import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class AllowanceSettingsViewModel extends ViewModel {
  AllowanceSettingsViewModel(this._store)
    : _total = _store.allowance,
      _limit = _store.dailyLimit,
      _split = Map.of(_store.split);

  final KoiniStore _store;
  int _total;
  int _limit;
  Map<Jar, int> _split;

  int get total => _total;
  int get limit => _limit;
  Map<Jar, int> get split => Map.unmodifiable(_split);

  void changeAmount(String value) {
    _total = int.tryParse(value) ?? 0;
    _split = KoiniStore.defaultSplit(_total);
    changed();
  }

  void changeLimit(String value) => _limit = int.tryParse(value) ?? 0;
  void changeSplit(Map<Jar, int> value) => _split = Map.of(value);

  Future<bool> save() =>
      submit(() => _store.setAllowance(_total, _limit, _split));
}
