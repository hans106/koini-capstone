import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/jars/widgets/jar_split_editor.dart';
import 'package:koini/features/parents/controllers/allowance_settings_controller.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class AllowanceSettingsView extends StatefulWidget {
  const AllowanceSettingsView({super.key, required this.store});
  final KoiniStore store;

  @override
  State<AllowanceSettingsView> createState() => _AllowanceSettingsViewState();
}

class _AllowanceSettingsViewState extends State<AllowanceSettingsView> {
  late final form = AllowanceSettingsController(widget.store);

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: form, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) => KPage(
    title: 'Atur uang saku',
    footer: KButton(
      'Simpan rencana',
      onTap: form.busy
          ? null
          : () async {
              final error = await form.save();
              if (!context.mounted) return;
              if (error == null) {
                Navigator.pop(context);
                note(context, 'Rencana uang saku tersimpan.');
              } else {
                note(context, error);
              }
            },
    ),
    children: [
      KField(
        'Nominal per minggu',
        form.amount,
        numeric: true,
        onChanged: form.changeAmount,
      ),
      const Gap(8),
      KField('Batas jajan harian', form.limit, numeric: true),
      const Gap(10),
      JarSplitEditor(
        key: ValueKey(form.total),
        amount: form.total,
        initial: form.split,
        onChanged: form.changeSplit,
      ),
      const Gap(8),
      caption('Rencana berlaku pada penerimaan uang saku berikutnya.'),
    ],
  );
}

@Preview(name: 'Atur uang saku', group: 'Orang tua', size: koiniPreviewSize)
Widget allowanceSettingsPreview() => KoiniPreviewHost(
  page: (context, store) => AllowanceSettingsView(store: store),
  returnPage: (context, store) => ParentDashboardView(store: store),
);
