import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/viewmodels/rating_viewmodel.dart';
import 'package:koini/services/koini_store.dart';

Future<void> rate(BuildContext context, KoiniStore store) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => _RatingSheet(store: store),
    );

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<RatingViewModel, _RatingSheet>(
      (ref, view) => RatingViewModel(view.store),
    );

class _RatingSheet extends ConsumerStatefulWidget {
  const _RatingSheet({required this.store});
  final KoiniStore store;

  @override
  ConsumerState<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends ConsumerState<_RatingSheet> {
  late final _provider = _viewModelProvider(widget);
  RatingViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        16 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: KCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            heading('Beri nilai Koini', color: KColors.gold),
            caption('Bantu kami menjadi lebih baik.'),
            const Gap(12),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  Expanded(
                    child: IconButton(
                      tooltip: 'Beri nilai $i',
                      onPressed: model.busy ? null : () => model.select(i),
                      icon: Icon(
                        Icons.star_rounded,
                        color: i <= model.rating ? KColors.gold : KColors.line,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(12),
            KButton(
              'Kirim nilai',
              onTap: model.rating == 0 || model.busy
                  ? null
                  : () async {
                      if (model.busy) return;
                      final saved = await model.save();
                      if (!context.mounted) return;
                      if (saved) {
                        Navigator.pop(context);
                      } else {
                        note(context, model.error!);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
