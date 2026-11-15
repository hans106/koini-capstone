import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/jars/viewmodels/jar_detail_viewmodel.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class JarDetailView extends StatefulWidget {
  const JarDetailView({super.key, required this.store, required this.jar});
  final KoiniStore store;
  final Jar jar;

  @override
  State<JarDetailView> createState() => _JarDetailViewState();
}

class _JarDetailViewState extends State<JarDetailView> {
  late final model = JarDetailViewModel(widget.store, widget.jar);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) {
      final jar = model.jar;
      final kind = model.kind;
      final changes = model.entries;
      return KPage(
        title: 'Toples ${jar.label}',
        footer: KButton(
          'Catat ${kind.label.toLowerCase()}',
          onTap: () => openPage(
            context,
            AddTransactionView(store: widget.store, kind: kind),
          ),
        ),
        children: [
          KCard(
            bright: true,
            border: KColors.jar(jar),
            child: Column(
              children: [
                Illustration(jarArt(jar), size: 78),
                heading(
                  rupiah(model.balance),
                  size: 34,
                  color: KColors.jar(jar),
                ),
                caption(jar.description),
                if (jar == Jar.tabung)
                  caption(
                    'Belum dialokasikan ${rupiah(model.availableSavings)}',
                  ),
              ],
            ),
          ),
          const Gap(),
          KRow(
            'Tambah uang masuk',
            'Catat tunai baru ke toples ini.',
            onTap: () => openPage(
              context,
              AddTransactionView(
                store: widget.store,
                kind: EntryKind.income,
                destination: jar,
              ),
            ),
          ),
          const Gap(8),
          KRow(
            'Pindah antartoples',
            'Pilih sumber dan tujuan.',
            onTap: () => openPage(
              context,
              AddTransactionView(
                store: widget.store,
                kind: EntryKind.transfer,
                source: jar,
                destination: model.transferDestination,
              ),
            ),
          ),
          const Gap(),
          heading('Riwayat toples', size: 19),
          const Gap(7),
          if (changes.isEmpty)
            const KCallout(
              'Belum ada catatan',
              'Aktivitas toples akan muncul di sini.',
            ),
          for (final entry in changes) ...[
            KRow(
              entry.kind.label,
              entry.note,
              trailing: heading(
                rupiah(entry.changes[jar] ?? 0),
                size: 15,
                color: KColors.jar(jar),
              ),
            ),
            const Gap(7),
          ],
        ],
      );
    },
  );
}

@Preview(name: 'Toples Tabung', group: 'Toples', size: koiniPreviewSize)
Widget tabungJarPreview() => KoiniPreviewHost(
  page: (context, store) => JarDetailView(store: store, jar: Jar.tabung),
  returnPage: (context, store) => ChildShell(store: store),
);

@Preview(name: 'Toples Jajan', group: 'Toples', size: koiniPreviewSize)
Widget jajanJarPreview() => KoiniPreviewHost(
  page: (context, store) => JarDetailView(store: store, jar: Jar.jajan),
  returnPage: (context, store) => ChildShell(store: store),
);

@Preview(name: 'Toples Berbagi', group: 'Toples', size: koiniPreviewSize)
Widget berbagiJarPreview() => KoiniPreviewHost(
  page: (context, store) => JarDetailView(store: store, jar: Jar.berbagi),
  returnPage: (context, store) => ChildShell(store: store),
);
