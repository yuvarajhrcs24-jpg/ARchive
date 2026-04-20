import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/domain/entities/place.dart';
import 'package:archive/presentation/providers/location_provider.dart';
import 'package:archive/presentation/providers/places_provider.dart';
import 'package:archive/presentation/screens/map/widgets/map_filter_sheet.dart';
import 'package:archive/presentation/screens/map/widgets/place_preview_card.dart';
import 'package:archive/presentation/widgets/error_widget.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  Place? _selectedPlace;
  Set<Marker> _markers = {};

  static const _defaultPosition = LatLng(12.2958, 76.6394);

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final placesAsync = ref.watch(filteredPlacesProvider);

    final initialPosition = locationAsync.valueOrNull != null
        ? LatLng(
            locationAsync.valueOrNull!.latitude,
            locationAsync.valueOrNull!.longitude,
          )
        : _defaultPosition;

    placesAsync.whenData((places) => _buildMarkers(places));

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            markers: _markers,
            onMapCreated: (controller) {
              if (!_controllerCompleter.isCompleted) {
                _controllerCompleter.complete(controller);
              }
            },
            onTap: (_) => setState(() => _selectedPlace = null),
          ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCircularButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _buildCircularButton(
                    icon: Icons.my_location,
                    onTap: _goToUserLocation,
                  ),
                  const SizedBox(width: 8),
                  _buildCircularButton(
                    icon: Icons.filter_list,
                    onTap: _showFilterSheet,
                  ),
                ],
              ),
            ),
          ),

          // Place preview at bottom
          if (_selectedPlace != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: PlacePreviewCard(
                place: _selectedPlace!,
                onNavigate: () => _launchNavigation(_selectedPlace!),
              ),
            ),

          // Loading overlay
          if (placesAsync.isLoading)
            const Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Loading places...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (placesAsync.hasError)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: AppErrorWidget(
                message: 'Failed to load places',
                onRetry: () => ref.invalidate(filteredPlacesProvider),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  void _buildMarkers(List<Place> places) {
    final markers = places.map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.lat, place.lng),
        infoWindow: InfoWindow(title: place.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _hueForCategory(place.categoryId),
        ),
        onTap: () => setState(() => _selectedPlace = place),
      );
    }).toSet();

    if (mounted) setState(() => _markers = markers);
  }

  double _hueForCategory(String categoryId) {
    switch (categoryId) {
      case 'historical':
        return BitmapDescriptor.hueOrange;
      case 'nature':
        return BitmapDescriptor.hueGreen;
      case 'temples':
        return BitmapDescriptor.hueRose;
      case 'food':
        return BitmapDescriptor.hueRed;
      case 'shopping':
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }

  Future<void> _goToUserLocation() async {
    final location = ref.read(locationProvider).valueOrNull;
    if (location == null) return;

    final controller = await _controllerCompleter.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        15,
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MapFilterSheet(),
    );
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
