import 'package:flutter/foundation.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/models/mission.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteSnapshot {
  const RemoteSnapshot({
    required this.missions,
    this.anakId,
    this.childName,
    this.age,
    this.tutorialDone,
    this.allowance,
    this.period,
    this.split,
    this.plan,
    this.dreams = const [],
    this.entries = const [],
    this.piggyChecks = const [],
    this.challenges = const [],
    this.bonuses = const [],
    this.missionScores = const {},
  });

  final List<Mission> missions;
  final int? anakId;
  final String? childName;
  final int? age;
  final bool? tutorialDone;
  final int? allowance;
  final AllowancePeriod? period;
  final Map<Jar, int>? split;
  final Plan? plan;
  final List<Dream> dreams;
  final List<MoneyEntry> entries;
  final List<PiggyBankCheck> piggyChecks;
  final List<RewardChallenge> challenges;
  final List<SavingsBonus> bonuses;
  final Map<String, int> missionScores;
}

abstract interface class KoiniRemoteRepository {
  bool get isSignedIn;

  Future<List<Mission>> fetchMissions();
  Future<RemoteSnapshot?> fetchFamilySnapshot();

  Future<int?> saveOnboarding({
    required String parentName,
    required String childName,
    required int age,
    required int allowance,
    required AllowancePeriod period,
    required Map<Jar, int> split,
  });

  Future<void> saveAllowanceSetting({
    required int anakId,
    required int allowance,
    required AllowancePeriod period,
    required Map<Jar, int> split,
    required DateTime effectiveDate,
  });

  Future<int?> insertDream({
    required int anakId,
    required String name,
    required int imageIndex,
    required int target,
    required bool isPrimary,
  });

  Future<void> insertEntry({required int anakId, required MoneyEntry entry});

  Future<void> savePiggyBankCheck({
    required int anakId,
    required PiggyBankCheck check,
  });

  Future<void> saveMissionProgress({
    required int anakId,
    required int misiId,
    required int correctCount,
    required int stars,
    required int streakHari,
  });

  Future<void> markTutorialDone({required int anakId});

  Future<void> activatePlan({required Plan plan});

  Future<int?> insertChallenge({
    required int anakId,
    required RewardChallenge challenge,
  });

  Future<void> updateChallengeStatus({
    required int tantanganId,
    required ChallengeStatus status,
    DateTime? confirmedAt,
  });

  Future<int?> insertSavingsBonus({
    required int anakId,
    required SavingsBonus bonus,
  });

  Future<void> updateSavingsBonusStatus({
    required int bonusId,
    required BonusStatus status,
  });

  Future<int> runSisaJajan({
    required int anakId,
    required DateTime periodStart,
    required DateTime periodEnd,
  });
}

/// Talks directly to Supabase Postgres (14 ERD tables + `sisa_jajan` RPC) under RLS.
final class SupabaseKoiniRepository implements KoiniRemoteRepository {
  SupabaseKoiniRepository(this._client);

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  @override
  bool get isSignedIn => _uid != null;

  @override
  Future<List<Mission>> fetchMissions() async {
    if (!isSignedIn) return const [];
    final rawMissions = await _client
        .from('misi')
        .select('misi_id, topik, level, judul')
        .order('misi_id', ascending: true);
    final rawQuestions = await _client
        .from('soal')
        .select(
          'soal_id, misi_id, cerita, opsi_a, opsi_b, opsi_c, opsi_d, jawaban, penjelasan_benar, penjelasan_salah, sumber',
        )
        .order('soal_id', ascending: true);

    final byMission = <int, List<Question>>{};
    for (final row in rawQuestions) {
      final misiId = (row['misi_id'] as num).toInt();
      final answerChar = (row['jawaban'] as String).toLowerCase();
      final correctIndex = switch (answerChar) {
        'a' => 0,
        'b' => 1,
        'c' => 2,
        _ => 3,
      };
      byMission
          .putIfAbsent(misiId, () => [])
          .add(
            Question(
              row['cerita'] as String,
              [
                row['opsi_a'] as String,
                row['opsi_b'] as String,
                row['opsi_c'] as String,
                row['opsi_d'] as String,
              ],
              correctIndex,
              row['penjelasan_benar'] as String,
              wrongExplanation: row['penjelasan_salah'] as String?,
              source: (row['sumber'] as String?) ?? '',
            ),
          );
    }

    final result = <Mission>[];
    for (final row in rawMissions) {
      final misiId = (row['misi_id'] as num).toInt();
      final questions = byMission[misiId] ?? const <Question>[];
      if (questions.isEmpty) continue;
      final topik = row['topik'] as String;
      final level = (row['level'] as num).toInt();
      result.add(
        Mission(
          '${topik}_$level',
          row['judul'] as String,
          questions,
          dbId: misiId,
          topic: topik,
          level: level,
        ),
      );
    }
    return result;
  }

