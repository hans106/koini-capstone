import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/viewmodels/parent_overview_viewmodel.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/widgets/dream_report.dart';
import 'package:koini/features/rewards/widgets/badge_icon.dart';
import 'package:koini/features/transactions/widgets/transaction_summary.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ParentOverviewViewModel, ParentReportView>(
      (ref, view) => ParentOverviewViewModel(view.store, monthly: view.monthly),
    );

class ParentReportView extends ConsumerStatefulWidget {
  const ParentReportView({
    super.key,
    required this.store,
    this.monthly = false,
  });
  final KoiniStore store;
  final bool monthly;

  @override
  ConsumerState<ParentReportView> createState() => _ParentReportViewState();
}

class _ParentReportViewState extends ConsumerState<ParentReportView> {
  KoiniStore get store => widget.store;
  late final _provider = _viewModelProvider(widget);
  ParentOverviewViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) {
    final monthly = widget.monthly;
    final period = model.entries;
    final periodLabel = monthly ? 'Bulan ini' : 'Minggu ini';
    final dream = model.dream;
    final completed = model.completedMissions.toList();
    return KPage(
      title: monthly ? 'Rapor bulanan' : 'Perkembangan',
      subtitle: '${model.child} · ${dateLabel(model.periodStart)}',
      footer: KButton(
        'Kembali ke ringkasan',
        onTap: () => Navigator.pop(context),
      ),
      children: [
        KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading(
                monthly ? 'Uang bulan ini' : 'Rencana minggu ini',
                size: 19,
              ),
              const Gap(7),
              Row(
                children: [
                  Expanded(child: caption(periodLabel)),
                  SizedBox(
                    width: 86,
                    child: caption('Rencana', align: TextAlign.end),
                  ),
                  SizedBox(
                    width: 86,
                    child: caption('Tercatat', align: TextAlign.end),
                  ),
                ],
              ),
              const Gap(6),
              for (final row in model.jarReport.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: heading(
                          row.key.label,
                          size: 16,
                          color: KColors.jar(row.key),
                        ),
                      ),
                      SizedBox(
                        width: 86,
                        child: caption(
                          rupiah(row.value.planned),
                          align: TextAlign.end,
                        ),
                      ),
                      SizedBox(
                        width: 86,
                        child: caption(
                          rupiah(row.value.actual),
                          align: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
              const Gap(7),
              caption('Rencana mengacu pada pengaturan uang saku saat ini.'),
            ],
          ),
        ),
        const Gap(9),
        if (dream != null) ...[
          DreamReport(
            dream: dream,
            saved: model.savedFor(dream),
            progress: model.progress(dream),
          ),
          const Gap(9),
        ],
        Row(
          children: [
            Expanded(
              child: Stat(
                'Tabungan $periodLabel',
                rupiah(model.savings),
                color: KColors.mint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Stat('Misi selesai (total)', model.missionFraction),
            ),
          ],
        ),
        const Gap(9),
        heading(monthly ? 'Pencapaian' : 'Hasil misi', size: 19),
        const Gap(6),
        if (monthly)
          for (final badge in model.earnedBadges) ...[
            KRow(badge.name, badge.description, icon: const BadgeIcon(true)),
            const Gap(6),
          ],
        if (completed.isEmpty)
          const KRow(
            'Belum ada misi selesai',
            'Hasil misi anak akan muncul di sini.',
          ),
        for (final mission in completed) ...[
          KRow(
            mission.name,
            mission.result,
            icon: const Icon(Icons.star, color: KColors.gold),
          ),
          const Gap(6),
        ],
        const Gap(9),
        heading('Aktivitas terbaru', size: 19),
        const Gap(6),
        if (period.isEmpty) const KRow('Belum ada aktivitas', ''),
        for (final entry in period.take(6)) ...[EntryRow(entry), const Gap(6)],
        const Gap(),
        const KCallout(
          'Saran untuk Ayah/Bunda',
          'Ajak anak bercerita tentang satu pilihan uangnya minggu ini.',
        ),
      ],
    );
  }
}

@Preview(
  name: 'Detail perkembangan',
  group: 'Orang tua',
  size: koiniPreviewSize,
)
Widget parentReportPreview() => KoiniPreviewHost(
  page: (context, store) => ParentReportView(store: store),
  scenario: PreviewScenario.missionsComplete,
  returnPage: (context, store) => ParentDashboardView(store: store),
);

@Preview(name: 'Rapor bulanan', group: 'Plus', size: koiniPreviewSize)
Widget monthlyReportPreview() => KoiniPreviewHost(
  page: (context, store) => ParentReportView(store: store, monthly: true),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);
