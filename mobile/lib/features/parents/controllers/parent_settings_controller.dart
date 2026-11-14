import 'package:flutter/foundation.dart';
import 'package:koini/services/koini_store.dart';

class ParentSettingsController extends ChangeNotifier {
  ParentSettingsController(this.store);

  final KoiniStore store;
  late bool reminders = store.reminders;
  late bool stories = store.stories;
  bool busy = false;
  bool _disposed = false;

  void setReminders(bool value) {
    reminders = value;
    notifyListeners();
  }

  void setStories(bool value) {
    stories = value;
    notifyListeners();
  }

  Future<String?> save() async {
    if (busy) return 'Koini sedang menyimpan. Coba lagi sebentar.';
    busy = true;
    notifyListeners();
    try {
      return await store.settings(
        reminders: reminders,
        stories: stories && store.hasPlus,
      );
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
