import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/missions/mission_content.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/widgets/dream_report.dart';
import 'package:koini/features/rewards/controllers/badge_progress.dart';
import 'package:koini/features/rewards/widgets/badge_icon.dart';
import 'package:koini/features/transactions/widgets/transaction_summary.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class ParentReportView extends StatelessWidget {
  const ParentReportView({
    super.key,
    required this.store,
    this.monthly = false,
  });
  final KoiniStore store;
  final bool monthly;

  @override
  Widget build(BuildContext context) {
    final period = monthly ? store.thisMonth : store.thisWeek;
    final periodLabel = monthly ? 'Bulan ini' : 'Minggu ini';
    final dream = store.activeDream;
    final first = monthly
        ? DateTime(store.now.year, store.now.month)
        : weekStart(store.now);
    final firstMonday = (DateTime.monday - first.weekday) % 7 + 1;
    final plannedReceipts = monthly
        ? (store.now.day < firstMonday
              ? 0
              : 1 + (store.now.day - firstMonday) ~/ 7)
        : 1;
    return KPage(
      title: monthly ? 'Rapor bulanan' : 'Perkembangan',
      subtitle: '${store.name} · ${dateLabel(first)}',
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
              for (final (jar, amount) in [
                (Jar.tabung, store.netSavings(period)),
                (Jar.jajan, store.amountFor(EntryKind.spend, period)),
                (Jar.berbagi, store.amountFor(EntryKind.give, period)),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: heading(
                          jar.label,
                          size: 16,
                          color: KColors.jar(jar),
                        ),
                      ),
                      SizedBox(
                        width: 86,
                        child: caption(
                          rupiah(store.split[jar]! * plannedReceipts),
                          align: TextAlign.end,
                        ),
                      ),
                      SizedBox(
                        width: 86,
                        child: caption(rupiah(amount), align: TextAlign.end),
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
          DreamReport(store: store, dream: dream),
          const Gap(9),
        ],
        Row(
          children: [
            Expanded(
              child: Stat(
                'Tabungan $periodLabel',
                rupiah(store.netSavings(period)),
                color: KColors.mint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Stat(
                'Misi selesai (total)',
                '${store.scores.length}/${missions.length}',
              ),
            ),
          ],
        ),
        const Gap(9),
        heading(monthly ? 'Pencapaian' : 'Hasil misi', size: 19),
        const Gap(6),
        if (monthly)
          for (final badge in badges(store).where((badge) => badge.earned)) ...[
            KRow(badge.name, badge.description, icon: const BadgeIcon(true)),
            const Gap(6),
          ],
        if (store.scores.isEmpty)
          const KRow(
            'Belum ada misi selesai',
            'Hasil misi anak akan muncul di sini.',
          ),
        for (final mission in missions.where(
          (mission) => store.scores.containsKey(mission.id),
        )) ...[
          KRow(
            mission.name,
            '${store.scores[mission.id]}/5 benar · ${store.scores[mission.id]! * 3} bintang',
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
