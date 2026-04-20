import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/domain/entities/category.dart';
import 'package:archive/presentation/providers/places_provider.dart';

class CategoryChipList extends ConsumerWidget {
  const CategoryChipList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 44,
      child: categoriesAsync.when(
        data: (categories) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildChip(
              context,
              ref,
              label: 'All',
              id: null,
              isSelected: selected == null,
              color: AppColors.primary,
            ),
            ...categories.map(
              (cat) => _buildChip(
                context,
                ref,
                label: cat.name,
                id: cat.id,
                isSelected: selected == cat.id,
                color: _colorForCategory(cat),
              ),
            ),
          ],
        ),
        loading: () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: List.generate(
            5,
            (_) => Container(
              width: 80,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String? id,
    required bool isSelected,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) {
          ref.read(selectedCategoryProvider.notifier).state = id;
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: color,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? color : Colors.grey.shade700,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4),
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
