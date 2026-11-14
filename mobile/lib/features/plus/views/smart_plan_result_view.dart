import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

class SmartPlanResultView extends StatelessWidget {
  const SmartPlanResultView({
    super.key,
    required this.store,
    required this.dream,
    required this.plan,
  });
  final KoiniStore store;
  final Dream? dream;
  final SmartPlan plan;

  @override
  Widget build(BuildContext context) {
    final weeks = plan.weeks;
    final saveToDream =
        dream != null &&
        plan.target == dream!.target &&
        plan.saved == store.savedFor(dream!) &&
        weeks > 0;
    return KPage(
      title: 'Rencana Pintar',
      footer: KButton(
        saveToDream ? 'Pakai rencana ini' : 'Selesai',
        onTap: () async {
          if (saveToDream) {
            final error = await store.setDreamPlan(dream!, plan.weekly);
            if (!context.mounted) return;
            if (error != null) {
              note(context, error);
              return;
            }
            note(context, 'Rencana impian tersimpan.');
          }
          if (context.mounted) Navigator.pop(context);
        },
      ),
      children: [
        KCard(
          bright: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(dream?.name ?? 'Target tabungan', size: 20),
              const Gap(8),
              Row(
                children: [
                  Expanded(child: caption('Perkiraan waktu')),
                  heading('$weeks minggu', color: KColors.gold, size: 24),
                ],
              ),
              Row(
                children: [
                  Expanded(child: caption('Menabung')),
                  caption(
                    '${rupiah(plan.weekly)} per minggu',
                    color: KColors.mint,
                  ),
                ],
              ),
              const Gap(),
              GoalProgress((plan.saved / plan.target).clamp(0, 1)),
              const Gap(6),
              caption('Kurang ${rupiah(plan.remaining)}'),
            ],
          ),
        ),
        const Gap(),
        heading('Langkah rencanamu', size: 20, color: KColors.gold),
        const Gap(6),
        if (weeks > 1) ...[
          KRow(
            'Minggu 1 · Mulai',
            'Sisihkan ${rupiah(plan.weekly)}, jadi ${rupiah(plan.balanceAt(1))}.',
            icon: const Icon(Icons.star, color: KColors.gold),
          ),
          const Gap(7),
        ],
        if (weeks > 2) ...[
          KRow(
            'Minggu ${weeks - 1} · Hampir sampai',
            'Tabunganmu ${rupiah(plan.balanceAt(weeks - 1))}.',
            icon: const Icon(Icons.star, color: KColors.gold),
          ),
          const Gap(7),
        ],
        KRow(
          weeks == 0 ? 'Target sudah tercapai!' : 'Minggu $weeks · Terwujud!',
          'Tabunganmu cukup untuk target.',
          icon: const Icon(Icons.star, color: KColors.gold),
        ),
        const Gap(),
        const KCallout(
          'Kata Koini',
          'Sisihkan jumlah yang nyaman dilakukan rutin setiap minggu.',
        ),
      ],
    );
  }
}

@Preview(name: 'Rencana Pintar - hasil', group: 'Plus', size: koiniPreviewSize)
Widget smartPlanResultPreview() => KoiniPreviewHost(
  page: (context, store) => SmartPlanResultView(
    store: store,
    dream: store.activeDream,
    plan: SmartPlan(
      target: store.activeDream!.target,
      saved: store.savedFor(store.activeDream!),
      weekly: store.activeDream!.weekly,
    ),
  ),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.dreams),
);
