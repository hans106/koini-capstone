import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/missions/mission_content.dart';
import 'package:koini/features/parents/views/parent_report_view.dart';
import 'package:koini/features/parents/views/parent_settings_view.dart';
import 'package:koini/features/parents/widgets/dream_report.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class ParentDashboardView extends StatelessWidget {
  const ParentDashboardView({super.key, required this.store});
  final KoiniStore store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final dream = store.activeDream;
      final week = store.thisWeek;
      final saved = store.netSavings(week);
      final spent = store.amountFor(EntryKind.spend, week);
      final previousWeek = weekStart(store.now)
          .subtract(const Duration(days: 7));
      final previousSaved = store.netSavings(
        store.entries.where(
          (entry) =>
              !entry.date.isBefore(previousWeek) &&
              entry.date.isBefore(weekStart(store.now)),
        ),
      );
      final change = saved - previousSaved;
      return KPage(
        title: 'Ringkasan orang tua',
        subtitle: '${store.name} · ${dateLabel(weekStart(store.now))}',
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KButton(
              'Keluar ke profil anak',
              secondary: true,
              onTap: () => Navigator.pop(context),
            ),
            const Gap(7),
            KButton(
              'Detail perkembangan',
              onTap: () => openPage(context, ParentReportView(store: store)),
            ),
          ],
        ),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Pill(
              'Area Ayah/Bunda · PIN terverifikasi',
              color: KColors.mint,
              icon: Icons.lock_outline,
            ),
          ),
          const Gap(),
          KCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                caption('Tabungan minggu ini'),
                Row(
                  children: [
                    Expanded(
                      child: heading(
                        rupiah(saved),
                        size: 27,
                        color: KColors.mint,
                      ),
                    ),
                    Flexible(
                      child: caption(
                        '${change > 0 ? '+' : ''}${rupiah(change)} dari minggu lalu',
                      ),
                    ),
                  ],
                ),
                caption('Catatan tabungan anak.'),
              ],
            ),
          ),
          const Gap(9),
          if (dream != null) ...[
            DreamReport(store: store, dream: dream),
            const Gap(9),
          ] else ...[
            const KCallout(
              'Belum ada impian',
              'Progres impian anak akan muncul di sini.',
            ),
            const Gap(9),
          ],
          Row(
            children: [
              Expanded(
                child: Stat(
                  'Misi selesai',
                  '${store.scores.length}/${missions.length}',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stat(
                  'Jajan tercatat',
                  rupiah(spent),
                  color: KColors.peach,
                ),
              ),
            ],
          ),
          const Gap(9),
          KRow(
            'Koini Plus',
            'Pilih paket pendampingan · ${store.plan.label}',
            color: KColors.gold,
            onTap: () => showPlus(context, store),
          ),
          const Gap(7),
          KRow(
            'Rapor bulanan',
            'Ringkasan belajar sebulan · Tahunan',
            onTap: () => openYearly(
              context,
              store,
              () => openPage(
                context,
                ParentReportView(store: store, monthly: true),
              ),
            ),
          ),
          const Gap(7),
          KRow(
            'Setelan orang tua',
            'Uang saku, email, dan PIN',
            onTap: () => openPage(context, ParentSettingsView(store: store)),
          ),
        ],
      );
    },
  );
}

@Preview(
  name: 'Ringkasan orang tua',
  group: 'Orang tua',
  size: koiniPreviewSize,
)
Widget parentDashboardPreview() => KoiniPreviewHost(
  page: (context, store) => ParentDashboardView(store: store),
  scenario: PreviewScenario.dream,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.profile),
);
