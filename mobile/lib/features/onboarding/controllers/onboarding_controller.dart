import 'package:flutter/widgets.dart';
import 'package:koini/core/utils/keypad_value.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

enum OnboardingStep { login, profile, settings, split, ready }

class OnboardingController extends ChangeNotifier {
  OnboardingController(this.store, {required this.step, bool demo = false}) {
    if (demo && step.index >= OnboardingStep.settings.index) {
      name.text = 'Raka';
      consent = true;
    }
    if (demo && step.index >= OnboardingStep.split.index) {
      pin = '123456';
      confirmation = pin;
    }
  }

  final KoiniStore store;
  OnboardingStep step;
  final name = TextEditingController();
  final email = TextEditingController();
  final allowance = TextEditingController(text: '100000');
  final limit = TextEditingController(text: '10000');
  Map<Jar, int>? _split;
  bool consent = false;
  bool reminders = false;
  bool busy = false;
  int age = 9;
  String? error;
  String pin = '';
  String confirmation = '';
  bool _disposed = false;

  int get amount => int.tryParse(allowance.text) ?? 0;
  int get dailyLimit => int.tryParse(limit.text) ?? 0;
  Map<Jar, int> get split => _split ??= KoiniStore.defaultSplit(amount);
  void setConsent(bool value) {
    consent = value;
    notifyListeners();
  }

  void setAge(int value) {
    age = value;
    notifyListeners();
  }

  void setReminders(bool value) {
    reminders = value;
    notifyListeners();
  }

  void setSplit(Map<Jar, int> value) => _split = value;
  void resetSplit() => _split = null;

  void enterPinDigit(String key) {
    if (pin.length < 6 || (key == 'Hapus' && confirmation.isEmpty)) {
      pin = keypadValue(pin, key, 6);
    } else {
      confirmation = keypadValue(confirmation, key, 6);
    }
    notifyListeners();
  }

  bool back() {
    if (step == OnboardingStep.login) return false;
    step = OnboardingStep.values[step.index - 1];
    error = null;
    notifyListeners();
    return true;
  }

  String? _validate() {
    switch (step) {
      case OnboardingStep.login:
        if (!consent) return 'Centang persetujuan orang tua untuk melanjutkan.';
      case OnboardingStep.profile:
        if (name.text.trim().isEmpty) {
          return 'Isi nama panggilan anak terlebih dahulu.';
        }
      case OnboardingStep.settings:
        if (amount < 1 || dailyLimit < 1) {
          return 'Isi uang saku dan batas jajan harian.';
        }
        final address = email.text.trim();
        if (address.isNotEmpty &&
            !RegExp(r'^\S+@\S+\.\S+$').hasMatch(address)) {
          return 'Periksa alamat email Ayah/Bunda.';
        }
        if (pin.length != 6 || pin != confirmation) {
          return 'Masukkan PIN 6 angka dan ulangi PIN yang sama.';
        }
      case OnboardingStep.split:
        if (split.values.fold<int>(0, (sum, value) => sum + value) != amount) {
          return 'Bagi seluruh uang saku ke tiga toples.';
        }
      case OnboardingStep.ready:
        break;
    }
    return null;
  }

  Future<bool> next() async {
    if (busy) return false;
    error = _validate();
    if (error != null) {
      notifyListeners();
      return false;
    }
    if (step != OnboardingStep.ready) {
      step = OnboardingStep.values[step.index + 1];
      notifyListeners();
      return false;
    }
    busy = true;
    notifyListeners();
    error = await store.setUp(
      name: name.text,
      age: age,
      email: email.text,
      pin: pin,
      allowance: amount,
      limit: dailyLimit,
      reminders: reminders,
      split: split,
    );
    if (error == null) return true;
    busy = false;
    if (!_disposed) notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _disposed = true;
    for (final field in [name, email, allowance, limit]) {
      field.dispose();
    }
    super.dispose();
  }
}
