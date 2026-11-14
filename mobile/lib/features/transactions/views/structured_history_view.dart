import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/transactions/controllers/transaction_controller.dart';
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
  EntryKind? filter;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final period = widget.store.thisWeek;
      final savings = widget.store.netSavings(period);
      final shown = period
          .where(
            (entry) =>
                filter == null ||
                (filter == EntryKind.income
                    ? entry.income > 0
                    : entry.kind == filter),
          )
          .toList();
      return KPage(
        title: 'Catatan terstruktur',
        subtitle: 'Minggu ini · ${dateLabel(weekStart(widget.store.now))}',
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
                onTap: () => setState(() => filter = null),
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
                  onTap: () => setState(() => filter = kind),
                ),
            ],
          ),
          const Gap(),
          Totals(period),
          const Gap(),
          for (final (kind, jar) in [
            (EntryKind.spend, Jar.jajan),
            (EntryKind.save, Jar.tabung),
            (EntryKind.give, Jar.berbagi),
          ])
            if (filter == null || filter == kind) ...[
              KCard(
                bright: true,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: heading(kind.label, size: 17)),
                        heading(
                          rupiah(
                            kind == EntryKind.save
                                ? savings
                                : widget.store.amountFor(kind, period),
                          ),
                          color: KColors.gold,
                          size: 20,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: caption('Rencana')),
                        caption(rupiah(widget.store.split[jar]!)),
                      ],
                    ),
                    const Gap(7),
                    GoalProgress(
                      widget.store.split[jar] == 0
                          ? 0
                          : ((kind == EntryKind.save
                                        ? savings
                                        : widget.store.amountFor(
                                            kind,
                                            period,
                                          )) /
                                    widget.store.split[jar]!)
                                .clamp(0, 1),
                      color: KColors.jar(jar),
                    ),
                  ],
                ),
              ),
              const Gap(8),
            ],
          if (filter == null || filter == EntryKind.spend) ...[
            heading('Kategori jajan', size: 17),
            const Gap(6),
            for (final category in [...categories, 'Tanpa kategori'])
              if (period.any(
                (entry) =>
                    entry.kind == EntryKind.spend &&
                    (entry.category ?? 'Tanpa kategori') == category,
              ))
                KRow(
                  category,
                  '',
                  trailing: heading(
                    rupiah(
                      widget.store.amountFor(
                        EntryKind.spend,
                        period.where(
                          (entry) =>
                              (entry.category ?? 'Tanpa kategori') == category,
                        ),
                      ),
                    ),
                    size: 15,
                  ),
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
