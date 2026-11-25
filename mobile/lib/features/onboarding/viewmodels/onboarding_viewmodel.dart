import 'package:koini/core/utils/keypad_value.dart';
import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

enum OnboardingStep { login, profile, settings, split, ready }

class OnboardingViewModel extends ViewModel {
  OnboardingViewModel(
    this._store, {
    required this._step,
    String name = '',
    String pin = '',
  }) : _name = name,
       _pin = pin,
       _confirmation = pin,
       _consent = name.isNotEmpty;

  final KoiniStore _store;
  OnboardingStep _step;
  String _name;
  String _email = '';
  int _amount = 100000;
  AllowancePeriod _period = AllowancePeriod.weekly;
  int _dailyLimit = 10000;
  Map<Jar, int>? _split;
  bool _consent;
  bool _reminders = false;
  int _age = 9;
  String _pin;
  String _confirmation;

  OnboardingStep get step => _step;
  String get name => _name.trim();
  int get amount => _amount;
  AllowancePeriod get period => _period;
  int get dailyLimit => _dailyLimit;
  Map<Jar, int> get split =>
      Map.unmodifiable(_split ?? KoiniStore.defaultSplit(amount));
  bool get consent => _consent;
  bool get reminders => _reminders;
  int get age => _age;
  int get pinLength => _pin.length;
  int get confirmationLength => _confirmation.length;

  void changeName(String value) => _name = value;
  void changeEmail(String value) => _email = value;
  void changeAllowance(String value) {
    _amount = int.tryParse(value) ?? 0;
    _split = null;
  }

  void changeLimit(String value) => _dailyLimit = int.tryParse(value) ?? 0;

  void setPeriod(AllowancePeriod value) {
    _period = value;
    changed();
  }

  void setConsent(bool value) {
    _consent = value;
    changed();
  }

  void setAge(int value) {
    _age = value;
    changed();
  }

  void setReminders(bool value) {
    _reminders = value;
    changed();
  }

  void setSplit(Map<Jar, int> value) => _split = Map.of(value);

  void enterPinDigit(String key) {
    if (busy) return;
    if (pinLength < 6 || (key == 'Hapus' && _confirmation.isEmpty)) {
      _pin = keypadValue(_pin, key, 6);
    } else {
      _confirmation = keypadValue(_confirmation, key, 6);
    }
    changed();
  }

  bool back() {
    if (step == OnboardingStep.login) return false;
    _step = OnboardingStep.values[step.index - 1];
    showError(null);
    return true;
  }

  String? _validate() {
    switch (step) {
      case OnboardingStep.login:
        if (!consent) return 'Centang persetujuan orang tua untuk melanjutkan.';
      case OnboardingStep.profile:
        if (name.isEmpty) {
          return 'Isi nama panggilan anak terlebih dahulu.';
        }
      case OnboardingStep.settings:
        if (amount < 1 || dailyLimit < 1) {
          return 'Isi uang saku dan batas jajan harian.';
        }
        final address = _email.trim();
        if (address.isNotEmpty &&
            !RegExp(r'^\S+@\S+\.\S+$').hasMatch(address)) {
          return 'Periksa alamat email Ayah/Bunda.';
        }
        if (pinLength != 6 || _pin != _confirmation) {
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
    final validation = _validate();
    if (validation != null) {
      showError(validation);
      return false;
    }
    if (step != OnboardingStep.ready) {
      _step = OnboardingStep.values[step.index + 1];
      showError(null);
      return false;
    }

    return submit(
      () => _store.setUp(
        name: name,
        age: age,
        email: _email,
        pin: _pin,
        allowance: amount,
        period: _period,
        limit: dailyLimit,
        reminders: reminders,
        split: split,
      ),
    );
  }
}
