import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/viewmodels/parent_overview_viewmodel.dart';
import 'package:koini/features/parents/widgets/dream_report.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ParentOverviewViewModel, ParentDashboardView>(
      (ref, view) => ParentOverviewViewModel(view.store),
    );

class ParentDashboardView extends ConsumerStatefulWidget {
  const ParentDashboardView({super.key, required this.store});
  final KoiniStore store;

  @override
  ConsumerState<ParentDashboardView> createState() =>
      _ParentDashboardViewState();
}

class _ParentDashboardViewState extends ConsumerState<ParentDashboardView> {
  KoiniStore get store => widget.store;
  late final _provider = _viewModelProvider(widget);
  ParentOverviewViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    final dream = model.dream;
    final saved = model.savings;
    final spent = model.spent;
    final change = model.weeklyChange;
    return KPage(
      title: 'Ringkasan orang tua',
      subtitle: '${model.child} · ${dateLabel(model.periodStart)}',
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
            onTap: () => openPage(context, KRoute.parentReport),
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
          DreamReport(
            dream: dream,
            saved: model.savedFor(dream),
            progress: model.progress(dream),
          ),
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
                model.missionFraction,
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
          'Pilih paket pendampingan · ${model.plan.label}',
          color: KColors.gold,
          onTap: () => showPlus(context),
        ),
        const Gap(7),
        KRow(
          'Rapor bulanan',
          'Ringkasan belajar sebulan · Tahunan',
          onTap: () => openYearly(
            context,
            store,
            () => openPage(context, KRoute.monthlyReport),
          ),
        ),
        const Gap(7),
        KRow(
          'Setelan orang tua',
          'Uang saku dan PIN',
          onTap: () => openPage(context, KRoute.parentSettings),
        ),
      ],
    );
  }
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