  @override
  Future<RemoteSnapshot?> fetchFamilySnapshot() async {
    final uid = _uid;
    if (uid == null) return null;

    final loadedMissions = await fetchMissions();
    final anakRows = await _client
        .from('anak')
        .select('anak_id, nama_panggilan, usia, tutorial_selesai, streak_hari')
        .eq('orang_tua_id', uid)
        .order('anak_id', ascending: true)
        .limit(1);

    if (anakRows.isEmpty) {
      return RemoteSnapshot(missions: loadedMissions);
    }

    final anak = anakRows.first;
    final anakId = (anak['anak_id'] as num).toInt();

    final settingRows = await _client
        .from('pengaturan_uang_saku')
        .select('nominal, periode, porsi_tabung, porsi_jajan, porsi_berbagi')
        .eq('anak_id', anakId)
        .order('berlaku_mulai', ascending: false)
        .order('pengaturan_id', ascending: false)
        .limit(1);

    int? allowance;
    AllowancePeriod? period;
    Map<Jar, int>? split;
    if (settingRows.isNotEmpty) {
      final s = settingRows.first;
      allowance = (s['nominal'] as num).toInt();
      period = AllowancePeriod.fromDb(s['periode'] as String?);
      split = {
        Jar.tabung: (s['porsi_tabung'] as num).toInt(),
        Jar.jajan: (s['porsi_jajan'] as num).toInt(),
        Jar.berbagi: (s['porsi_berbagi'] as num).toInt(),
      };
    }

    final planRows = await _client
        .from('langganan')
        .select('paket')
        .eq('orang_tua_id', uid)
        .eq('status', 'aktif')
        .order('langganan_id', ascending: false)
        .limit(1);
    final plan = planRows.isEmpty
        ? Plan.free
        : switch (planRows.first['paket'] as String?) {
            'bulanan' => Plan.monthly,
            'tahunan' => Plan.yearly,
            _ => Plan.free,
          };

    final dreamRows = await _client
        .from('impian')
        .select('impian_id, nama, gambar, target_harga')
        .eq('anak_id', anakId)
        .order('impian_id', ascending: true);
    final dreams = [
      for (final row in dreamRows)
        Dream(
          id: '${(row['impian_id'] as num).toInt()}',
          name: row['nama'] as String,
          image: _imageIndexFromDb(row['gambar'] as String?),
          target: (row['target_harga'] as num).toInt(),
          weekly: (split?[Jar.tabung] ?? 10000).clamp(5000, rupiahLimit),
        ),
    ];

    final entryRows = await _client
        .from('catatan')
        .select(
          'catatan_id, impian_id, toples, jenis, kategori, nominal, keterangan, tanggal',
        )
        .eq('anak_id', anakId)
        .order('tanggal', ascending: true)
        .order('catatan_id', ascending: true);
    final entries = <MoneyEntry>[
      for (final row in entryRows) _entryFromRow(row),
    ];

    final checkRows = await _client
        .from('cek_celengan')
        .select('jumlah_fisik, jumlah_catatan, created_at')
        .eq('anak_id', anakId)
        .order('created_at', ascending: false)
        .limit(20);
    final checks = [
      for (final row in checkRows)
        PiggyBankCheck(
          physicalAmount: (row['jumlah_fisik'] as num).toInt(),
          recordedAmount: (row['jumlah_catatan'] as num).toInt(),
          checkedAt: DateTime.parse(row['created_at'] as String).toLocal(),
        ),
    ];

    final challengeRows = await _client
        .from('tantangan_hadiah')
        .select(
          'tantangan_id, impian_id, judul, jenis, syarat, hadiah, status, dikonfirmasi_pada, created_at',
        )
        .eq('anak_id', anakId)
        .order('created_at', ascending: false);
    final challenges = [
      for (final row in challengeRows)
        RewardChallenge(
          id: '${(row['tantangan_id'] as num).toInt()}',
          title: row['judul'] as String,
          kind: ChallengeKind.fromDb(row['jenis'] as String?),
          requirement: row['syarat'] as String,
          reward: (row['hadiah'] as num).toInt(),
          status: ChallengeStatus.fromDb(row['status'] as String?),
          createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
          dreamId: row['impian_id'] == null
              ? null
              : '${(row['impian_id'] as num).toInt()}',
          confirmedAt: row['dikonfirmasi_pada'] == null
              ? null
              : DateTime.parse(row['dikonfirmasi_pada'] as String).toLocal(),
        ),
    ];

    final bonusRows = await _client
        .from('bonus_tabungan')
        .select(
          'bonus_id, nominal_bonus, minimal_tabungan, mulai, berakhir, status, created_at',
        )
        .eq('anak_id', anakId)
        .order('created_at', ascending: false);
    final bonuses = [
      for (final row in bonusRows)
        SavingsBonus(
          id: '${(row['bonus_id'] as num).toInt()}',
          bonusAmount: (row['nominal_bonus'] as num).toInt(),
          minSavings: (row['minimal_tabungan'] as num).toInt(),
          startDate: DateTime.parse(row['mulai'] as String),
          endDate: DateTime.parse(row['berakhir'] as String),
          status: BonusStatus.fromDb(row['status'] as String?),
          createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        ),
    ];

    final missionIdByDbId = {
      for (final m in loadedMissions)
        if (m.dbId != null) m.dbId!: m.id,
    };
    final progressRows = await _client
        .from('progres_misi')
        .select('misi_id, jumlah_benar')
        .eq('anak_id', anakId);
    final scores = <String, int>{};
    for (final row in progressRows) {
      final dbId = (row['misi_id'] as num).toInt();
      final key = missionIdByDbId[dbId];
      if (key != null) {
        scores[key] = (row['jumlah_benar'] as num).toInt();
      }
    }

    return RemoteSnapshot(
      missions: loadedMissions,
      anakId: anakId,
      childName: anak['nama_panggilan'] as String,
      age: (anak['usia'] as num).toInt(),
      tutorialDone: anak['tutorial_selesai'] as bool? ?? false,
      allowance: allowance,
      period: period,
      split: split,
      plan: plan,
      dreams: dreams,
      entries: entries,
      piggyChecks: checks,
      challenges: challenges,
      bonuses: bonuses,
      missionScores: scores,
    );
  }

