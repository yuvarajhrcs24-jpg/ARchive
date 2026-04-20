import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/core/utils/distance_utils.dart';
import 'package:archive/domain/entities/place.dart';

class PlacePreviewCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onNavigate;

  const PlacePreviewCard({
    super.key,
    required this.place,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: place.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: place.imageUrls.first,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.shimmerBase,
                      child: const Icon(Icons.image_not_supported, color: Colors.white38),
                    ),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: AppColors.shimmerBase,
                    child: const Icon(Icons.place, color: AppColors.primary),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  place.name,
                  style: AppTextStyles.title2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text(place.rating.toStringAsFixed(1), style: AppTextStyles.caption),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on, size: 12, color: AppColors.primary),
                    const SizedBox(width: 2),
                    Text(
                      DistanceUtils.formatDistance(place.distanceMeters),
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  place.shortDescription.isEmpty
                      ? place.description
                      : place.shortDescription,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => context.push('/place/${place.id}'),
                icon: const Icon(Icons.info_outline, color: AppColors.primary),
                tooltip: 'Details',
              ),
              IconButton(
                onPressed: onNavigate,
                icon: const Icon(Icons.navigation, color: AppColors.primary),
                tooltip: 'Navigate',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
