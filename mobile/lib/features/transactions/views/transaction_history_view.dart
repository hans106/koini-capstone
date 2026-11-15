import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/transactions/viewmodels/transaction_history_viewmodel.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/features/transactions/widgets/transaction_summary.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class TransactionHistoryView extends StatefulWidget {
  const TransactionHistoryView({
    super.key,
    required this.store,
    required this.onStructured,
  });
  final KoiniStore store;
  final VoidCallback onStructured;

  @override
  State<TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<TransactionHistoryView> {
  KoiniStore get store => widget.store;
  late final model = TransactionHistoryViewModel(store);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: model, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) {
    final groups = model.byDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: caption('Ringkasan minggu ini')),
            TextButton(
              onPressed: widget.onStructured,
              child: const Text('Lihat rincian'),
            ),
          ],
        ),
        Totals(model.totals),
        const Gap(16),
        if (groups.isEmpty)
          const KCallout(
            'Belum ada catatan',
            'Catat uang yang kamu terima atau pakai hari ini.',
          ),
        for (final group in groups.entries) ...[
          heading(model.labelFor(group.key), size: 16),
          const Gap(6),
          for (final entry in group.value) ...[EntryRow(entry), const Gap(7)],
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