  @override
  Future<int?> saveOnboarding({
    required String parentName,
    required String childName,
    required int age,
    required int allowance,
    required AllowancePeriod period,
    required Map<Jar, int> split,
  }) async {
    final uid = _uid;
    if (uid == null) return null;

    final safeParent = parentName.trim().isEmpty
        ? 'Ayah/Bunda'
        : parentName.trim();
    await _client.from('orang_tua').upsert({
      'orang_tua_id': uid,
      'nama': safeParent,
      'pin_diatur': true,
      'persetujuan_data_pada': DateTime.now().toUtc().toIso8601String(),
    });

    final existingAnak = await _client
        .from('anak')
        .select('anak_id')
        .eq('orang_tua_id', uid)
        .limit(1);

    final int anakId;
    if (existingAnak.isNotEmpty) {
      anakId = (existingAnak.first['anak_id'] as num).toInt();
      await _client
          .from('anak')
          .update({'nama_panggilan': childName.trim(), 'usia': age})
          .eq('anak_id', anakId);
    } else {
      final inserted = await _client
          .from('anak')
          .insert({
            'orang_tua_id': uid,
            'nama_panggilan': childName.trim(),
            'usia': age,
          })
          .select('anak_id')
          .single();
      anakId = (inserted['anak_id'] as num).toInt();
    }

    await saveAllowanceSetting(
      anakId: anakId,
      allowance: allowance,
      period: period,
      split: split,
      effectiveDate: DateTime.now(),
    );

    final existingPlan = await _client
        .from('langganan')
        .select('langganan_id')
        .eq('orang_tua_id', uid)
        .limit(1);
    if (existingPlan.isEmpty) {
      await _client.from('langganan').insert({
        'orang_tua_id': uid,
        'paket': 'gratis',
        'harga': 0,
        'mulai': isoDate(DateTime.now()),
        'status': 'aktif',
        'is_simulasi': true,
      });
    }

    return anakId;
  }

