import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/presentation/providers/user_prefs_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const _languages = [
    ('en', 'English', '🇬🇧'),
    ('kn', 'ಕನ್ನಡ', '🇮🇳'),
    ('hi', 'हिन्दी', '🇮🇳'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPrefsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Language', style: AppTextStyles.title2),
        ),
        ..._languages.map(
          (lang) => RadioListTile<String>(
            title: Row(
              children: [
                Text(lang.$3, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(lang.$2, style: AppTextStyles.bodyMedium),
              ],
            ),
            value: lang.$1,
            groupValue: prefs.preferredLanguage,
            activeColor: AppColors.primary,
            onChanged: (val) {
              if (val != null) {
                ref.read(userPrefsProvider.notifier).setLanguage(val);
              }
            },
          ),
        ),
      ],
    );
  }
}
