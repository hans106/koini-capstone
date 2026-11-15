import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/views/parent_pin_view.dart';
import 'package:koini/features/plus/viewmodels/plus_packages_viewmodel.dart';
import 'package:koini/features/plus/views/active_plan_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

const _features = [
  ('Catat, impian, dan misi', Plan.free),
  ('Tiga toples dan lencana', Plan.free),
  ('Ringkasan mingguan', Plan.free),
  ('Rencana Pintar', Plan.monthly),
  ('Catatan terstruktur', Plan.monthly),
  ('Rapor bulanan', Plan.yearly),
  ('Peringatan email', Plan.yearly),
  ('Target bertanggal', Plan.yearly),
  ('Musim uang hadiah', Plan.yearly),
];

class PlusPackagesView extends StatefulWidget {
  const PlusPackagesView({
    super.key,
    required this.store,
    required this.yearlyFeatures,
  });
  final KoiniStore store;
  final Map<String, VoidCallback> yearlyFeatures;

  @override
  State<PlusPackagesView> createState() => _PlusPackagesViewState();
}

class _PlusPackagesViewState extends State<PlusPackagesView> {
  Future<void> confirmPlan() async {
    if (!model.beginConfirmation()) return;
    final plan = model.selected;
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (dialog) => AlertDialog(
        title: heading('Konfirmasi paket'),
        content: Text(
          '${plan.label} · ${plan.price}\n\nAktivasi ini adalah simulasi. Tidak ada pembayaran.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Lanjut dengan PIN'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      model.endConfirmation();
      return;
    }
    final result = await openPage<bool>(
      context,
      ParentPinView(
        title: 'PIN Ayah/Bunda',
        prompt: 'Masukkan PIN 6 angka untuk memilih paket ${plan.label}.',
        buttonLabel: 'Aktifkan paket demo',
        verify: (pin) => model.verify(plan, pin),
      ),
    );
    if (!mounted) return;
    model.endConfirmation();
    if (result == true && plan != Plan.free) {
      await openPage<void>(
        context,
        ActivePlanView(
          store: widget.store,
          yearlyFeatures: widget.yearlyFeatures,
        ),
      );
      if (mounted) Navigator.pop(context);
    } else if (result == true) {
      note(context, 'Paket Gratis aktif.');
    }
  }

  late final model = PlusPackagesViewModel(widget.store);

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: model, builder: buildPage);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Widget buildPage(BuildContext context, Widget? child) => KPage(
    title: 'Koini Plus',
    trailing: Pill(model.current.label, icon: Icons.star, color: KColors.gold),
    footer: KButton(
      model.selected == model.current
          ? 'Paket sedang aktif'
          : 'Mulai paket ${model.selected.label}',
      onTap: model.canConfirm ? confirmPlan : null,
    ),
    children: [
      const KCallout(
        'Pilihan Ayah/Bunda',
        'Belajar lebih jauh bersama Koini Plus. Aktivasi paket menggunakan PIN.',
      ),
      const Gap(),
      heading('Pilih paket', size: 18),
      const Gap(6),
      for (final plan in Plan.values) ...[
        KCard(
          border: plan == model.selected ? KColors.gold : null,
          onTap: () => model.select(plan),
          child: Row(
            children: [
              Icon(
                plan == model.selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: plan == model.selected ? KColors.gold : KColors.soft,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading(plan.label, size: 18),
                    caption(switch (plan) {
                      Plan.free => 'Fitur dasar selamanya',
                      Plan.monthly => 'Catatan dan rencana',
                      Plan.yearly => 'Pendampingan lengkap',
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: heading(
                  plan.price,
                  size: 16,
                  align: TextAlign.end,
                  color: plan == Plan.free ? KColors.mint : KColors.gold,
                ),
              ),
            ],
          ),
        ),
        const Gap(7),
      ],
      KCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: heading('Manfaat Koini Plus', size: 16)),
                for (final label in ['Gratis', 'Bulan', 'Tahun'])
                  SizedBox(
                    width: 42,
                    child: caption(label, align: TextAlign.center),
                  ),
              ],
            ),
            const Gap(7),
            for (final (label, required) in _features)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: caption(label)),
                    for (final plan in Plan.values)
                      SizedBox(
                        width: 42,
                        child: Icon(
                          plan.index >= required.index
                              ? Icons.check
                              : Icons.remove,
                          size: 16,
                          color: plan.index >= required.index
                              ? KColors.mint
                              : KColors.soft,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      const Gap(9),
      caption(
        'Fitur dasar tetap gratis. Aktivasi paket dalam mode demo.',
        color: KColors.mint,
        align: TextAlign.center,
      ),
    ],
  );
}

@Preview(
  name: 'Pilih paket - PIN 123456',
  group: 'Plus',
  size: koiniPreviewSize,
)
Widget plusPackagesPreview() => KoiniPreviewHost(
  page: (context, store) => PlusPackagesView(
    store: store,
    yearlyFeatures: yearlyPlanActions(context, store),
  ),
  scenario: PreviewScenario.dream,
  returnPage: (context, store) => ParentDashboardView(store: store),
);
