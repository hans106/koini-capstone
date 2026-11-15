import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/viewmodels/change_pin_viewmodel.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ChangePinViewModel, ChangePinView>(
      (ref, view) => ChangePinViewModel(view.store),
    );

class ChangePinView extends ConsumerStatefulWidget {
  const ChangePinView({super.key, required this.store});
  final KoiniStore store;

  @override
  ConsumerState<ChangePinView> createState() => _ChangePinViewState();
}

class _ChangePinViewState extends ConsumerState<ChangePinView> {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();

  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  late final _provider = _viewModelProvider(widget);
  ChangePinViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) => KPage(
    title: 'Ganti PIN',
    footer: KButton(
      'Simpan PIN',
      onTap: model.busy
          ? null
          : () async {
              if (model.busy) return;
              final saved = await model.save(
                current.text,
                next.text,
                confirm.text,
              );
              if (!context.mounted) return;
              if (!saved) {
                note(context, model.error!);
              } else {
                Navigator.pop(context);
                note(context, 'PIN baru tersimpan.');
              }
            },
    ),
    children: [
      KField('PIN lama', current, numeric: true, secret: true, length: 6),
      const Gap(10),
      KField('PIN baru', next, numeric: true, secret: true, length: 6),
      const Gap(10),
      KField(
        'Ulangi PIN baru',
        confirm,
        numeric: true,
        secret: true,
        length: 6,
      ),
    ],
  );
}

@Preview(
  name: 'Ganti PIN demo 123456',
  group: 'Orang tua',
  size: koiniPreviewSize,
)
Widget changePinPreview() => KoiniPreviewHost(
  page: (context, store) => ChangePinView(store: store),
  returnPage: (context, store) => ParentDashboardView(store: store),
);
