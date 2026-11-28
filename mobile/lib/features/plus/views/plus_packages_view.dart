import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/plus/viewmodels/plus_packages_viewmodel.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/supabase_koini_repository.dart';
import 'package:url_launcher/url_launcher.dart';

const _features = [
  ('Catat, impian, dan misi', Plan.free),
  ('Tiga toples, cek celengan, lencana', Plan.free),
  ('Ringkasan mingguan', Plan.free),
  ('Tantangan Hadiah', Plan.monthly),
  ('Bonus Tabungan', Plan.monthly),
  ('Catatan terstruktur', Plan.monthly),
  ('Rapor bulanan', Plan.monthly),
];

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<PlusPackagesViewModel, PlusPackagesView>(
      (ref, view) => PlusPackagesViewModel(view.store),
    );

class PlusPackagesView extends ConsumerStatefulWidget {
  const PlusPackagesView({
    super.key,
    required this.store,
    required this.yearlyFeatures,
  });
  final KoiniStore store;
  final Map<String, VoidCallback> yearlyFeatures;

  @override
  ConsumerState<PlusPackagesView> createState() => _PlusPackagesViewState();
}

class _PlusPackagesViewState extends ConsumerState<PlusPackagesView> {
  Future<void> confirmPlan() async {
    if (!model.beginConfirmation()) return;
    final plan = model.selected;
    final canUseMidtrans = widget.store.isRemoteConnected && plan != Plan.free;
    final choice = await showDialog<String>(
      context: context,
      useRootNavigator: false,
      builder: (dialog) => AlertDialog(
        title: heading('Konfirmasi paket'),
        content: Text(
          canUseMidtrans
              ? '${plan.label} · ${plan.price}\n\nBayar menggunakan Midtrans Sandbox (uang uji coba) atau aktifkan simulasi instan.'
              : '${plan.label} · ${plan.price}\n\nAktivasi ini adalah simulasi. Tidak ada pembayaran.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Batal'),
          ),
          if (canUseMidtrans) ...[
            TextButton(
              onPressed: () => Navigator.pop(dialog, 'demo'),
              child: const Text('Simulasi instan'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, 'midtrans'),
              child: const Text('Bayar Midtrans'),
            ),
          ] else
            FilledButton(
              onPressed: () => Navigator.pop(dialog, 'demo'),
              child: const Text('Aktifkan paket demo'),
            ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == null) {
      model.endConfirmation();
      return;
    }
    if (choice == 'midtrans') {
      await _payWithMidtrans(plan);
      if (mounted) model.endConfirmation();
      return;
    }
    await _finishActivation(plan);
    if (mounted) model.endConfirmation();
  }

  Future<void> _finishActivation(Plan plan) async {
    final saved = await model.activate(plan);
    if (!mounted) return;
    if (!saved) {
      note(context, model.error ?? 'Paket belum bisa diaktifkan.');
    } else if (plan != Plan.free) {
      await openPage<void>(context, KRoute.activePlan);
      if (mounted) Navigator.pop(context);
    } else {
      note(context, 'Paket Gratis aktif.');
    }
  }

  Future<void> _payWithMidtrans(Plan plan) async {
    note(context, 'Menyiapkan transaksi Midtrans Sandbox...');
    MidtransCheckoutSession session;
    try {
      session = await widget.store.createMidtransCheckout(plan);
    } on FormatException catch (error) {
      if (mounted) note(context, error.message);
      return;
    } catch (_) {
      if (mounted) {
        note(context, 'Gagal terhubung ke Midtrans Sandbox. Coba lagi.');
      }
      return;
    }
    if (!mounted) return;

    Future<void> openCheckout() async {
      final uri = Uri.parse(session.redirectUrl);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        note(context, 'Browser tidak dapat membuka halaman Midtrans.');
      }
    }

    await openCheckout();
    if (!mounted) return;

    var statusText =
        'Selesaikan pembayaran di Midtrans Sandbox (bisa pakai simulator QRIS/VA/GoPay), lalu tekan "Cek status".';
    var checking = false;

    final paid = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (dialog) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: heading('Pembayaran Midtrans'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${plan.label} · ${rupiah(session.amount)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Gap(4),
              caption('Order ID: ${session.orderId}'),
              const Gap(10),
              Text(statusText),
            ],
          ),
          actions: [
            TextButton(
              onPressed: checking ? null : () => Navigator.pop(dialog, false),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: checking ? null : openCheckout,
              child: const Text('Buka lagi'),
            ),
            FilledButton(
              onPressed: checking
                  ? null
                  : () async {
                      setDialogState(() {
                        checking = true;
                        statusText = 'Memeriksa status ke Midtrans Sandbox...';
                      });
                      try {
                        final result = await widget.store.checkMidtransStatus(
                          session.orderId,
                        );
                        if (!dialog.mounted) return;
                        if (result.paid) {
                          Navigator.pop(dialog, true);
                          return;
                        }
                        setDialogState(() {
                          checking = false;
                          statusText = result.message;
                        });
                      } on FormatException catch (error) {
                        if (!dialog.mounted) return;
                        setDialogState(() {
                          checking = false;
                          statusText = error.message;
                        });
                      } catch (_) {
                        if (!dialog.mounted) return;
                        setDialogState(() {
                          checking = false;
                          statusText = 'Gagal memeriksa status. Pastikan internet aktif.';
                        });
                      }
                    },
              child: Text(checking ? 'Memeriksa...' : 'Cek status'),
            ),
          ],
        ),
      ),
    );
    if (paid == true && mounted) {
      await _finishActivation(plan);
    }
  }

  late final _provider = _viewModelProvider(widget);
  PlusPackagesViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) => KPage(
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
                      Plan.monthly => 'Tantangan, bonus, dan rapor',
                      Plan.yearly => 'Semua fitur · hemat Rp10.000',
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
