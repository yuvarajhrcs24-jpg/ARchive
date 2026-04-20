import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/presentation/providers/saved_provider.dart';
import 'package:archive/presentation/screens/saved/widgets/saved_place_tile.dart';
import 'package:archive/presentation/screens/saved/widgets/trip_tile.dart';
import 'package:archive/presentation/widgets/error_widget.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Saved', style: AppTextStyles.headline3),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            tabs: [
              Tab(text: 'Saved Places'),
              Tab(text: 'Trips'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SavedPlacesTab(),
            _TripsTab(),
          ],
        ),
      ),
    );
  }
}

class _SavedPlacesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedPlacesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(savedPlacesProvider),
      child: savedAsync.when(
        data: (places) {
          if (places.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No saved places yet'),
                  SizedBox(height: 8),
                  Text(
                    'Tap the bookmark on any place to save it',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (_, i) => SavedPlaceTile(savedPlace: places[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(savedPlacesProvider),
        ),
      ),
    );
  }
}

class _TripsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(tripsProvider),
        child: tripsAsync.when(
          data: (trips) {
            if (trips.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No trips yet'),
                    SizedBox(height: 8),
                    Text(
                      'Create a trip to plan your tour',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (_, i) => TripTile(trip: trips[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(tripsProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _createTrip(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _createTrip(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Trip'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Trip name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await ref.read(savedRepositoryProvider).createTrip(
                    controller.text.trim(),
                  );
              ref.invalidate(tripsProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