  @override
  Future<void> saveAllowanceSetting({
    required int anakId,
    required int allowance,
    required AllowancePeriod period,
    required Map<Jar, int> split,
    required DateTime effectiveDate,
  }) async {
    if (!isSignedIn) return;
    await _client.from('pengaturan_uang_saku').insert({
      'anak_id': anakId,
      'nominal': allowance,
      'periode': period.dbValue,
      'porsi_tabung': split[Jar.tabung] ?? 0,
      'porsi_jajan': split[Jar.jajan] ?? 0,
      'porsi_berbagi': split[Jar.berbagi] ?? 0,
      'berlaku_mulai': isoDate(effectiveDate),
    });
  }

  @override
  Future<int?> insertDream({
    required int anakId,
    required String name,
    required int imageIndex,
    required int target,
    required bool isPrimary,
  }) async {
    if (!isSignedIn) return null;
    final inserted = await _client
        .from('impian')
        .insert({
          'anak_id': anakId,
          'nama': name.trim(),
          'gambar': 'dream_$imageIndex',
          'target_harga': target,
          'is_utama': isPrimary,
          'status': 'aktif',
        })
        .select('impian_id')
        .single();
    return (inserted['impian_id'] as num).toInt();
  }

  @override
  Future<void> insertEntry({
    required int anakId,
    required MoneyEntry entry,
  }) async {
    if (!isSignedIn) return;
    final rows = <Map<String, dynamic>>[];
    final impianId = int.tryParse(entry.dreamId ?? '');
    final dateText = isoDate(entry.date);
    final keterangan = entry.note.length > 100
        ? entry.note.substring(0, 100)
        : entry.note;

    for (final change in entry.changes.entries) {
      if (change.value == 0) continue;
      final isIncome = change.value > 0;
      rows.add({
        'anak_id': anakId,
        'impian_id': change.key == Jar.tabung && isIncome ? impianId : null,
        'toples': change.key.name,
        'jenis': isIncome ? 'masuk' : 'keluar',
        'kategori': _kategoriFor(entry.kind),
        'nominal': change.value.abs(),
        'keterangan': keterangan,
        'tanggal': dateText,
      });
    }
    if (rows.isEmpty) return;
    await _client.from('catatan').insert(rows);
  }

  @override
  Future<void> savePiggyBankCheck({
    required int anakId,
    required PiggyBankCheck check,
  }) async {
    if (!isSignedIn) return;
    await _client.from('cek_celengan').insert({
      'anak_id': anakId,
      'jumlah_fisik': check.physicalAmount,
      'jumlah_catatan': check.recordedAmount,
      'selisih': check.difference,
    });
  }

