import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class JarDetailViewModel extends StoreViewModel {
  JarDetailViewModel(this._store, this.jar) : super(_store);
  final KoiniStore _store;
  final Jar jar;

  EntryKind get kind => switch (jar) {
    Jar.tabung => EntryKind.save,
    Jar.jajan => EntryKind.spend,
    Jar.berbagi => EntryKind.give,
  };
  Jar get transferDestination => jar == Jar.jajan ? Jar.tabung : Jar.jajan;
  int get balance => _store.balance(jar);
  int get availableSavings => _store.availableSavings;
  Iterable<MoneyEntry> get entries => _store.entries.where(
    (entry) =>
        entry.changes.containsKey(jar) ||
        (jar == Jar.tabung && entry.dreamId != null),
  );
}
