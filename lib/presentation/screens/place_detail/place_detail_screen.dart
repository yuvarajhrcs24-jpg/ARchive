import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/core/utils/distance_utils.dart';
import 'package:archive/domain/entities/place.dart';
import 'package:archive/presentation/providers/places_provider.dart';
import 'package:archive/presentation/providers/saved_provider.dart';
import 'package:archive/presentation/screens/place_detail/widgets/audio_player_widget.dart';
import 'package:archive/presentation/screens/place_detail/widgets/image_carousel.dart';
import 'package:archive/presentation/screens/place_detail/widgets/info_row.dart';
import 'package:archive/presentation/widgets/error_widget.dart';
import 'package:archive/presentation/widgets/loading_shimmer.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeDetailProvider(placeId));

    return placeAsync.when(
      data: (place) => _PlaceDetailContent(place: place),
      loading: () => const _PlaceDetailLoading(),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(placeDetailProvider(placeId)),
        ),
      ),
    );
  }
}

class _PlaceDetailContent extends ConsumerStatefulWidget {
  final Place place;

  const _PlaceDetailContent({required this.place});

  @override
  ConsumerState<_PlaceDetailContent> createState() => _PlaceDetailContentState();
}

class _PlaceDetailContentState extends ConsumerState<_PlaceDetailContent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final isSavedAsync = ref.watch(isPlaceSavedProvider(place.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ImageCarousel(imageUrls: place.imageUrls),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              isSavedAsync.when(
                data: (saved) => Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_outline,
                      color: saved ? AppColors.primary : Colors.white,
                    ),
                    onPressed: () => _toggleBookmark(saved),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(place.name, style: AppTextStyles.headline2),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _RatingStars(rating: place.rating),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (place.categoryId.isNotEmpty)
                    Chip(
                      label: Text(
                        place.categoryId[0].toUpperCase() +
                            place.categoryId.substring(1),
                        style: AppTextStyles.caption,
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      side: const BorderSide(color: AppColors.primary),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  if (place.openingHours.isNotEmpty)
                    InfoRow(
                      icon: Icons.access_time,
                      label: 'Hours',
                      value: place.openingHours,
                      iconColor: AppColors.success,
                    ),
                  InfoRow(
                    icon: Icons.location_on,
                    label: 'Distance',
                    value: DistanceUtils.formatDistance(place.distanceMeters),
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('About', style: AppTextStyles.title1),
                  const SizedBox(height: 8),
                  AnimatedCrossFade(
                    firstChild: Text(
                      place.shortDescription.isNotEmpty
                          ? place.shortDescription
                          : place.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      place.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  if (place.description.length > 150)
                    TextButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      child: Text(
                        _expanded ? 'Read less' : 'Read more',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (place.audioUrl.isNotEmpty) ...[
                    AudioPlayerWidget(
                      audioUrl: place.audioUrl,
                      trackTitle: '${place.name} Audio Guide',
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => _launchNavigation(place),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.navigation),
            label: const Text('Navigate Here'),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleBookmark(bool isSaved) async {
    final repo = ref.read(savedRepositoryProvider);
    if (isSaved) {
      await repo.removePlace(widget.place.id);
    } else {
      await repo.savePlace(widget.place.id);
    }
    ref.invalidate(isPlaceSavedProvider(widget.place.id));
    ref.invalidate(savedPlacesProvider);
  }

  Future<void> _launchNavigation(Place place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;

  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: AppColors.warning, size: 14);
        } else if (i < rating.ceil() && rating % 1 > 0) {
          return const Icon(Icons.star_half, color: AppColors.warning, size: 14);
        }
        return const Icon(Icons.star_outline, color: AppColors.warning, size: 14);
      }),
    );
  }
}

class _PlaceDetailLoading extends StatelessWidget {
  const _PlaceDetailLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const LoadingShimmer(height: 280),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LoadingShimmer(height: 28, width: 200),
                const SizedBox(height: 12),
                const LoadingShimmer(height: 14),
                const SizedBox(height: 8),
                const LoadingShimmer(height: 14, width: 250),
                const SizedBox(height: 8),
                const LoadingShimmer(height: 14, width: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
