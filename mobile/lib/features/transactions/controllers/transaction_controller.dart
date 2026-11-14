import 'package:flutter/foundation.dart';
import 'package:koini/core/utils/keypad_value.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

const categories = ['Makanan', 'Sekolah', 'Hiburan', 'Transportasi', 'Lainnya'];

class TransactionController extends ChangeNotifier {
  TransactionController(
    this.store, {
    required this.kind,
    this.dream,
    Jar? destination,
    Jar? source,
  }) : destination = destination ?? Jar.jajan,
       source = source ?? Jar.jajan;

  final KoiniStore store;
  EntryKind kind;
  Dream? dream;
  Jar destination;
  Jar source;
  Jar? savingSource = Jar.tabung;
  String _digits = '';
  String category = categories.first;
  bool _busy = false;

  bool get busy => _busy;
  int get amount => int.tryParse(_digits) ?? 0;
  bool get completed =>
      kind == EntryKind.save && dream != null && store.remaining(dream!) == 0;

  void chooseKind(EntryKind value) {
    kind = value;
    notifyListeners();
  }

  void chooseDream(Dream? value) {
    dream = value;
    notifyListeners();
  }

  void chooseSource(Jar value) {
    source = value;
    notifyListeners();
  }

  void chooseDestination(Jar value) {
    destination = value;
    notifyListeners();
  }

  void chooseSavingSource(Jar? value) {
    savingSource = value;
    notifyListeners();
  }

  void chooseCategory(String value) {
    category = value;
    notifyListeners();
  }

  void enterDigit(String value) {
    if (_busy) return;
    _digits = keypadValue(_digits, value, 9);
    notifyListeners();
  }

  Future<String?> save(String note) async {
    if (_busy) return 'Koini sedang menyimpan. Coba lagi sebentar.';
    _busy = true;
    notifyListeners();
    final error = await store.record(
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
      category: kind == EntryKind.spend && store.hasPlus ? category : null,
    );
    if (error != null) {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
    return error;
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
