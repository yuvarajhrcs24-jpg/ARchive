import 'package:dio/dio.dart';
import 'package:archive/core/constants/app_constants.dart';
import 'package:archive/core/errors/failures.dart';
import 'package:archive/data/models/place_model.dart';
import 'package:archive/data/models/category_model.dart';

class PlacesRemoteDatasource {
  final Dio dio;

  PlacesRemoteDatasource(this.dio);

  bool get _isConfigured =>
      AppConstants.googlePlacesApiKey != 'YOUR_GOOGLE_PLACES_API_KEY';

  Future<List<PlaceModel>> getNearbyPlaces({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
    String? categoryId,
    String language = 'en',
  }) async {
    if (!_isConfigured) {
      return _getSamplePlaces(lat, lng);
    }

    try {
      final response = await dio.get(
        '${AppConstants.placesBaseUrl}/nearbysearch/json',
        queryParameters: {
          'location': '$lat,$lng',
          'radius': radiusMeters.toInt(),
          'language': language,
          if (categoryId != null && categoryId.isNotEmpty) 'type': categoryId,
          'key': AppConstants.googlePlacesApiKey,
        },
        options: Options(
          sendTimeout: const Duration(seconds: AppConstants.httpTimeoutSeconds),
          receiveTimeout: const Duration(seconds: AppConstants.httpTimeoutSeconds),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List? ?? [];
      return results
          .map((r) => PlaceModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error', statusCode: e.response?.statusCode);
    }
  }

  Future<PlaceModel> getPlaceDetails(
    String placeId, {
    String language = 'en',
  }) async {
    if (!_isConfigured) {
      final samples = await _getSamplePlaces(0, 0);
      return samples.firstWhere(
        (p) => p.id == placeId,
        orElse: () => samples.first,
      );
    }

    try {
      final response = await dio.get(
        '${AppConstants.placesBaseUrl}/details/json',
        queryParameters: {
          'place_id': placeId,
          'language': language,
          'fields':
              'place_id,name,formatted_address,geometry,rating,opening_hours,photos,editorial_summary,types',
          'key': AppConstants.googlePlacesApiKey,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) throw const NotFoundFailure();
      return PlaceModel.fromJson(result);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error', statusCode: e.response?.statusCode);
    }
  }

  Future<List<PlaceModel>> searchPlaces({
    required String query,
    double? lat,
    double? lng,
    String language = 'en',
  }) async {
    if (!_isConfigured) {
      final all = await _getSamplePlaces(lat ?? 0, lng ?? 0);
      return all
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    try {
      final params = <String, dynamic>{
        'query': query,
        'language': language,
        'key': AppConstants.googlePlacesApiKey,
      };
      if (lat != null && lng != null) {
        params['location'] = '$lat,$lng';
        params['radius'] = AppConstants.nearbyRadiusMeters.toInt();
      }
      final response = await dio.get(
        '${AppConstants.placesBaseUrl}/textsearch/json',
        queryParameters: params,
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List? ?? [];
      return results
          .map((r) => PlaceModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error', statusCode: e.response?.statusCode);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    return AppConstants.sampleCategories
        .map((c) => CategoryModel.fromJson(c))
        .toList();
  }

  List<PlaceModel> _getSamplePlaces(double userLat, double userLng) {
    return AppConstants.samplePlaces
        .map((p) => PlaceModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();
  }
}
