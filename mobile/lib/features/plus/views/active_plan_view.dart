import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/plus/viewmodels/plus_packages_viewmodel.dart';
import 'package:koini/features/transactions/views/structured_history_view.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class ActivePlanView extends StatefulWidget {
  const ActivePlanView({
    super.key,
    required this.store,
    required this.yearlyFeatures,
  });
  final KoiniStore store;
  final Map<String, VoidCallback> yearlyFeatures;

  @override
  State<ActivePlanView> createState() => _ActivePlanViewState();
}

class _ActivePlanViewState extends State<ActivePlanView> {
  late final model = ActivePlanViewModel(widget.store);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: model, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) => Celebration(
    title: 'Koini Plus aktif!',
    message:
        'Paket ${model.plan.label} · ${model.plan.price}\nAktivasi simulasi',
    button: 'Kembali ke Ringkasan',
    details: [
      KRow(
        'Rencana Pintar',
        'Perkiraan waktu untuk impian',
        color: KColors.gold,
        icon: const Icon(Icons.star, color: KColors.gold),
        onTap: () => openSmartPlan(context, widget.store, model.activeDream),
      ),
      const Gap(8),
      KRow(
        'Catatan terstruktur',
        'Rincian transaksi per kategori',
        color: KColors.gold,
        icon: const Icon(Icons.star, color: KColors.gold),
        onTap: () => openPage(
          context,
          StructuredHistoryView(store: widget.store, readOnly: true),
        ),
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
