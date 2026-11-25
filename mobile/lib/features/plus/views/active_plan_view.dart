import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/plus/viewmodels/plus_packages_viewmodel.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ActivePlanViewModel, ActivePlanView>(
      (ref, view) => ActivePlanViewModel(view.store),
    );

class ActivePlanView extends ConsumerStatefulWidget {
  const ActivePlanView({
    super.key,
    required this.store,
    required this.yearlyFeatures,
  });
  final KoiniStore store;
  final Map<String, VoidCallback> yearlyFeatures;

  @override
  ConsumerState<ActivePlanView> createState() => _ActivePlanViewState();
}

class _ActivePlanViewState extends ConsumerState<ActivePlanView> {
  late final _provider = _viewModelProvider(widget);
  ActivePlanViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) => Celebration(
    title: 'Koini Plus aktif!',
    message:
        'Paket ${model.plan.label} · ${model.plan.price}\nAktivasi simulasi',
    button: 'Kembali ke Ringkasan',
    details: [
      KRow(
        'Tantangan Hadiah',
        'Buat tantangan nilai ujian, lomba, atau tugas rumah',
        color: KColors.gold,
        icon: const Icon(Icons.emoji_events_rounded, color: KColors.gold),
        onTap: () => openPage(context, KRoute.parentChallenges),
      ),
      const Gap(8),
      KRow(
        'Bonus Tabungan',
        'Berikan bonus jika anak menjaga tabungan utuh',
        color: KColors.gold,
        icon: const Icon(Icons.savings_rounded, color: KColors.gold),
        onTap: () => openPage(context, KRoute.parentSavingsBonus),
      ),
      const Gap(8),
      KRow(
        'Catatan terstruktur',
        'Rincian transaksi per kategori',
        color: KColors.gold,
        icon: const Icon(Icons.star, color: KColors.gold),
        onTap: () => openPage(context, KRoute.structuredHistory, extra: true),
      ),
      if (model.hasYearly)
        for (final entry in widget.yearlyFeatures.entries) ...[
          const Gap(8),
          KRow(
            entry.key,
            '',
            color: KColors.gold,
            icon: const Icon(Icons.star, color: KColors.gold),
            onTap: entry.value,
          ),
        ],
    ],
  );
}

@Preview(name: 'Paket Tahunan aktif', group: 'Plus', size: koiniPreviewSize)
Widget activePlanPreview() => KoiniPreviewHost(
  page: (context, store) => ActivePlanView(
    store: store,
    yearlyFeatures: yearlyPlanActions(context, store),
  ),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);
