import 'package:koini/core/utils/keypad_value.dart';
import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

const categories = ['Makanan', 'Sekolah', 'Hiburan', 'Transportasi', 'Lainnya'];

class TransactionViewModel extends StoreViewModel {
  TransactionViewModel(
    this._store, {
    required this._kind,
    this._dream,
    Jar? destination,
    Jar? source,
  }) : _destination = destination ?? Jar.jajan,
       _sourceJar = source ?? Jar.jajan,
       super(_store);

  final KoiniStore _store;
  EntryKind _kind;
  Dream? _dream;
  Jar _destination;
  Jar _sourceJar;
  Jar? _savingSource = Jar.tabung;
  String _digits = '';
  String _category = categories.first;

  EntryKind get kind => _kind;
  Dream? get dream => _dream;
  Jar get destination => _destination;
  Jar get source => _sourceJar;
  Jar? get savingSource => _savingSource;
  String get category => _category;
  int get amount => int.tryParse(_digits) ?? 0;
  bool get completed =>
      kind == EntryKind.save && dream != null && _store.remaining(dream!) == 0;
  int get savedForDream => dream == null ? 0 : _store.savedFor(dream!);
  int get spendingThisWeek =>
      _store.amountFor(EntryKind.spend, _store.thisWeek);
  bool get hasPlus => _store.hasPlus;
  int get availableSavings => _store.availableSavings;
  int balance(Jar jar) => _store.balance(jar);
  Iterable<Dream> get activeDreams =>
      _store.dreams.where((item) => _store.remaining(item) > 0);

  void chooseKind(EntryKind value) {
    _kind = value;
    changed();
  }

  void chooseDream(Dream? value) {
    _dream = value;
    changed();
  }

  void chooseSource(Jar value) {
    _sourceJar = value;
    changed();
  }

  void chooseDestination(Jar value) {
    _destination = value;
    changed();
  }

  void chooseSavingSource(Jar? value) {
    _savingSource = value;
    changed();
  }

  void chooseCategory(String value) {
    _category = value;
    changed();
  }

  void enterDigit(String value) {
    if (busy) return;
    _digits = keypadValue(_digits, value, 9);
    changed();
  }

  Future<bool> save(String note) => submit(
    () => _store.record(
      kind: kind,
      amount: amount,
      note: note,
      source: switch (kind) {
        EntryKind.save when dream != null => savingSource,
        EntryKind.transfer => source,
        _ => null,
      },
      destination: destination,
      dream: kind == EntryKind.save ? dream : null,
      category: kind == EntryKind.spend && hasPlus ? category : null,
    ),
  );
}
