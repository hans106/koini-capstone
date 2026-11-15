import 'package:flutter_test/flutter_test.dart';
import 'package:koini/features/home/viewmodels/home_viewmodel.dart';
import 'package:koini/features/transactions/viewmodels/transaction_viewmodel.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

import 'koini_store_test.dart' show MemoryStorage, createProfile;

void main() {
  test(
    'transaction reports failures and refreshes the home balance on retry',
    () async {
      final storage = MemoryStorage();
      final store = KoiniStore(storage, clock: () => DateTime(2026, 11, 14));
      await createProfile(store);
      await store.receiveAllowance();
      final home = HomeViewModel(store);
      final transaction = TransactionViewModel(store, kind: EntryKind.spend);
      addTearDown(() {
        transaction.dispose();
        home.dispose();
        store.dispose();
      });

      final totals = <int>[];
      home.addListener(() => totals.add(home.total));
      transaction.enterDigit('5');
      transaction.enterDigit('000');
      storage.fail = true;
      expect(await transaction.save('Roti'), isFalse);
      expect(transaction.error, isNotNull);
      expect(transaction.busy, isFalse);
      expect(totals, isEmpty);

      storage.fail = false;
      final retry = transaction.save('Roti');
      expect(transaction.busy, isTrue);
      expect(await transaction.save('Roti'), isFalse);
      expect(await retry, isTrue);
      expect(transaction.busy, isFalse);
      expect(transaction.error, isNull);
      expect(totals, [95000]);
      expect(home.balance(Jar.jajan), 45000);
      expect(home.balance(Jar.tabung), 40000);
      expect(home.balance(Jar.berbagi), 10000);
    },
  );
}
