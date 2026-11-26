import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:koini/features/missions/mission_content.dart' as fallback;
import 'package:koini/models/mission.dart';

import '../models/koini_data.dart';
import 'koini_storage.dart';
import 'supabase_koini_repository.dart';

class KoiniStore extends ChangeNotifier {
  KoiniStore(this.storage, {DateTime Function()? clock, this.remote})
    : _clock = clock ?? DateTime.now;

  final KoiniStorage storage;
  final KoiniRemoteRepository? remote;
  final DateTime Function() _clock;
  KoiniData _data = KoiniData();
  List<Mission> _remoteMissions = const [];
  bool _saving = false;
  int _pinFailures = 0;
  DateTime? _pinLockedUntil;

  DateTime get now => _clock();
  bool get hasProfile => _data.hasProfile;
  bool get isRemoteConnected => remote != null && remote!.isSignedIn;
  int? get anakId => _data.anakId;
  String get name => _data.name;
  String get email => _data.email;
  int get age => _data.age;
  int get allowance => _data.allowance;
  AllowancePeriod get allowancePeriod => _data.allowancePeriod;
  int get dailyLimit => _data.dailyLimit;
  Map<Jar, int> get split => Map.unmodifiable(_data.split);
  Plan get plan => _data.plan;
  bool get hasPlus => plan != Plan.free;
  bool get hasYearly => plan == Plan.yearly;
  bool get reminders => _data.reminders;
  bool get alerts => _data.emailAlerts;
  bool get stories => _data.stories;
  bool get tutorialDone => _data.tutorialDone;
  int get rating => _data.rating;
  int get heldGift => _data.heldGiftMoney;
  List<Dream> get dreams => List.unmodifiable(_data.dreams);
  List<MoneyEntry> get entries => List.unmodifiable(_data.entries.reversed);
  List<PiggyBankCheck> get piggyChecks => List.unmodifiable(_data.piggyChecks);
  List<RewardChallenge> get challenges => List.unmodifiable(_data.challenges);
  List<SavingsBonus> get bonuses => List.unmodifiable(_data.bonuses);
  List<Mission> get catalogMissions =>
      _remoteMissions.isNotEmpty ? _remoteMissions : fallback.missions;
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
  List<MoneyEntry> get currentPeriodEntries => entries
      .where((entry) => !entry.date.isBefore(periodStart(now, allowancePeriod)))
      .toList();
  List<MoneyEntry> get thisMonth => entries
      .where(
        (entry) => entry.date.year == now.year && entry.date.month == now.month,
      )
      .toList();
  bool get receivedThisPeriod =>
      currentPeriodEntries.any((entry) => entry.kind == EntryKind.allowance);
  bool get receivedThisWeek => receivedThisPeriod;
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
    await syncFromRemote();
  }

  Future<void> syncFromRemote() async {
    final repo = remote;
    if (repo == null || !repo.isSignedIn) return;
    try {
      final snapshot = await repo.fetchFamilySnapshot();
      if (snapshot == null) return;
      if (snapshot.missions.isNotEmpty) {
        _remoteMissions = List.unmodifiable(snapshot.missions);
      }
      if (snapshot.anakId != null && snapshot.childName != null) {
        final next = KoiniData.fromJson(_data.toJson());
        next
          ..anakId = snapshot.anakId
          ..name = snapshot.childName!
          ..age = snapshot.age ?? next.age
          ..tutorialDone = snapshot.tutorialDone ?? next.tutorialDone
          ..allowance = snapshot.allowance ?? next.allowance
          ..allowancePeriod = snapshot.period ?? next.allowancePeriod
          ..plan = snapshot.plan ?? next.plan;
        if (snapshot.split != null) {
          next.split = Map.of(snapshot.split!);
        }
        if (snapshot.dreams.isNotEmpty || next.dreams.isEmpty) {
          next.dreams
            ..clear()
            ..addAll(snapshot.dreams);
        }
        if (snapshot.entries.isNotEmpty || next.entries.isEmpty) {
          next.entries
            ..clear()
            ..addAll(snapshot.entries);
        }
        if (snapshot.piggyChecks.isNotEmpty) {
          next.piggyChecks
            ..clear()
            ..addAll(snapshot.piggyChecks);
        }
        if (snapshot.challenges.isNotEmpty) {
          next.challenges
            ..clear()
            ..addAll(snapshot.challenges);
        }
        if (snapshot.bonuses.isNotEmpty) {
          next.bonuses
            ..clear()
            ..addAll(snapshot.bonuses);
        }
        if (snapshot.missionScores.isNotEmpty) {
          next.missionScores.addAll(snapshot.missionScores);
        }
        await storage.write(jsonEncode(next.toJson()));
        _data = next;
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Koini remote sync: ${error.runtimeType}');
    }
  }

  static String _hashPin(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  static String _newPinRecord(String pin) {
    final random = Random.secure();
    final salt = base64UrlEncode(List.generate(12, (_) => random.nextInt(256)));
    return 'v1:$salt:${_hashPin(pin, salt)}';
  }

  /// Format 'v1:salt:hash'. PIN lama (teks biasa) tetap valid sampai diganti.
  static bool _pinMatches(String record, String pin) {
    if (!record.startsWith('v1:')) return record == pin;
    final parts = record.split(':');
    return parts.length == 3 && _hashPin(pin, parts[1]) == parts[2];
  }

  String? checkPin(String pin) {
    if (_pinLockedUntil?.isAfter(now) ?? false) {
      return 'Terlalu banyak percobaan. Tunggu satu menit.';
    }
    if (_data.pin.isNotEmpty && _pinMatches(_data.pin, pin)) {
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
    AllowancePeriod period = AllowancePeriod.weekly,
  }) async {
    final error = await _change((next) {
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
        ..pin = _newPinRecord(pin)
        ..allowance = allowance
        ..allowancePeriod = period
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
    if (error != null) return error;
    final repo = remote;
    if (repo != null && repo.isSignedIn) {
      try {
        final createdId = await repo.saveOnboarding(
          parentName: email.trim().isEmpty ? 'Ayah/Bunda' : email.trim(),
          childName: name.trim(),
          age: age,
          allowance: allowance,
          period: period,
          split: split,
        );
        if (createdId != null) {
          await _change((next) {
            next.anakId = createdId;
            return null;
          });
        }
      } catch (e) {
        debugPrint('Koini onboarding remote sync: ${e.runtimeType}');
      }
    }
    return null;
  }

  static Map<Jar, int> defaultSplit(int amount) => {
    Jar.tabung: amount * 40 ~/ 100,
    Jar.berbagi: amount * 10 ~/ 100,
    Jar.jajan: amount - amount * 40 ~/ 100 - amount * 10 ~/ 100,
  };

  Future<String?> setAllowance(
    int amount,
    int limit,
    Map<Jar, int> split, {
    AllowancePeriod? period,
  }) async {
    final nextPeriod = period ?? _data.allowancePeriod;
    final error = await _change((next) {
      if (!_validAmount(amount) ||
          !_validAmount(limit) ||
          Jar.values.any((jar) => (split[jar] ?? -1) < 0) ||
          split.values.fold<int>(0, (a, b) => a + b) != amount) {
        return 'Bagi seluruh uang saku ke tiga toples.';
      }
      next
        ..allowance = amount
        ..allowancePeriod = nextPeriod
        ..dailyLimit = limit
        ..split = Map.of(split);
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final id = _data.anakId;
    if (repo != null && repo.isSignedIn && id != null) {
      try {
        await repo.saveAllowanceSetting(
          anakId: id,
          allowance: amount,
          period: nextPeriod,
          split: split,
          effectiveDate: now,
        );
      } catch (e) {
        debugPrint('Koini allowance remote sync: ${e.runtimeType}');
      }
    }
    return null;
  }

  Future<String?> receiveAllowance() async {
    final entry = MoneyEntry(
      kind: EntryKind.allowance,
      amount: allowance,
      date: now,
      note: 'Uang saku ${allowancePeriod.label.toLowerCase()}',
      changes: Map.unmodifiable(split),
    );
    final error = await _change((next) {
      if (receivedThisPeriod) {
        return 'Uang saku ${allowancePeriod.currentLabel} sudah tercatat.';
      }
      next.entries.add(entry);
      return null;
    });
    if (error != null) return error;
    await _syncEntryToRemote(entry);
    return null;
  }

  Future<String?> record({
    required EntryKind kind,
    required int amount,
    required String note,
    Jar? source,
    Jar? destination,
    Dream? dream,
    String? category,
  }) async {
    MoneyEntry? created;
    final error = await _change((next) {
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
          if (dream != null &&
              !next.dreams.any((item) => item.id == dream.id)) {
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
        case EntryKind.leftoverTransfer:
        case EntryKind.challengeReward:
        case EntryKind.gift:
        case EntryKind.giftReturn:
          return 'Gunakan halaman penerimaan untuk mencatat ini.';
      }
      created = MoneyEntry(
        kind: kind,
        date: now,
        amount: amount,
        note: note.trim(),
        changes: Map.unmodifiable(changes),
        dreamId: kind == EntryKind.save ? dream?.id : null,
        category: category,
      );
      next.entries.add(created!);
      _study(next);
      return null;
    });
    if (error != null) return error;
    if (created case final entry?) {
      await _syncEntryToRemote(entry);
    }
    return null;
  }

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

  Future<String?> addDream(
    String name,
    int image,
    int target,
    int weekly,
  ) async {
    final isPrimary = _data.dreams.isEmpty;
    String localId = '';
    final error = await _change((next) {
      if (image < 0 ||
          image >= 6 ||
          name.trim().isEmpty ||
          !_validAmount(target) ||
          !_validAmount(weekly)) {
        return 'Isi nama, harga target, dan tabungan mingguan.';
      }
      localId = '${now.microsecondsSinceEpoch}-${next.dreams.length}';
      next.dreams.add(
        Dream(
          id: localId,
          name: name.trim(),
          image: image,
          target: target,
          weekly: weekly,
        ),
      );
      _study(next);
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final id = _data.anakId;
    if (repo != null && repo.isSignedIn && id != null) {
      try {
        final dbDreamId = await repo.insertDream(
          anakId: id,
          name: name,
          imageIndex: image,
          target: target,
          isPrimary: isPrimary,
        );
        if (dbDreamId != null) {
          await _change((next) {
            final idx = next.dreams.indexWhere((d) => d.id == localId);
            if (idx >= 0) {
              final old = next.dreams[idx];
              next.dreams[idx] = Dream(
                id: '$dbDreamId',
                name: old.name,
                image: old.image,
                target: old.target,
                weekly: old.weekly,
                deadline: old.deadline,
              );
            }
            return null;
          });
        }
      } catch (e) {
        debugPrint('Koini dream remote sync: ${e.runtimeType}');
      }
    }
    return null;
  }

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

  Future<String?> completeMission(String id, int correct) async {
    final error = await _change((next) {
      if (correct < 0 || correct > 5) return 'Skor misi tidak valid.';
      next.missionScores[id] = max(next.missionScores[id] ?? 0, correct);
      _study(next);
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final childId = _data.anakId;
    final mission = catalogMissions.where((item) => item.id == id).firstOrNull;
    if (repo != null &&
        repo.isSignedIn &&
        childId != null &&
        mission?.dbId != null) {
      try {
        await repo.saveMissionProgress(
          anakId: childId,
          misiId: mission!.dbId!,
          correctCount: _data.missionScores[id] ?? correct,
          stars: 3 * (_data.missionScores[id] ?? correct),
          streakHari: streak,
        );
      } catch (e) {
        debugPrint('Koini mission remote sync: ${e.runtimeType}');
      }
    }
    return null;
  }

  Future<String?> recordPiggyBankCheck(int physicalAmount) async {
    if (physicalAmount < 0 || physicalAmount > rupiahLimit) {
      return 'Masukkan jumlah uang tunai yang valid.';
    }
    final check = PiggyBankCheck(
      physicalAmount: physicalAmount,
      recordedAmount: total,
      checkedAt: now,
    );
    final error = await _change((next) {
      next.piggyChecks.insert(0, check);
      _study(next);
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final childId = _data.anakId;
    if (repo != null && repo.isSignedIn && childId != null) {
      try {
        await repo.savePiggyBankCheck(anakId: childId, check: check);
      } catch (e) {
        debugPrint('Koini piggy check remote sync: ${e.runtimeType}');
      }
    }
    return null;
  }

  Future<String?> completeTutorial() async {
    if (_data.tutorialDone) return null;
    final error = await _change((next) {
      next.tutorialDone = true;
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final childId = _data.anakId;
    if (repo != null && repo.isSignedIn && childId != null) {
      try {
        await repo.markTutorialDone(anakId: childId);
      } catch (e) {
        debugPrint('Koini tutorial remote sync: ${e.runtimeType}');
      }
    }
    return null;
  }

  Future<String?> addChallenge({
    required String title,
    required ChallengeKind kind,
    required String requirement,
    required int reward,
    Dream? dream,
  }) async {
    if (title.trim().isEmpty || requirement.trim().isEmpty) {
      return 'Isi judul dan syarat tantangan terlebih dahulu.';
    }
    if (!_validAmount(reward)) {
      return 'Nominal hadiah harus lebih dari Rp0.';
    }
    final localId =
        'ch-${now.microsecondsSinceEpoch}-${_data.challenges.length}';
    final created = RewardChallenge(
      id: localId,
      title: title.trim(),
      kind: kind,
      requirement: requirement.trim(),
      reward: reward,
      status: ChallengeStatus.active,
      createdAt: now,
      dreamId: dream?.id ?? activeDream?.id,
    );
    final error = await _change((next) {
      next.challenges.insert(0, created);
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final childId = _data.anakId;
    if (repo != null && repo.isSignedIn && childId != null) {
      try {
        final dbId = await repo.insertChallenge(
          anakId: childId,
          challenge: created,
        );
        if (dbId != null) {
          await _change((next) {
            final idx = next.challenges.indexWhere((c) => c.id == localId);
            if (idx >= 0) {
              next.challenges[idx] = next.challenges[idx].copyWith(id: '$dbId');
            }
            return null;
          });
        }
      } catch (e) {
        debugPrint('Koini challenge insert remote sync: ${e.runtimeType}');
      }
    }
    return null;
  }

  Future<String?> markChallengeWaiting(String challengeId) async {
    final error = await _change((next) {
      final idx = next.challenges.indexWhere((c) => c.id == challengeId);
      if (idx < 0) return 'Tantangan tidak ditemukan.';
      if (next.challenges[idx].status != ChallengeStatus.active) {
        return 'Tantangan ini sudah selesai atau menunggu konfirmasi.';
      }
      next.challenges[idx] = next.challenges[idx].copyWith(
        status: ChallengeStatus.waiting,
      );
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final dbId = int.tryParse(challengeId);
    if (repo != null && repo.isSignedIn && dbId != null) {
      try {
        await repo.updateChallengeStatus(
          tantanganId: dbId,
          status: ChallengeStatus.waiting,
        );
      } catch (e) {
        debugPrint('Koini challenge waiting sync: ${e.runtimeType}');
      }
    }
    return null;
  }

  Future<String?> resolveChallenge(
    String challengeId, {
    required bool succeeded,
  }) async {
    MoneyEntry? rewardEntry;
    final targetStatus = succeeded
        ? ChallengeStatus.completed
        : ChallengeStatus.failed;
    final error = await _change((next) {
      final idx = next.challenges.indexWhere((c) => c.id == challengeId);
      if (idx < 0) return 'Tantangan tidak ditemukan.';
      final item = next.challenges[idx];
      if (item.status == ChallengeStatus.completed ||
          item.status == ChallengeStatus.failed) {
        return 'Tantangan ini sudah dikonfirmasi.';
      }
      next.challenges[idx] = item.copyWith(
        status: targetStatus,
        confirmedAt: now,
      );
      if (succeeded) {
        rewardEntry = MoneyEntry(
          kind: EntryKind.challengeReward,
          date: now,
          amount: item.reward,
          note: 'Hadiah tantangan: ${item.title}',
          changes: {Jar.tabung: item.reward},
          dreamId: item.dreamId ?? activeDream?.id,
        );
        next.entries.add(rewardEntry!);
        _study(next);
      }
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final dbId = int.tryParse(challengeId);
    if (repo != null && repo.isSignedIn && dbId != null) {
      try {
        await repo.updateChallengeStatus(
          tantanganId: dbId,
          status: targetStatus,
          confirmedAt: now,
        );
      } catch (e) {
        debugPrint('Koini challenge resolve sync: ${e.runtimeType}');
      }
    }
    if (rewardEntry case final entry?) {
      await _syncEntryToRemote(entry);
    }
    return null;
  }

  Future<String?> addSavingsBonus({
    required int bonusAmount,
    required int minSavings,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_validAmount(bonusAmount) || !_validAmount(minSavings)) {
      return 'Isi nominal bonus dan minimal tabungan lebih dari Rp0.';
    }
    if (endDate.isBefore(startDate)) {
      return 'Tanggal berakhir tidak boleh sebelum tanggal mulai.';
    }
    final localId = 'bn-${now.microsecondsSinceEpoch}-${_data.bonuses.length}';
    final created = SavingsBonus(
      id: localId,
      bonusAmount: bonusAmount,
      minSavings: minSavings,
      startDate: dayStart(startDate),
      endDate: dayStart(endDate),
      status: BonusStatus.active,
      createdAt: now,
    );
    final error = await _change((next) {
      next.bonuses.insert(0, created);
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final childId = _data.anakId;
    if (repo != null && repo.isSignedIn && childId != null) {
      try {
        final dbId = await repo.insertSavingsBonus(
          anakId: childId,
          bonus: created,
        );
        if (dbId != null) {
          await _change((next) {
            final idx = next.bonuses.indexWhere((b) => b.id == localId);
            if (idx >= 0) {
              next.bonuses[idx] = next.bonuses[idx].copyWith(id: '$dbId');
            }
            return null;
          });
        }
      } catch (e) {
        debugPrint('Koini bonus insert remote sync: ${e.runtimeType}');
      }
    }
    return null;
  }

  Future<String?> resolveSavingsBonus(
    String bonusId, {
    required bool succeeded,
  }) async {
    MoneyEntry? bonusEntry;
    final targetStatus = succeeded ? BonusStatus.completed : BonusStatus.failed;
    final error = await _change((next) {
      final idx = next.bonuses.indexWhere((b) => b.id == bonusId);
      if (idx < 0) return 'Janji bonus tidak ditemukan.';
      final item = next.bonuses[idx];
      if (item.status != BonusStatus.active) {
        return 'Janji bonus ini sudah selesai.';
      }
      if (succeeded && balance(Jar.tabung) < item.minSavings) {
        return 'Saldo Tabung belum mencapai minimal ${rupiah(item.minSavings)}.';
      }
      next.bonuses[idx] = item.copyWith(status: targetStatus);
      if (succeeded) {
        bonusEntry = MoneyEntry(
          kind: EntryKind.bonus,
          date: now,
          amount: item.bonusAmount,
          note: 'Bonus tabungan (${rupiah(item.minSavings)})',
          changes: {Jar.tabung: item.bonusAmount},
          dreamId: activeDream?.id,
        );
        next.entries.add(bonusEntry!);
        _study(next);
      }
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    final dbId = int.tryParse(bonusId);
    if (repo != null && repo.isSignedIn && dbId != null) {
      try {
        await repo.updateSavingsBonusStatus(
          bonusId: dbId,
          status: targetStatus,
        );
      } catch (e) {
        debugPrint('Koini bonus resolve sync: ${e.runtimeType}');
      }
    }
    if (bonusEntry case final entry?) {
      await _syncEntryToRemote(entry);
    }
    return null;
  }

  /// Idempotent leftover-jajan sweep for the just-completed allowance period.
  /// Returns the rupiah amount moved from Jajan to Tabung, or 0 if nothing moved.
  Future<int> sweepLeftoverJajan() async {
    if (!hasProfile) return 0;
    final prev = previousPeriodRange(now, allowancePeriod);
    final endKey = isoDate(prev.end);
    if (_data.lastSweptPeriodEnd == endKey) return 0;
    final alreadyRecorded = _data.entries.any(
      (entry) =>
          entry.kind == EntryKind.leftoverTransfer &&
          isoDate(entry.date) == endKey,
    );
    if (alreadyRecorded) return 0;

    final leftover = _data.entries
        .where((entry) => !dayStart(entry.date).isAfter(prev.end))
        .fold<int>(0, (sum, entry) => sum + (entry.changes[Jar.jajan] ?? 0));
    if (leftover <= 0) return 0;

    int moved = leftover;
    final repo = remote;
    final childId = _data.anakId;
    if (repo != null && repo.isSignedIn && childId != null) {
      final rpcMoved = await repo.runSisaJajan(
        anakId: childId,
        periodStart: prev.start,
        periodEnd: prev.end,
      );
      if (rpcMoved <= 0) {
        await _change((next) {
          next.lastSweptPeriodEnd = endKey;
          return null;
        });
        return 0;
      }
      moved = rpcMoved;
    }

    final primaryDream = activeDream;
    final error = await _change((next) {
      next.lastSweptPeriodEnd = endKey;
      next.entries.add(
        MoneyEntry(
          kind: EntryKind.leftoverTransfer,
          date: prev.end,
          amount: moved,
          note: 'Sisa jajan ${dateLabel(prev.start)} - ${dateLabel(prev.end)}',
          changes: {Jar.jajan: -moved, Jar.tabung: moved},
          dreamId: primaryDream?.id,
        ),
      );
      return null;
    });
    return error == null ? moved : 0;
  }

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
    next.pin = _newPinRecord(pin);
    return null;
  });

  /// PIN hanya dicek bila diberikan. Layar paket hanya terbuka setelah PIN
  /// area orang tua diverifikasi, jadi tidak perlu meminta PIN lagi.
  Future<String?> activatePlan(Plan plan, [String? pin]) async {
    final error = await _change((next) {
      if (pin != null) {
        final pinError = checkPin(pin);
        if (pinError != null) return pinError;
      }
      next.plan = plan;
      return null;
    });
    if (error != null) return error;
    final repo = remote;
    if (repo != null && repo.isSignedIn) {
      try {
        await repo.activatePlan(plan: plan);
      } catch (e) {
        debugPrint('Koini plan remote sync: ${e.runtimeType}');
      }
    }
    return null;
  }

  Future<void> _syncEntryToRemote(MoneyEntry entry) async {
    final repo = remote;
    final id = _data.anakId;
    if (repo == null || !repo.isSignedIn || id == null) return;
    try {
      await repo.insertEntry(anakId: id, entry: entry);
    } catch (e) {
      debugPrint('Koini entry remote sync: ${e.runtimeType}');
    }
  }

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
