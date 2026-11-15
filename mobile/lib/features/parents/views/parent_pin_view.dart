import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/viewmodels/parent_pin_viewmodel.dart';
import 'package:koini/previews/preview_host.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ParentPinViewModel, ParentPinView>(
      (ref, view) => ParentPinViewModel(view.verify),
    );

class ParentPinView extends ConsumerStatefulWidget {
  const ParentPinView({
    super.key,
    required this.title,
    required this.prompt,
    required this.verify,
    this.recovery = false,
    this.onVerified,
    this.buttonLabel = 'Buka ringkasan',
  });

  final String title;
  final String prompt;
  final Future<String?> Function(String) verify;
  final bool recovery;
  final String buttonLabel;
  final VoidCallback? onVerified;

  @override
  ConsumerState<ParentPinView> createState() => _ParentPinViewState();
}

class _ParentPinViewState extends ConsumerState<ParentPinView> {
  Future<void> submit() async {
    if (!await model.verify() || !mounted) return;
    if (widget.onVerified case final onVerified?) {
      onVerified();
    } else {
      Navigator.pop(context, true);
    }
  }

  late final _provider = _viewModelProvider(widget);
  ParentPinViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) => KPage(
    title: widget.title,
    footer: KButton(widget.buttonLabel, onTap: model.busy ? null : submit),
    children: [
      KCard(
        bright: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('Khusus Ayah/Bunda', size: 18, color: KColors.gold),
            Text(widget.prompt),
          ],
        ),
      ),
      const Gap(17),
      PinDots(count: model.length),
      const Gap(9),
      caption(
        model.error ?? 'PIN tersimpan di HP ini.',
        color: model.error == null ? KColors.text : KColors.error,
        align: TextAlign.center,
      ),
      const Gap(),
      Keypad(pin: true, onDigit: model.enterDigit),
      if (widget.recovery)
        Center(
          child: TextButton(
            onPressed: () => kSheet(
              context,
              'Lupa PIN?',
              'Pemulihan melalui email belum tersedia dalam mode demo.',
            ),
            child: const Text('Lupa PIN?'),
          ),
        ),
    ],
  );
}

@Preview(
  name: 'Masuk dengan PIN demo 123456',
  group: 'Orang tua',
  size: koiniPreviewSize,
)
Widget parentPinPreview() => KoiniPreviewHost(
  page: (context, store) => ParentPinView(
    title: 'PIN orang tua',
    prompt: 'Masukkan PIN 6 digit untuk membuka pengawasan di HP ini.',
    verify: (pin) async => store.checkPin(pin),
    recovery: true,
    onVerified: () => openPage(context, KRoute.parentDashboard),
  ),
  returnPage: (_, store) =>
      ChildShell(store: store, initialTab: ChildTab.profile),
);
