import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/domain/entities/saved_place.dart';
import 'package:archive/presentation/providers/places_provider.dart';
import 'package:archive/presentation/providers/saved_provider.dart';

class SavedPlaceTile extends ConsumerWidget {
  final SavedPlace savedPlace;

  const SavedPlaceTile({super.key, required this.savedPlace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeDetailProvider(savedPlace.placeId));

    return Dismissible(
      key: Key(savedPlace.placeId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        await ref.read(savedRepositoryProvider).removePlace(savedPlace.placeId);
        ref.invalidate(savedPlacesProvider);
        return true;
      },
      child: placeAsync.when(
        data: (place) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.place, color: AppColors.primary),
            ),
            title: Text(place.name, style: AppTextStyles.title2),
            subtitle: Text(
              place.shortDescription.isEmpty
                  ? place.categoryId
                  : place.shortDescription,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/place/${place.id}'),
          ),
        ),
        loading: () => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            title: Text(savedPlace.placeId, style: AppTextStyles.title2),
          ),
        ),
        error: (_, __) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.place, color: AppColors.primary),
            title: Text(savedPlace.placeId, style: AppTextStyles.title2),
            subtitle: const Text('Tap to view'),
            onTap: () => context.push('/place/${savedPlace.placeId}'),
          ),
        ),
      ),
    );
  }
}
