import 'package:flutter_test/flutter_test.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_storage.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

class MemoryStorage implements KoiniStorage {
  String? saved;
  bool fail = false;

  @override
  Future<String?> read() async => saved;

  @override
  Future<void> write(String value) async {
    if (fail) throw StateError('storage unavailable');
    saved = value;
  }
}

Future<void> createProfile(KoiniStore store) async {
  expect(
    await store.setUp(
      name: 'Raka',
      age: 9,
      email: 'raka@example.test',
      pin: '123456',
      allowance: 100000,
      limit: 10000,
      reminders: false,
      split: KoiniStore.defaultSplit(100000),
    ),
    isNull,
  );
}

void main() {
  late MemoryStorage storage;
  late KoiniStore store;
  late DateTime now;

  setUp(() async {
    now = DateTime(2026, 11, 14);
    storage = MemoryStorage();
    store = KoiniStore(storage, clock: () => now);
    await createProfile(store);
  });

  test(
    'weekly allowance is recorded once and spending updates only Jajan',
    () async {
      expect(store.total, 0);
      final results = await Future.wait([
        store.receiveAllowance(),
        store.receiveAllowance(),
      ]);
      expect(results.where((value) => value == null), hasLength(1));
      expect(await store.receiveAllowance(), isNotNull);
      expect(
        await store.record(kind: EntryKind.spend, amount: 5000, note: 'Roti'),
        isNull,
      );
      expect(store.balance(Jar.jajan), 45000);
      expect(store.balance(Jar.tabung), 40000);
      expect(store.balance(Jar.berbagi), 10000);
      expect(store.total, 95000);
      expect(
        await store.record(kind: EntryKind.spend, amount: 6000, note: ''),
        isNotNull,
      );
      expect(
        await store.record(kind: EntryKind.give, amount: 11000, note: ''),
        isNotNull,
      );
      expect(store.total, 95000);
      expect(
        await store.setAllowance(50000, 10000, KoiniStore.defaultSplit(50000)),
        isNull,
      );
      expect(await store.receiveAllowance(), isNotNull);
      expect(store.total, 95000);
      now = DateTime(2026, 11, 16);
      expect(await store.receiveAllowance(), isNull);
      expect(store.total, 145000);
    },
  );

  test('allocating recorded savings never creates cash; transfers respect reservations', () async {
    await store.receiveAllowance();
    await store.addDream('Sepeda', 1, 100000, 20000);
    final dream = store.dreams.single;
    expect(
      await store.record(
        kind: EntryKind.save,
        amount: 40000,
        note: '',
        source: Jar.tabung,
        dream: dream,
      ),
      isNull,
    );
    expect(store.progress(dream), .4);
    expect(store.remaining(dream), 60000);
    expect(store.total, 100000);
    expect(store.availableSavings, 0);
    expect(
      await store.record(
        kind: EntryKind.transfer,
        amount: 1,
        note: '',
        source: Jar.tabung,
        destination: Jar.jajan,
      ),
      isNotNull,
    );
    expect(
      await store.record(
        kind: EntryKind.save,
        amount: 20000,
        note: '',
        source: Jar.jajan,
        dream: dream,
      ),
      isNull,
    );
    expect(store.progress(dream), .6);
    expect(store.balance(Jar.jajan), 30000);
    expect(store.total, 100000);
    expect(
      await store.record(
        kind: EntryKind.save,
        amount: 40001,
        note: '',
        dream: dream,
      ),
      isNotNull,
    );
    expect(
      await store.record(
        kind: EntryKind.save,
        amount: 40000,
        note: '',
        dream: dream,
      ),
      isNull,
    );
    expect(store.progress(dream), 1);
    expect(store.remaining(dream), 0);
    expect(store.total, 140000);

    final reloaded = KoiniStore(storage, clock: () => now);
    await reloaded.load();
    expect(reloaded.progress(reloaded.dreams.single), 1);
    expect(reloaded.total, store.total);
    expect(reloaded.receivedThisWeek, isTrue);
  });

  test('PIN protects plan activation and can be changed', () async {
    expect(await store.activatePlan(Plan.yearly, '000000'), isNotNull);
    expect(store.plan, Plan.free);
    expect(await store.activatePlan(Plan.yearly, '123456'), isNull);
    expect(await store.updatePin('123456', '654321'), isNull);

    final reloaded = KoiniStore(storage, clock: () => now);
    await reloaded.load();
    expect(reloaded.plan, Plan.yearly);
    expect(reloaded.checkPin('123456'), isNotNull);
    expect(reloaded.checkPin('654321'), isNull);
  });

  test(
    'mission replays award only extra stars and earned streaks persist',
    () async {
      await store.completeMission('catat', 3);
      await store.completeMission('catat', 2);
      expect(store.stars, 9);
      now = DateTime(2026, 11, 15);
      await store.completeMission('catat', 5);
      expect(store.stars, 15);
      expect(store.streak, 2);
      now = DateTime(2026, 11, 18);
      expect(store.streak, 0);
      expect(store.longestStreak, 2);
    },
  );

  test('recording and returning a gift preserves the sum and does not add a new gift', () async {
    expect(
      await store.recordGift(
        100000,
        {Jar.tabung: 40000, Jar.jajan: 30000, Jar.berbagi: 10000},
        20000,
        'THR',
      ),
      isNull,
    );
    expect(store.heldGift, 20000);
    expect(store.total, 80000);
    expect(await store.releaseGift(20001, Jar.tabung), isNotNull);
    expect(await store.releaseGift(15000, Jar.tabung), isNull);
    expect(store.heldGift + store.total, 100000);
    expect(
      store.entries.fold<int>(0, (sum, entry) => sum + entry.income),
      100000,
    );
    expect(
      store.entries.where((entry) => entry.kind == EntryKind.gift),
      hasLength(1),
    );
  });

  test('a failed save leaves balances intact and can be retried', () async {
    storage.fail = true;
    expect(await store.receiveAllowance(), isNotNull);
    expect(store.total, 0);
    expect(store.receivedThisWeek, isFalse);
    storage.fail = false;
    expect(await store.receiveAllowance(), isNull);
    expect(store.total, 100000);
  });

  test('smart plan rounds up weeks and handles an already funded dream', () {
    const plan = SmartPlan(target: 1000000, saved: 350000, weekly: 40000);
    expect(plan.remaining, 650000);
    expect(plan.weeks, 17);
    expect(plan.balanceAt(16), 990000);
    expect(plan.balanceAt(17), 1000000);
    expect(const SmartPlan(target: 100, saved: 120, weekly: 10).weeks, 0);
  });

  test(
    'allowance supports daily/monthly periods and idempotent sisa jajan sweep',
    () async {
      expect(
        await store.setAllowance(20000, 10000, {
          Jar.tabung: 8000,
          Jar.jajan: 10000,
          Jar.berbagi: 2000,
        }, period: AllowancePeriod.daily),
        isNull,
      );
      expect(store.allowancePeriod, AllowancePeriod.daily);
      expect(await store.receiveAllowance(), isNull);
      expect(
        await store.record(kind: EntryKind.spend, amount: 4000, note: 'Roti'),
        isNull,
      );
      expect(store.balance(Jar.jajan), 6000);

      // Move clock to next day: leftover 6.000 moves from Jajan to Tabung once.
      now = DateTime(2026, 11, 15, 8);
      expect(await store.sweepLeftoverJajan(), 6000);
      expect(store.balance(Jar.jajan), 0);
      expect(store.balance(Jar.tabung), 14000);
      // Calling again for the same ended period must be idempotent (0 moved).
      expect(await store.sweepLeftoverJajan(), 0);
      expect(store.balance(Jar.tabung), 14000);
    },
  );

  test(
    'piggy bank check records physical cash and difference accurately',
    () async {
      expect(await store.receiveAllowance(), isNull);
      expect(await store.recordPiggyBankCheck(95000), isNull);
      expect(store.piggyChecks, hasLength(1));
      expect(store.piggyChecks.first.physicalAmount, 95000);
      expect(store.piggyChecks.first.recordedAmount, 100000);
      expect(store.piggyChecks.first.difference, -5000);
    },
  );

  test('completing first-time guide updates tutorialDone state', () async {
    expect(store.tutorialDone, isFalse);
    expect(await store.completeTutorial(), isNull);
    expect(store.tutorialDone, isTrue);
  });
}
