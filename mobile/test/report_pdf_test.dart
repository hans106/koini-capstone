import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:koini/features/parents/services/report_pdf.dart';
import 'package:koini/features/parents/viewmodels/parent_overview_viewmodel.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

import 'koini_store_test.dart' show MemoryStorage, createProfile;

void main() {
  test('monthly report builds a real PDF offline', () async {
    final data = ReportPdfData(
      child: 'Raka',
      periodStart: DateTime(2026, 11),
      generatedAt: DateTime(2026, 11, 29),
      jars: {
        for (final jar in Jar.values) jar: (planned: 40000, actual: 25000),
      },
      savings: 25000,
      missions: '3/5',
      challengeCount: 1,
      challengeRewards: 20000,
      bonusRewards: 10000,
      badges: const ['Dermawan cilik'],
      history: [
        MoneyEntry(
          kind: EntryKind.spend,
          date: DateTime(2026, 11, 3),
          amount: 5000,
          note: 'Bakso',
          changes: const {Jar.jajan: -5000},
        ),
      ],
    );
    final bytes = await buildReportPdf(data);
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));
    expect(data.fileName, 'rapor-koini-2026-11.pdf');
  });

  group('exportPdf', () {
    late KoiniStore store;
    late ParentOverviewViewModel model;

    setUp(() async {
      final now = DateTime(2026, 11, 15, 10);
      store = KoiniStore(MemoryStorage(), clock: () => now);
      await createProfile(store);
      model = ParentOverviewViewModel(store, monthly: true);
    });

    tearDown(() => model.dispose());

    test('hands the PDF bytes and file name to the share callback', () async {
      String? name;
      var size = 0;
      final ok = await model.exportPdf((bytes, fileName) async {
        name = fileName;
        size = bytes.length;
      });
      expect(ok, isTrue);
      expect(name, 'rapor-koini-2026-11.pdf');
      expect(size, greaterThan(1000));
      expect(model.error, isNull);
    });

    test('reports a friendly error when sharing fails', () async {
      final ok = await model.exportPdf((_, _) async => throw StateError('x'));
      expect(ok, isFalse);
      expect(model.error, contains('PDF belum bisa dibuat'));
      expect(model.busy, isFalse);
    });
  });
}
