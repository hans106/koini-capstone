import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/missions/mission_content.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/views/parent_report_view.dart';
import 'package:koini/features/parents/widgets/dream_report.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class EmailPreviewView extends StatefulWidget {
  const EmailPreviewView({super.key, required this.store, this.alert = false});
  final KoiniStore store;
  final bool alert;

  @override
  State<EmailPreviewView> createState() => _EmailPreviewViewState();
}

class _EmailPreviewViewState extends State<EmailPreviewView> {
  bool busy = false;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final dream = store.activeDream;
      final weeklySavings = store.netSavings(store.thisWeek);
      return KPage(
        title: widget.alert ? 'Peringatan email' : 'Kabar ${store.name}',
        subtitle: 'Pratinjau email demo',
        footer: KButton(
          'Lihat ringkasan',
          onTap: () => openPage(context, ParentReportView(store: store)),
        ),
        children: [
          caption(
            'Dari Koini · Kepada ${store.email.isEmpty ? 'Ayah/Bunda' : store.email}',
          ),
          const Gap(4),
          caption(dateLabel(store.now)),
          const Gap(),
          Center(
            child: Image.asset(
              'assets/images/wordmark.png',
              width: 72,
              semanticLabel: 'Koini',
            ),
          ),
          const Gap(10),
          heading('Halo, Ayah/Bunda', size: 19),
          Text(
            widget.alert
                ? 'Ini contoh kabar saat catatan tabungan ${store.name} berkurang.'
                : 'Ini cerita belajar ${store.name} minggu ini. Ada langkah kecil yang patut dirayakan.',
          ),
          const Gap(),
          KCard(
            bright: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                caption(
                  widget.alert
                      ? 'Saldo toples Tabung'
                      : 'Catatan tabungan minggu ini',
                ),
                heading(
                  rupiah(
                    widget.alert ? store.balance(Jar.tabung) : weeklySavings,
                  ),
                  color: KColors.mint,
                  size: 29,
                ),
              ],
            ),
          ),
          const Gap(8),
          if (dream != null) ...[
            DreamReport(store: store, dream: dream),
            const Gap(8),
          ],
          Stat(
            'Misi selesai (total)',
            '${store.scores.length}/${missions.length}',
            color: Colors.white,
          ),
          const Gap(),
          const Text(
            'Ajak anak bercerita: apa yang paling menyenangkan saat menabung minggu ini?',
          ),
          const Gap(9),
          caption(
            'Email ini berupa pratinjau. Pengiriman email belum tersedia.',
          ),
          if (widget.alert) ...[
            const Gap(9),
            KCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                value: store.alerts,
                onChanged: busy
                    ? null
                    : (value) async {
                        setState(() => busy = true);
                        final error = await store.settings(alerts: value);
                        if (!mounted || !context.mounted) return;
                        setState(() => busy = false);
                        if (error != null) note(context, error);
                      },
                title: const Text('Peringatan tabungan'),
                subtitle: caption('Preferensi lokal'),
              ),
            ),
          ],
        ],
      );
    },
  );
}

@Preview(
  name: 'Contoh email mingguan',
  group: 'Orang tua',
  size: koiniPreviewSize,
)
Widget weeklyEmailPreview() => KoiniPreviewHost(
  page: (context, store) => EmailPreviewView(store: store),
  scenario: PreviewScenario.dream,
  returnPage: (context, store) => ParentDashboardView(store: store),
);

@Preview(name: 'Peringatan email', group: 'Plus', size: koiniPreviewSize)
Widget alertEmailPreview() => KoiniPreviewHost(
  page: (context, store) => EmailPreviewView(store: store, alert: true),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);
