import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/home/viewmodels/weekly_summary_viewmodel.dart';
import 'package:koini/features/transactions/widgets/transaction_summary.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<WeeklySummaryViewModel, WeeklySummaryView>(
      (ref, view) => WeeklySummaryViewModel(view.store),
    );

class WeeklySummaryView extends ConsumerStatefulWidget {
  const WeeklySummaryView({super.key, required this.store});
  final KoiniStore store;

  @override
  ConsumerState<WeeklySummaryView> createState() => _WeeklySummaryViewState();
}

class _WeeklySummaryViewState extends ConsumerState<WeeklySummaryView> {
  KoiniStore get store => widget.store;
  late final _provider = _viewModelProvider(widget);
  WeeklySummaryViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) => KPage(
    title: 'Minggu ini',
    footer: KButton('Selesai', onTap: () => Navigator.pop(context)),
    children: [
      heading('Ringkasan minggumu', size: 23, color: KColors.gold),
      const Text(
        'Koini menghitung dari catatanmu. Kamu tidak perlu mengisi apa-apa.',
      ),
      const Gap(),
      Totals(model.totals),
      const Gap(),
      KCard(
        bright: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('Ringkasan minggu ini', size: 19),
            const Gap(7),
            for (final kind in [
              EntryKind.allowance,
              EntryKind.save,
              EntryKind.spend,
              EntryKind.give,
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(kind.label)),
                    heading(
                      rupiah(model.amount(kind)),
                      color: entryColor(kind),
                      size: 16,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

@Preview(name: 'Ringkasan mingguan', group: 'Beranda', size: koiniPreviewSize)
Widget weeklySummaryPreview() => KoiniPreviewHost(
  page: (context, store) => WeeklySummaryView(store: store),
  returnPage: (context, store) => ChildShell(store: store),
);
