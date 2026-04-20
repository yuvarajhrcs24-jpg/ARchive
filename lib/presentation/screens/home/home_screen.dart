import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/presentation/providers/places_provider.dart';
import 'package:archive/presentation/screens/home/widgets/category_chip_list.dart';
import 'package:archive/presentation/screens/home/widgets/place_card.dart';
import 'package:archive/presentation/screens/home/widgets/search_bar_widget.dart';
import 'package:archive/presentation/widgets/error_widget.dart';
import 'package:archive/presentation/widgets/loading_shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyPlacesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nearbyPlacesProvider);
          ref.invalidate(categoriesProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.explore, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ARchive',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const SearchBarWidget(readOnly: false),
                  const SizedBox(height: 16),
                  const CategoryChipList(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Places',
                          style: AppTextStyles.headline3,
                        ),
                        TextButton(
                          onPressed: () => context.go('/map'),
                          child: const Text(
                            'See all',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNearbySection(context, ref, nearbyAsync),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Popular Places',
                      style: AppTextStyles.headline3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPopularSection(context, ref, nearbyAsync),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/map'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.map, color: Colors.white),
        label: const Text('Map', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildNearbySection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue places,
  ) {
    return SizedBox(
      height: 210,
      child: places.when(
        data: (data) {
          final list = data as List;
          if (list.isEmpty) {
            return const Center(child: Text('No places nearby'));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: list.length.clamp(0, 10),
            itemBuilder: (_, i) => PlaceCard(place: list[i]),
          );
        },
        loading: () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16),
          itemCount: 5,
          itemBuilder: (_, __) => const PlaceCardShimmer(),
        ),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(nearbyPlacesProvider),
        ),
      ),
    );
  }

  Widget _buildPopularSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue places,
  ) {
    return places.when(
      data: (data) {
        final list = data as List;
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          children: list
              .take(4)
              .map((p) => PlaceCard(place: p, horizontal: false))
              .toList(),
        );
      },
      loading: () => Column(
        children: List.generate(3, (_) => const ListItemShimmer()),
      ),
      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(nearbyPlacesProvider),
      ),
    );
  }
}
