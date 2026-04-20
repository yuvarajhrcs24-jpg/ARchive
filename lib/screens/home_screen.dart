import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../models/place.dart';
import '../widgets/category_chip.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationService = context.read<LocationService>();
      final placesService = context.read<PlacesService>();

      // Initialize location
      await locationService.initialize();
      await locationService.startLocationUpdates();

      // Fetch nearby places
      if (locationService.currentPosition != null) {
        await placesService.searchNearbyPlaces(
          locationService.currentPosition!.latitude,
          locationService.currentPosition!.longitude,
        );
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Explore Nearby',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<PlacesService>().searchByName(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search places...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Categories
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: PlacesService().categories
                      .map((category) => CategoryChip(
                            label: category,
                            onTap: () {
                              context
                                  .read<PlacesService>()
                                  .filterByCategory(category);
                            },
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Nearby places
              Consumer2<LocationService, PlacesService>(
                builder: (context, locationService, placesService, _) {
                  if (!_isInitialized) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (locationService.error != null) {
                    return Center(
                      child: Text('Location error: ${locationService.error}'),
                    );
                  }

                  if (placesService.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final places = placesService.filteredPlaces;

                  if (places.isEmpty) {
                    return Center(
                      child: Text(
                        'No places found',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby Places (${places.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          final place = places[index];
                          final distance = locationService.currentPosition != null
                              ? locationService.calculateDistance(
                                  locationService.currentPosition!.latitude,
                                  locationService.currentPosition!.longitude,
                                  place.latitude,
                                  place.longitude,
                                )
                              : 0.0;

                          return PlaceCard(
                            place: place.copyWith(distance: distance),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlaceDetailScreen(place: place),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
