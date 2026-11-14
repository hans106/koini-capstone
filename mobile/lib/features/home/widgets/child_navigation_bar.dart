import 'package:flutter/material.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';

class ChildNavigationBar extends StatelessWidget {
  const ChildNavigationBar({
    super.key,
    required this.index,
    required this.onSelect,
  });
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const labels = ['Beranda', 'Impian', 'Catat', 'Misi', 'Profil'];
    const assets = ['home', 'dream', 'record', 'mission', 'profile'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 5),
      child: KCard(
        padding: const EdgeInsets.all(4),
        radius: 26,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Semantics(
                  selected: i == index,
                  button: true,
                  child: Material(
                    color: i == index ? KColors.gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(21),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onSelect(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 9,
                          horizontal: 2,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/${assets[i]}.png',
                              width: 22,
                              height: 22,
                              color: i == index ? KColors.ink : KColors.text,
                            ),
                            const Gap(3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: i == index
                                      ? KColors.ink
                                      : KColors.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
