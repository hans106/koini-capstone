import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/plus/controllers/smart_plan_controller.dart';
import 'package:koini/features/plus/views/smart_plan_result_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class SmartPlanView extends StatefulWidget {
  const SmartPlanView({super.key, required this.store, this.dream});
  final KoiniStore store;
  final Dream? dream;

  @override
  State<SmartPlanView> createState() => _SmartPlanViewState();
}

class _SmartPlanViewState extends State<SmartPlanView> {
  late final form = SmartPlanController(widget.store, widget.dream);

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> calculate() async {
    FocusScope.of(context).unfocus();
    final plan = form.estimate;
    if (plan == null) {
      note(context, 'Isi target, tabungan saat ini, dan nominal per minggu.');
      return;
    }
    await form.showCalculation();
    if (!mounted) return;
    await openPage<void>(
      context,
      SmartPlanResultView(store: widget.store, dream: widget.dream, plan: plan),
    );
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: form, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) => form.working
      ? KPage(
          back: false,
          children: [
            const Gap(125),
            const Center(child: Mascot(size: 160, glow: true)),
            const Gap(18),
            heading(
              'Koini berpikir…',
              color: KColors.gold,
              size: 32,
              align: TextAlign.center,
            ),
            const Gap(),
            caption('Menghitung rencana menabungmu.', align: TextAlign.center),
          ],
        )
      : KPage(
          title: 'Rencana Pintar',
          footer: KButton('Lihat rencana', onTap: calculate),
          children: [
            heading('Mau menabung berapa?', size: 22, color: KColors.gold),
            const Text(
              'Pilih jumlah per minggu. Koini bantu menghitung waktunya.',
            ),
            const Gap(),
            for (final (amount, message) in [
              (20000, 'Sedikit demi sedikit'),
              (30000, 'Seimbang dan mudah dijaga'),
              (40000, 'Lebih cepat sampai'),
            ]) ...[
              KCard(
                border: int.tryParse(form.weekly.text) == amount
                    ? KColors.gold
                    : null,
                onTap: () => form.chooseWeekly(amount),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading('${rupiah(amount)} per minggu', size: 18),
                    caption(message),
                  ],
                ),
              ),
              const Gap(6),
            ],
            const Gap(6),
            KCard(
              bright: true,
              child: Column(
                children: [
                  if (widget.dream != null)
                    heading(widget.dream!.name, size: 18),
                  KField('Target tabungan', form.target, numeric: true),
                  const Gap(8),
                  KField('Tabungan saat ini', form.saved, numeric: true),
                  const Gap(8),
                  KField(
                    'Nominal per minggu',
                    form.weekly,
                    numeric: true,
                    onChanged: (_) => form.refresh(),
                  ),
                ],
              ),
            ),
            const Gap(),
            const KCallout(
              'Rencana Pintar demo',
              'Koini menghitung perkiraan dari nominal yang kamu masukkan.',
            ),
          ],
        );
}

@Preview(
  name: 'Rencana Pintar - masukan',
  group: 'Plus',
  size: koiniPreviewSize,
)
Widget smartPlanPreview() => KoiniPreviewHost(
  page: (context, store) =>
      SmartPlanView(store: store, dream: store.activeDream),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.dreams),
);
