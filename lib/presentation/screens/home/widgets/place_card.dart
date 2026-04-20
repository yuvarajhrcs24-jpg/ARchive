import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/core/utils/distance_utils.dart';
import 'package:archive/domain/entities/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final bool horizontal;

  const PlaceCard({super.key, required this.place, this.horizontal = true});

  @override
  Widget build(BuildContext context) {
    if (horizontal) return _buildHorizontalCard(context);
    return _buildVerticalCard(context);
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/place/${place.id}'),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _buildImage(double.infinity, 110),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption,
                      ),
                      const Spacer(),
                      Text(
                        DistanceUtils.formatDistance(place.distanceMeters),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/place/${place.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: _buildImage(90, 90),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: AppTextStyles.title2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.shortDescription.isEmpty
                          ? place.description
                          : place.shortDescription,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          place.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, size: 12, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          DistanceUtils.formatDistance(place.distanceMeters),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double width, double height) {
    if (place.imageUrls.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: AppColors.shimmerBase,
        child: const Icon(Icons.image_not_supported, color: Colors.white38),
      );
    }
    return CachedNetworkImage(
      imageUrl: place.imageUrls.first,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: AppColors.shimmerBase,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.shimmerBase,
        child: const Icon(Icons.image_not_supported, color: Colors.white38),
      ),
    );
  }
}
