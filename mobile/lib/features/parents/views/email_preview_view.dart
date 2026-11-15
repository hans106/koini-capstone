import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/viewmodels/parent_overview_viewmodel.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/widgets/dream_report.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ParentOverviewViewModel, EmailPreviewView>(
      (ref, view) => ParentOverviewViewModel(view.store, alert: view.alert),
    );

class EmailPreviewView extends ConsumerStatefulWidget {
  const EmailPreviewView({super.key, required this.store, this.alert = false});
  final KoiniStore store;
  final bool alert;

  @override
  ConsumerState<EmailPreviewView> createState() => _EmailPreviewViewState();
}

class _EmailPreviewViewState extends ConsumerState<EmailPreviewView> {
  late final _provider = _viewModelProvider(widget);
  ParentOverviewViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    final dream = model.dream;
    return KPage(
      title: widget.alert ? 'Peringatan email' : 'Kabar ${model.child}',
      subtitle: 'Pratinjau email demo',
      footer: KButton(
        'Lihat ringkasan',
        onTap: () => openPage(context, KRoute.parentReport),
      ),
      children: [
        caption('Dari Koini · Kepada ${model.recipient}'),
        const Gap(4),
        caption(dateLabel(model.today)),
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
              ? 'Ini contoh kabar saat catatan tabungan ${model.child} berkurang.'
              : 'Ini cerita belajar ${model.child} minggu ini. Ada langkah kecil yang patut dirayakan.',
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
              heading(rupiah(model.emailAmount), color: KColors.mint, size: 29),
            ],
          ),
        ),
        const Gap(8),
        if (dream != null) ...[
          DreamReport(
            dream: dream,
            saved: model.savedFor(dream),
            progress: model.progress(dream),
          ),
          const Gap(8),
        ],
        Stat(
          'Misi selesai (total)',
          model.missionFraction,
          color: Colors.white,
        ),
        const Gap(),
        const Text(
          'Ajak anak bercerita: apa yang paling menyenangkan saat menabung minggu ini?',
        ),
        const Gap(9),
        caption('Email ini berupa pratinjau. Pengiriman email belum tersedia.'),
        if (widget.alert) ...[
          const Gap(9),
          KCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              value: model.alerts,
              onChanged: model.busy
                  ? null
                  : (value) async {
                      if (model.busy) return;
                      final saved = await model.setAlerts(value);
                      if (!mounted || !context.mounted || saved) return;
                      note(context, model.error!);
                    },
              title: const Text('Peringatan tabungan'),
              subtitle: caption('Preferensi lokal'),
            ),
          ),
        ],
      ],
    );
  }
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
