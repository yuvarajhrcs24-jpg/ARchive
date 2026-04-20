import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/domain/entities/category.dart';
import 'package:archive/presentation/providers/places_provider.dart';

class MapFilterSheet extends ConsumerWidget {
  const MapFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Filter by Category', style: AppTextStyles.title1),
          const SizedBox(height: 16),
          categoriesAsync.when(
            data: (categories) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: selected == null,
                  onSelected: (_) {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                    Navigator.pop(context);
                  },
                  selectedColor: AppColors.primary,
                ),
                ...categories.map(
                  (cat) => FilterChip(
                    label: Text(cat.name),
                    selected: selected == cat.id,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          selected == cat.id ? null : cat.id;
                      Navigator.pop(context);
                    },
                    selectedColor: _colorForCategory(cat),
                    showCheckmark: false,
                  ),
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Failed to load categories'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Color _colorForCategory(Category cat) {
    switch (cat.color) {
      case 'amber':
        return AppColors.historical;
      case 'green':
        return AppColors.nature;
      case 'deepOrange':
        return AppColors.temples;
      case 'red':
        return AppColors.food;
      case 'purple':
        return AppColors.shopping;
      case 'teal':
        return AppColors.adventure;
      default:
        return AppColors.primary;
    }
  }
}
