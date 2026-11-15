import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/transactions/viewmodels/transaction_history_viewmodel.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/features/transactions/widgets/transaction_summary.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class StructuredHistoryView extends StatefulWidget {
  const StructuredHistoryView({
    super.key,
    required this.store,
    this.readOnly = false,
  });
  final KoiniStore store;
  final bool readOnly;

  @override
  State<StructuredHistoryView> createState() => _StructuredHistoryViewState();
}

class _StructuredHistoryViewState extends State<StructuredHistoryView> {
  late final model = StructuredHistoryViewModel(widget.store);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) {
      final filter = model.filter;
      final shown = model.visibleEntries;
      return KPage(
        title: 'Catatan terstruktur',
        subtitle: 'Minggu ini · ${dateLabel(model.firstDay)}',
        footer: widget.readOnly
            ? null
            : KButton(
                'Catat uang baru',
                onTap: () =>
                    openPage(context, AddTransactionView(store: widget.store)),
              ),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Pill(
                'Semua',
                selected: filter == null,
                onTap: () => model.select(null),
              ),
              for (final kind in [
                EntryKind.spend,
                EntryKind.save,
                EntryKind.give,
                EntryKind.income,
              ])
                Pill(
                  kind.label,
                  selected: filter == kind,
                  onTap: () => model.select(kind),
                ),
            ],
          ),
          const Gap(),
          Totals(model.totals),
          const Gap(),
          for (final summary in model.summaries) ...[
            KCard(
              bright: true,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: heading(summary.kind.label, size: 17)),
                      heading(
                        rupiah(summary.amount),
                        color: KColors.gold,
                        size: 20,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: caption('Rencana')),
                      caption(rupiah(summary.planned)),
                    ],
                  ),
                  const Gap(7),
                  GoalProgress(summary.ratio, color: KColors.jar(summary.jar)),
                ],
              ),
            ),
            const Gap(8),
          ],
          if (filter == null || filter == EntryKind.spend) ...[
            heading('Kategori jajan', size: 17),
            const Gap(6),
            for (final entry in model.spendingByCategory.entries)
              KRow(
                entry.key,
                '',
                trailing: heading(rupiah(entry.value), size: 15),
              ),
            const Gap(8),
          ],
          if (shown.isEmpty)
            const KCallout(
              'Belum ada catatan',
              'Catatan untuk kategori ini akan muncul di sini.',
            ),
          for (final entry in shown) ...[EntryRow(entry), const Gap(6)],
        ],
      );
    },
  );
}

@Preview(
  name: 'Catatan terstruktur',
  group: 'Transaksi',
  size: koiniPreviewSize,
)
Widget structuredHistoryPreview() => KoiniPreviewHost(
  page: (context, store) => StructuredHistoryView(store: store),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.history),
);
