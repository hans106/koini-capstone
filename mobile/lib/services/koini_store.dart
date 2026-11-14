import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/koini_data.dart';
import 'koini_storage.dart';

class KoiniStore extends ChangeNotifier {
  KoiniStore(this.storage, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final KoiniStorage storage;
  final DateTime Function() _clock;
  KoiniData _data = KoiniData();
  bool _saving = false;
  int _pinFailures = 0;
  DateTime? _pinLockedUntil;

  DateTime get now => _clock();
  bool get hasProfile => _data.hasProfile;
  String get name => _data.name;
  String get email => _data.email;
  int get age => _data.age;
  int get allowance => _data.allowance;
  int get dailyLimit => _data.dailyLimit;
  Map<Jar, int> get split => Map.unmodifiable(_data.split);
  Plan get plan => _data.plan;
  bool get hasPlus => plan != Plan.free;
  bool get hasYearly => plan == Plan.yearly;
  bool get reminders => _data.reminders;
  bool get alerts => _data.emailAlerts;
  bool get stories => _data.stories;
  int get rating => _data.rating;
  int get heldGift => _data.heldGiftMoney;
  List<Dream> get dreams => List.unmodifiable(_data.dreams);
  List<MoneyEntry> get entries => List.unmodifiable(_data.entries.reversed);
  Map<String, int> get scores => Map.unmodifiable(_data.missionScores);
  int get stars => scores.values.fold(0, (sum, score) => sum + 3 * score);
  int get streak {
    var date = dayStart(now);
    if (!_data.studyDays.contains(_dayKey(date))) {
      date = DateTime(date.year, date.month, date.day - 1);
    }
    var count = 0;
    while (_data.studyDays.contains(_dayKey(date))) {
      count++;
      date = DateTime(date.year, date.month, date.day - 1);
    }
    return count;
  }

  int get longestStreak {
    final days = _data.studyDays.map(DateTime.parse).toList()..sort();
    var longest = 0;
    var current = 0;
    DateTime? previous;
    for (final day in days) {
      final followsPrevious =
          previous != null &&
          day == DateTime(previous.year, previous.month, previous.day + 1);
      current = followsPrevious ? current + 1 : 1;
      longest = max(longest, current);
      previous = day;
    }
    return longest;
  }

  int netSavings(Iterable<MoneyEntry> period) =>
      period.fold(0, (sum, entry) => sum + (entry.changes[Jar.tabung] ?? 0));

  int balance(Jar jar) =>
      _data.entries.fold(0, (sum, item) => sum + (item.changes[jar] ?? 0));
  int get total => Jar.values.fold(0, (sum, jar) => sum + balance(jar));
  int savedFor(Dream dream) => _data.entries
      .where((entry) => entry.dreamId == dream.id)
      .fold(0, (sum, entry) => sum + entry.amount);
  int remaining(Dream dream) => max(0, dream.target - savedFor(dream));
  double progress(Dream dream) =>
      (savedFor(dream) / dream.target).clamp(0.0, 1.0);
  int get availableSavings =>
      balance(Jar.tabung) -
      dreams.fold(0, (sum, dream) => sum + savedFor(dream));
  Dream? get activeDream =>
      dreams.where((dream) => remaining(dream) > 0).firstOrNull ??
      dreams.firstOrNull;
  List<MoneyEntry> get thisWeek =>
      entries.where((entry) => !entry.date.isBefore(weekStart(now))).toList();
  List<MoneyEntry> get thisMonth => entries
      .where(
        (entry) => entry.date.year == now.year && entry.date.month == now.month,
      )
      .toList();
  bool get receivedThisWeek =>
      thisWeek.any((entry) => entry.kind == EntryKind.allowance);
  int get spentToday => entries
      .where(
        (entry) =>
            entry.kind == EntryKind.spend &&
            dayStart(entry.date) == dayStart(now),
      )
      .fold(0, (sum, entry) => sum + entry.amount);
  int amountFor(EntryKind kind, Iterable<MoneyEntry> period) => period
      .where((entry) => entry.kind == kind)
      .fold(0, (sum, entry) => sum + entry.amount);

  Future<void> load() async {
    final saved = await storage.read();
    if (saved != null) {
      _data = KoiniData.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    }
    notifyListeners();
  }

  String? checkPin(String pin) {
    if (_pinLockedUntil?.isAfter(now) ?? false) {
      return 'Terlalu banyak percobaan. Tunggu satu menit.';
    }
    if (_data.pin.isNotEmpty && pin == _data.pin) {
      _pinFailures = 0;
      _pinLockedUntil = null;
      return null;
    }
    _pinFailures++;
    if (_pinFailures == 5) {
      _pinLockedUntil = now.add(const Duration(minutes: 1));
      _pinFailures = 0;
    }
    return 'PIN belum tepat. Coba lagi, ya.';
  }

  Future<String?> setUp({
    required String name,
    required int age,
    required String email,
    required String pin,
    required int allowance,
    required int limit,
    required bool reminders,
    required Map<Jar, int> split,
  }) => _change((next) {
    if (next.hasProfile) return 'Profil sudah dibuat.';
    if (name.trim().isEmpty || age < 6 || age > 12) {
      return 'Periksa nama dan usia.';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return 'PIN harus terdiri dari 6 angka.';
    }
    next
      ..name = name.trim()
      ..age = age
      ..email = email.trim()
      ..pin = pin
      ..allowance = allowance
      ..dailyLimit = limit
      ..reminders = reminders;
    if (!_validAmount(allowance) ||
        !_validAmount(limit) ||
        Jar.values.any((jar) => (split[jar] ?? -1) < 0) ||
        split.values.fold<int>(0, (a, b) => a + b) != allowance) {
      return 'Bagi seluruh uang saku ke tiga toples.';
    }
    next.split = Map.of(split);
    return null;
  });

  static Map<Jar, int> defaultSplit(int amount) => {
    Jar.tabung: amount * 40 ~/ 100,
    Jar.berbagi: amount * 10 ~/ 100,
    Jar.jajan: amount - amount * 40 ~/ 100 - amount * 10 ~/ 100,
  };

  Future<String?> setAllowance(int amount, int limit, Map<Jar, int> split) =>
      _change((next) {
        if (!_validAmount(amount) ||
            !_validAmount(limit) ||
            Jar.values.any((jar) => (split[jar] ?? -1) < 0) ||
            split.values.fold<int>(0, (a, b) => a + b) != amount) {
          return 'Bagi seluruh uang saku ke tiga toples.';
        }
        next
          ..allowance = amount
          ..dailyLimit = limit
          ..split = Map.of(split);
        return null;
      });

  Future<String?> receiveAllowance() => _change((next) {
    if (receivedThisWeek) return 'Uang saku minggu ini sudah tercatat.';
    next.entries.add(
      MoneyEntry(
        kind: EntryKind.allowance,
        amount: allowance,
        date: now,
        note: 'Uang saku mingguan',
        changes: Map.unmodifiable(split),
      ),
    );
    return null;
  });

  Future<String?> record({
    required EntryKind kind,
    required int amount,
    required String note,
    Jar? source,
    Jar? destination,
    Dream? dream,
    String? category,
  }) => _change((next) {
    if (!_validAmount(amount)) {
      return 'Nominalnya masih kosong atau terlalu besar.';
    }
    final changes = <Jar, int>{};
    switch (kind) {
      case EntryKind.spend:
        if (amount > balance(Jar.jajan)) {
          return 'Uang di toples Jajan tidak cukup.';
        }
        if (amount + spentToday > dailyLimit) {
          return 'Nominal melebihi batas jajan harian.';
        }
        changes[Jar.jajan] = -amount;
      case EntryKind.give:
        if (amount > balance(Jar.berbagi)) {
          return 'Uang di toples Berbagi tidak cukup.';
        }
        changes[Jar.berbagi] = -amount;
      case EntryKind.save:
        if (dream != null && !next.dreams.any((item) => item.id == dream.id)) {
          return 'Impian ini tidak ditemukan.';
        }
        if (dream != null && amount > remaining(dream)) {
          return 'Nominal melebihi sisa target impian.';
        }
        if (source == Jar.tabung) {
          if (dream == null || amount > availableSavings) {
            return 'Tabungan yang belum dibagi tidak cukup.';
          }
        } else if (source != null) {
          if (amount > balance(source)) {
            return 'Uang di toples ${source.label} tidak cukup.';
          }
          changes[source] = -amount;
          changes[Jar.tabung] = amount;
        } else {
          changes[Jar.tabung] = amount;
        }
      case EntryKind.transfer:
        if (source == null || destination == null || source == destination) {
          return 'Pilih dua toples berbeda.';
        }
        final available = source == Jar.tabung
            ? availableSavings
            : balance(source);
        if (amount > available) {
          return 'Uang yang tersedia di toples ${source.label} tidak cukup.';
        }
        changes[source] = -amount;
        changes[destination] = amount;
      case EntryKind.income:
      case EntryKind.bonus:
        if (destination == null) return 'Pilih toples tujuan.';
        changes[destination] = amount;
      case EntryKind.allowance:
      case EntryKind.gift:
      case EntryKind.giftReturn:
        return 'Gunakan halaman penerimaan untuk mencatat ini.';
    }
    next.entries.add(
      MoneyEntry(
        kind: kind,
        date: now,
        amount: amount,
        note: note.trim(),
        changes: Map.unmodifiable(changes),
        dreamId: kind == EntryKind.save ? dream?.id : null,
        category: category,
      ),
    );
    _study(next);
    return null;
  });

  Future<String?> recordGift(
    int amount,
    Map<Jar, int> split,
    int held,
    String note,
  ) => _change((next) {
    if (!_validAmount(amount) ||
        held < 0 ||
        split.values.any((value) => value < 0) ||
        split.values.fold<int>(held, (sum, value) => sum + value) != amount) {
      return 'Bagi seluruh uang hadiah terlebih dahulu.';
    }
    next.heldGiftMoney += held;
    next.entries.add(
      MoneyEntry(
        kind: EntryKind.gift,
        date: now,
        amount: amount,
        note: note,
        changes: Map.unmodifiable(split),
      ),
    );
    return null;
  });

  Future<String?> releaseGift(int amount, Jar destination) => _change((next) {
    if (!_validAmount(amount) || amount > next.heldGiftMoney) {
      return 'Nominal melebihi uang yang dititipkan.';
    }
    next.heldGiftMoney -= amount;
    next.entries.add(
      MoneyEntry(
        kind: EntryKind.giftReturn,
        date: now,
        amount: amount,
        note: 'Pengembalian titipan ke ${destination.label}',
        changes: {destination: amount},
      ),
    );
    return null;
  });

  Future<String?> addDream(String name, int image, int target, int weekly) =>
      _change((next) {
        if (image < 0 ||
            image >= 6 ||
            name.trim().isEmpty ||
            !_validAmount(target) ||
            !_validAmount(weekly)) {
          return 'Isi nama, harga target, dan tabungan mingguan.';
        }
        next.dreams.add(
          Dream(
            id: '${now.microsecondsSinceEpoch}-${next.dreams.length}',
            name: name.trim(),
            image: image,
            target: target,
            weekly: weekly,
          ),
        );
        _study(next);
        return null;
      });

  Future<String?> setDreamPlan(Dream dream, int weekly, {DateTime? deadline}) =>
      _change((next) {
        final index = next.dreams.indexWhere((item) => item.id == dream.id);
        if (index < 0 || !_validAmount(weekly)) {
          return 'Periksa rencana tabungannya.';
        }
        next.dreams[index] = next.dreams[index].withPlan(
          weekly,
          deadline: deadline,
        );
        return null;
      });

  Future<String?> completeMission(String id, int correct) => _change((next) {
    if (correct < 0 || correct > 5) return 'Skor misi tidak valid.';
    next.missionScores[id] = max(next.missionScores[id] ?? 0, correct);
    _study(next);
    return null;
  });

  Future<String?> settings({
    bool? reminders,
    bool? alerts,
    bool? stories,
    int? rating,
  }) => _change((next) {
    next.reminders = reminders ?? next.reminders;
    next.emailAlerts = alerts ?? next.emailAlerts;
    next.stories = stories ?? next.stories;
    next.rating = rating ?? next.rating;
    return null;
  });

  Future<String?> updatePin(String current, String pin) => _change((next) {
    final error = checkPin(current);
    if (error != null) return error;
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return 'PIN harus terdiri dari 6 angka.';
    }
    next.pin = pin;
    return null;
  });

  Future<String?> activatePlan(Plan plan, String pin) => _change((next) {
    final error = checkPin(pin);
    if (error != null) return error;
    next.plan = plan;
    return null;
  });

  bool _validAmount(int amount) => amount > 0 && amount <= rupiahLimit;

  String _dayKey(DateTime day) => dayStart(day).toIso8601String();
  void _study(KoiniData data) => data.studyDays.add(_dayKey(now));

  Future<String?> _change(String? Function(KoiniData) update) async {
    if (_saving) return 'Koini sedang menyimpan. Coba lagi sebentar.';
    _saving = true;
    try {
      final next = KoiniData.fromJson(_data.toJson());
      final error = update(next);
      if (error != null) return error;
      await storage.write(jsonEncode(next.toJson()));
      _data = next;
      notifyListeners();
      return null;
    } catch (error) {
      debugPrint('Koini storage: ${error.runtimeType}');
      return 'Perubahan belum tersimpan. Coba lagi, ya.';
    } finally {
      _saving = false;
    }
  }
}
