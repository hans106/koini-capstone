import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class PlusPackagesViewModel extends StoreViewModel {
  PlusPackagesViewModel(this._store) : _selected = _store.plan, super(_store);
  final KoiniStore _store;
  Plan _selected;
  bool _confirming = false;

  Plan get selected => _selected;
  Plan get current => _store.plan;
  bool get canConfirm => !_confirming && selected != current;

  void select(Plan value) {
    _selected = value;
    changed();
  }

  bool beginConfirmation() {
    if (!canConfirm) return false;
    _confirming = true;
    changed();
    return true;
  }

  void endConfirmation() {
    _confirming = false;
    changed();
  }

  /// Area orang tua sudah dibuka dengan PIN, jadi paket langsung diaktifkan.
  Future<bool> activate(Plan plan) => submit(() => _store.activatePlan(plan));

  Future<String?> verify(Plan plan, String pin) async {
    if (busy) return 'Koini sedang menyimpan. Coba lagi sebentar.';
    await submit(() => _store.activatePlan(plan, pin));
    return error;
  }
}

class ActivePlanViewModel extends StoreViewModel {
  ActivePlanViewModel(this._store) : super(_store);

  final KoiniStore _store;

  Plan get plan => _store.plan;
  bool get hasYearly => _store.hasYearly;
  Dream? get activeDream => _store.activeDream;
}
