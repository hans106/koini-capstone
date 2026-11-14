import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/features/transactions/widgets/transaction_summary.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class TransactionHistoryView extends StatelessWidget {
  const TransactionHistoryView({
    super.key,
    required this.store,
    required this.onStructured,
  });
  final KoiniStore store;
  final VoidCallback onStructured;

  @override
  Widget build(BuildContext context) {
    final period = store.thisWeek;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: caption('Ringkasan minggu ini')),
            TextButton(
              onPressed: onStructured,
              child: const Text('Lihat rincian'),
            ),
          ],
        ),
        Totals(period),
        const Gap(16),
        if (store.entries.isEmpty)
          const KCallout(
            'Belum ada catatan',
            'Catat uang yang kamu terima atau pakai hari ini.',
          ),
        for (final date
            in store.entries.map((entry) => dayStart(entry.date)).toSet()) ...[
          heading(
            date == dayStart(store.now) ? 'Hari ini' : dateLabel(date),
            size: 16,
          ),
          const Gap(6),
          for (final entry in store.entries.where(
            (entry) => dayStart(entry.date) == date,
          )) ...[EntryRow(entry), const Gap(7)],
          const Gap(6),
        ],
        KButton(
          'Catat uang baru',
          onTap: () => openPage(context, AddTransactionView(store: store)),
        ),
      ],
    );
  }
}

@Preview(name: 'Riwayat transaksi', group: 'Transaksi', size: koiniPreviewSize)
Widget historyPreview() => KoiniPreviewHost(
  page: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.history),
);
