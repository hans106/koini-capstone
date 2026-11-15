import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class GiftSeasonViewModel extends StoreViewModel {
  GiftSeasonViewModel(this._store) : super(_store);
  final KoiniStore _store;

  int _total = 0;
  int _held = 0;
  final _parts = {for (final jar in Jar.values) jar: 0};

  int get heldGift => _store.heldGift;
  int get remainder =>
      _total - _held - _parts.values.fold<int>(0, (a, b) => a + b);

  void changeTotal(String value) {
    _total = int.tryParse(value) ?? 0;
    changed();
  }

  void changeHeld(String value) {
    _held = int.tryParse(value) ?? 0;
    changed();
  }

  void changePart(Jar jar, String value) {
    _parts[jar] = int.tryParse(value) ?? 0;
    changed();
  }

  Future<bool> save(String name) {
    final memo = name.trim();
    return submit(
      () => _store.recordGift(
        _total,
        Map.of(_parts),
        _held,
        memo.isEmpty ? 'Uang hadiah' : memo,
      ),
    );
  }
}

class GiftReleaseViewModel extends StoreViewModel {
  GiftReleaseViewModel(this._store) : super(_store);
  final KoiniStore _store;
  Jar _destination = Jar.tabung;

  Jar get destination => _destination;
  int get heldGift => _store.heldGift;

  void selectDestination(Jar value) {
    _destination = value;
    changed();
  }

  Future<bool> save(String amount) =>
      submit(() => _store.releaseGift(int.tryParse(amount) ?? 0, destination));
}
