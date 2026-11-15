import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/missions/viewmodels/koini_story_viewmodel.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class KoiniStoryView extends StatefulWidget {
  const KoiniStoryView({
    super.key,
    required this.store,
    required this.parentAccess,
  });
  final KoiniStore store;
  final VoidCallback parentAccess;

  @override
  State<KoiniStoryView> createState() => _KoiniStoryViewState();
}

class _KoiniStoryViewState extends State<KoiniStoryView> {
  late final model = KoiniStoryViewModel(widget.store);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) {
      final permitted = model.permitted;
      const topics = KoiniStoryViewModel.topics;
      return KPage(
        title: 'Cerita dengan Koini',
        subtitle: 'Pilih topik, belajar bersama',
        footer: KButton(
          permitted ? 'Baca cerita' : 'Ajak Ayah/Bunda',
          onTap: () {
            if (permitted) {
              model.reveal();
            } else if (!model.hasPlus) {
              plusGate(
                context,
                yearly: false,
                parentAccess: widget.parentAccess,
              );
            } else {
              widget.parentAccess();
            }
          },
        ),
        children: [
          KCallout('Koini', model.message),
          const Gap(),
          heading('Topik cerita', size: 19),
          const Gap(7),
          for (var i = 0; i < topics.length; i++) ...[
            KRow(
              topics[i].$1,
              topics[i].$2,
              color: model.current == i ? KColors.gold : null,
              onTap: () => model.select(i),
            ),
            const Gap(7),
          ],
          caption('Cerita dalam mode demo mengikuti topik pilihanmu.'),
        ],
      );
    },
  );
}

@Preview(name: 'Cerita dengan Koini', group: 'Misi', size: koiniPreviewSize)
Widget storyPreview() => KoiniPreviewHost(
  page: (context, store) => KoiniStoryView(
    store: store,
    parentAccess: () => openParentArea(context, store),
  ),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.missions),
);
