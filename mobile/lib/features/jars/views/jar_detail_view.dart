import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class JarDetailView extends StatelessWidget {
  const JarDetailView({super.key, required this.store, required this.jar});
  final KoiniStore store;
  final Jar jar;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final kind = switch (jar) {
        Jar.tabung => EntryKind.save,
        Jar.jajan => EntryKind.spend,
        Jar.berbagi => EntryKind.give,
      };
      final changes = store.entries
          .where(
            (entry) =>
                entry.changes.containsKey(jar) ||
                (jar == Jar.tabung && entry.dreamId != null),
          )
          .toList();
      return KPage(
        title: 'Toples ${jar.label}',
        footer: KButton(
          'Catat ${kind.label.toLowerCase()}',
          onTap: () =>
              openPage(context, AddTransactionView(store: store, kind: kind)),
        ),
        children: [
          KCard(
            bright: true,
            border: KColors.jar(jar),
            child: Column(
              children: [
                Illustration(jarArt(jar), size: 78),
                heading(
                  rupiah(store.balance(jar)),
                  size: 34,
                  color: KColors.jar(jar),
                ),
                caption(jar.description),
                if (jar == Jar.tabung)
                  caption(
                    'Belum dialokasikan ${rupiah(store.availableSavings)}',
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
                store: store,
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
                store: store,
                kind: EntryKind.transfer,
                source: jar,
                destination: jar == Jar.jajan ? Jar.tabung : Jar.jajan,
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
