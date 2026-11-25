import 'dart:convert';

import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_storage.dart';
import 'package:koini/services/koini_store.dart';

const previewPin = '123456';

enum PreviewScenario {
  normal,
  empty,
  dream,
  lowBalance,
  missionsComplete,
  newProfile,
  plus,
}

class PreviewStorage implements KoiniStorage {
  PreviewStorage([this._value]);

  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async => _value = value;
}

Future<KoiniStore> createPreviewStore(PreviewScenario scenario) async {
  final date = DateTime(2026, 11, 14, 9);
  final data = KoiniData();

  if (scenario != PreviewScenario.newProfile) {
    data
      ..name = 'Raka'
      ..email = 'ayah.bunda@example.test'
      ..pin = previewPin
      ..tutorialDone = true;
    if (scenario == PreviewScenario.plus) {
      data
        ..plan = Plan.yearly
        ..stories = true
        ..reminders = true
        ..heldGiftMoney = 100000;
    }
  }

  if (scenario != PreviewScenario.newProfile &&
      scenario != PreviewScenario.empty &&
      scenario != PreviewScenario.lowBalance) {
    data.entries.addAll([
      MoneyEntry(
        kind: EntryKind.allowance,
        date: date,
        amount: 100000,
        note: 'Uang saku mingguan',
        changes: KoiniStore.defaultSplit(100000),
      ),
      MoneyEntry(
        kind: EntryKind.spend,
        date: date,
        amount: 5000,
        note: 'Roti',
        changes: const {Jar.jajan: -5000},
        category: 'Makanan',
      ),
    ]);
  }
  if (scenario == PreviewScenario.lowBalance) {
    data.entries.add(
      MoneyEntry(
        kind: EntryKind.income,
        date: date,
        amount: 2000,
        note: 'Uang jajan tersisa',
        changes: const {Jar.jajan: 2000},
      ),
    );
  }
  if ({
    PreviewScenario.dream,
    PreviewScenario.plus,
    PreviewScenario.missionsComplete,
  }.contains(scenario)) {
    const dream = Dream(
      id: 'sepeda',
      name: 'Sepeda baru',
      image: 1,
      target: 1000000,
      weekly: 40000,
    );
    data.dreams.add(dream);
    data.entries.add(
      MoneyEntry(
        kind: EntryKind.save,
        date: date,
        amount: 400000,
        note: 'Tabungan sepeda',
        changes: const {Jar.tabung: 360000},
        dreamId: dream.id,
      ),
    );
  }
  if (scenario == PreviewScenario.missionsComplete) {
    data.missionScores.addAll({
      'catat': 5,
      'tabungan': 5,
      'butuh': 5,
      'impian': 5,
    });
    data.studyDays.addAll([
      for (var day = 12; day <= 14; day++)
        DateTime(2026, 11, day).toIso8601String(),
    ]);
  }

  final store = KoiniStore(
    PreviewStorage(jsonEncode(data.toJson())),
    clock: () => date,
  );
  await store.load();
  return store;
}
