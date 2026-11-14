import 'package:flutter/material.dart';

import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/services/koini_store.dart';

import 'preview_data.dart';

const koiniPreviewSize = Size(390, 844);

typedef PreviewPageBuilder = Widget Function(
  BuildContext context,
  KoiniStore store,
);

class KoiniPreviewHost extends StatefulWidget {
  const KoiniPreviewHost({
    super.key,
    required this.page,
    this.scenario = PreviewScenario.normal,
    this.returnPage,
  });

  final PreviewPageBuilder page;
  final PreviewScenario scenario;
  final PreviewPageBuilder? returnPage;

  @override
  State<KoiniPreviewHost> createState() => _KoiniPreviewHostState();
}

class _KoiniPreviewHostState extends State<KoiniPreviewHost> {
  late final Future<KoiniStore> _request = _load();
  KoiniStore? _store;

  Future<KoiniStore> _load() async {
    final store = await createPreviewStore(widget.scenario);
    if (mounted) {
      _store = store;
    } else {
      store.dispose();
    }
    return store;
  }

  @override
  void dispose() {
    _store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _request,
    builder: (context, snapshot) {
      final store = snapshot.data;
      if (store == null) {
        return ColoredBox(
          color: KColors.sky,
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Text(
                textDirection: TextDirection.ltr,
                snapshot.hasError
                    ? 'Data preview gagal dimuat.'
                    : 'Memuat Koini…',
              ),
            ),
          ),
        );
      }

      // A Navigator inside the card keeps routes out of the previewer's browser history.
      return Theme(
        data: koiniTheme(fontPackage: 'koini'),
        child: ScaffoldMessenger(
          child: HeroControllerScope.none(
            child: Navigator(
              requestFocus: false,
              reportsRouteUpdateToEngine: false,
              onGenerateInitialRoutes: (_, _) => [
                if (widget.returnPage case final returnPage?)
                  MaterialPageRoute<void>(
                    builder: (context) => ListenableBuilder(
                      listenable: store,
                      builder: (context, _) => returnPage(context, store),
                    ),
                  ),
                MaterialPageRoute<void>(
                  builder: (context) => widget.page(context, store),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