  @override
  Future<void> saveMissionProgress({
    required int anakId,
    required int misiId,
    required int correctCount,
    required int stars,
    required int streakHari,
  }) async {
    if (!isSignedIn) return;
    await _client.from('progres_misi').upsert({
      'anak_id': anakId,
      'misi_id': misiId,
      'jumlah_benar': correctCount,
      'bintang': stars,
      'selesai_pada': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'anak_id,misi_id');
    await _client
        .from('anak')
        .update({'streak_hari': streakHari})
        .eq('anak_id', anakId);
  }

  @override
  Future<void> markTutorialDone({required int anakId}) async {
    if (!isSignedIn) return;
    await _client
        .from('anak')
        .update({'tutorial_selesai': true})
        .eq('anak_id', anakId);
  }

  @override
  Future<void> activatePlan({required Plan plan}) async {
    final uid = _uid;
    if (uid == null) return;
    final now = DateTime.now();
    final (paket, harga, end) = switch (plan) {
      Plan.free => ('gratis', 0, null),
      Plan.monthly => (
        'bulanan',
        5000,
        isoDate(DateTime(now.year, now.month + 1, now.day)),
      ),
      Plan.yearly => (
        'tahunan',
        50000,
        isoDate(DateTime(now.year + 1, now.month, now.day)),
      ),
    };
    await _client
        .from('langganan')
        .update({'status': 'berakhir'})
        .eq('orang_tua_id', uid)
        .eq('status', 'aktif');
    await _client.from('langganan').insert({
      'orang_tua_id': uid,
      'paket': paket,
      'harga': harga,
      'mulai': isoDate(now),
      'berakhir': end,
      'status': 'aktif',
      'is_simulasi': true,
    });
  }

  @override
  Future<int?> insertChallenge({
    required int anakId,
    required RewardChallenge challenge,
  }) async {
    if (!isSignedIn) return null;
    final inserted = await _client
        .from('tantangan_hadiah')
        .insert({
          'anak_id': anakId,
          'impian_id': int.tryParse(challenge.dreamId ?? ''),
          'judul': challenge.title.trim(),
          'jenis': challenge.kind.dbValue,
          'syarat': challenge.requirement.trim(),
          'hadiah': challenge.reward,
          'status': challenge.status.dbValue,
        })
        .select('tantangan_id')
        .single();
    return (inserted['tantangan_id'] as num).toInt();
  }

  @override
  Future<void> updateChallengeStatus({
    required int tantanganId,
    required ChallengeStatus status,
    DateTime? confirmedAt,
  }) async {
    if (!isSignedIn) return;
    await _client
        .from('tantangan_hadiah')
        .update({
          'status': status.dbValue,
          if (confirmedAt != null)
            'dikonfirmasi_pada': confirmedAt.toUtc().toIso8601String(),
        })
        .eq('tantangan_id', tantanganId);
  }

  @override
  Future<int?> insertSavingsBonus({
    required int anakId,
    required SavingsBonus bonus,
  }) async {
    if (!isSignedIn) return null;
    final inserted = await _client
        .from('bonus_tabungan')
        .insert({
          'anak_id': anakId,
          'nominal_bonus': bonus.bonusAmount,
          'minimal_tabungan': bonus.minSavings,
          'mulai': isoDate(bonus.startDate),
          'berakhir': isoDate(bonus.endDate),
          'status': bonus.status.dbValue,
        })
        .select('bonus_id')
        .single();
    return (inserted['bonus_id'] as num).toInt();
  }

  @override
  Future<void> updateSavingsBonusStatus({
    required int bonusId,
    required BonusStatus status,
  }) async {
    if (!isSignedIn) return;
    await _client
        .from('bonus_tabungan')
        .update({'status': status.dbValue})
        .eq('bonus_id', bonusId);
  }

  @override
  Future<int> runSisaJajan({
    required int anakId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    if (!isSignedIn) return 0;
    try {
      final result = await _client.rpc<Object?>(
        'sisa_jajan',
        params: {
          'p_anak_id': anakId,
          'p_periode_mulai': isoDate(periodStart),
          'p_periode_selesai': isoDate(periodEnd),
        },
      );
      if (result is num) return result.toInt();
      return 0;
    } catch (error) {
      debugPrint('Koini sisa_jajan RPC: ${error.runtimeType}');
      return 0;
    }
  }

  String _kategoriFor(EntryKind kind) => switch (kind) {
    EntryKind.allowance => 'uang_saku',
    EntryKind.spend => 'jajan',
    EntryKind.give => 'sumbangan',
    EntryKind.leftoverTransfer => 'sisa_jajan',
    EntryKind.challengeReward => 'tantangan',
    EntryKind.gift => 'hadiah',
    EntryKind.bonus => 'bonus',
    EntryKind.save ||
    EntryKind.income ||
    EntryKind.transfer ||
    EntryKind.giftReturn => 'lainnya',
  };

  MoneyEntry _entryFromRow(Map<String, dynamic> row) {
    final jar = Jar.values.firstWhere(
      (j) => j.name == row['toples'],
      orElse: () => Jar.jajan,
    );
    final isIn = row['jenis'] == 'masuk';
    final nominal = (row['nominal'] as num).toInt();
    final kategori = row['kategori'] as String? ?? 'lainnya';
    final kind = switch (kategori) {
      'uang_saku' => EntryKind.allowance,
      'jajan' => EntryKind.spend,
      'sumbangan' => EntryKind.give,
      'sisa_jajan' => EntryKind.leftoverTransfer,
      'tantangan' => EntryKind.challengeReward,
      'bonus' => EntryKind.bonus,
      'hadiah' => EntryKind.income,
      _ => isIn && jar == Jar.tabung ? EntryKind.save : EntryKind.income,
    };
    return MoneyEntry(
      kind: kind,
      date: DateTime.parse(row['tanggal'] as String),
      amount: nominal,
      note: (row['keterangan'] as String?) ?? '',
      changes: {jar: isIn ? nominal : -nominal},
      dreamId: row['impian_id'] == null
          ? null
          : '${(row['impian_id'] as num).toInt()}',
    );
  }

  int _imageIndexFromDb(String? raw) {
    if (raw == null) return 0;
    final parsed = int.tryParse(raw.replaceFirst('dream_', ''));
    if (parsed != null && parsed >= 0 && parsed < 6) return parsed;
    return 0;
  }
}
