import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:archive/core/utils/logger.dart';

class LocationNotifier extends StateNotifier<AsyncValue<Position?>> {
  LocationNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = const AsyncValue.data(null);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = const AsyncValue.data(null);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = const AsyncValue.data(null);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      state = AsyncValue.data(position);
      _startStream();
    } catch (e, st) {
      AppLogger.error('Location error', e, st);
      state = const AsyncValue.data(null);
    }
  }

  void _startStream() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    ).listen(
      (position) => state = AsyncValue.data(position),
      onError: (e) => AppLogger.error('Location stream error', e),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _init();
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<Position?>>(
  (ref) => LocationNotifier(),
);
