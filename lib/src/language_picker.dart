import 'package:flutter/material.dart';

import 'app_language.dart';
import 'theme.dart';

class AppLanguagePicker extends StatelessWidget {
  const AppLanguagePicker({
    required this.value,
    required this.onChanged,
    this.compact = false,
    super.key,
  });

  final AppLanguage value;
  final ValueChanged<AppLanguage> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: AppLanguage.launchValues
        .map(
          (language) => ChoiceChip(
            key: ValueKey(language),
            selected: language == value,
            onSelected: (_) => onChanged(language),
            selectedColor: MysticColors.violet,
            side: BorderSide(
              color: language == value
                  ? MysticColors.gold.withValues(alpha: .7)
                  : Colors.white.withValues(alpha: .12),
            ),
            avatar: Text(
              language.code,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: compact ? 8 : 9,
                fontWeight: FontWeight.w900,
                color: language == value
                    ? MysticColors.gold
                    : MysticColors.muted,
              ),
            ),
            label: Text(
              language.label,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )
        .toList(growable: false),
  );
}
