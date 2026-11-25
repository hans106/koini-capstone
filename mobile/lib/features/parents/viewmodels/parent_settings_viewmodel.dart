import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class ParentSettingsViewModel extends StoreViewModel {
  ParentSettingsViewModel(this._store) : super(_store);

  final KoiniStore _store;
  late bool _reminders = _store.reminders;
  late bool _stories = _store.stories;

  bool get reminders => _reminders;
  bool get stories => hasPlus && _stories;
  bool get hasPlus => _store.hasPlus;
  int get allowance => _store.allowance;
  AllowancePeriod get allowancePeriod => _store.allowancePeriod;
  int get dailyLimit => _store.dailyLimit;
  String get email => _store.email;
  int get rating => _store.rating;

  void setReminders(bool value) {
    _reminders = value;
    changed();
  }

  void setStories(bool value) {
    _stories = value;
    changed();
  }

  Future<bool> save() =>
      submit(() => _store.settings(reminders: _reminders, stories: stories));
}
