import 'dart:convert';

class UserPrefsModel {
  final String preferredLanguage;
  final List<String> selectedCategoryIds;
  final List<String> downloadedCityIds;

  const UserPrefsModel({
    this.preferredLanguage = 'en',
    this.selectedCategoryIds = const [],
    this.downloadedCityIds = const [],
  });

  factory UserPrefsModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        try {
          final decoded = jsonDecode(value) as List?;
          return decoded?.cast<String>() ?? [];
        } catch (_) {
          return [];
        }
      }
      if (value is List) return List<String>.from(value);
      return [];
    }

    return UserPrefsModel(
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      selectedCategoryIds: parseList(json['selectedCategoryIds']),
      downloadedCityIds: parseList(json['downloadedCityIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredLanguage': preferredLanguage,
      'selectedCategoryIds': selectedCategoryIds,
      'downloadedCityIds': downloadedCityIds,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'preferredLanguage': preferredLanguage,
      'selectedCategoryIds': jsonEncode(selectedCategoryIds),
      'downloadedCityIds': jsonEncode(downloadedCityIds),
    };
  }

  factory UserPrefsModel.fromMap(Map<String, dynamic> map) =>
      UserPrefsModel.fromJson(map);

  UserPrefsModel copyWith({
    String? preferredLanguage,
    List<String>? selectedCategoryIds,
    List<String>? downloadedCityIds,
  }) {
    return UserPrefsModel(
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      downloadedCityIds: downloadedCityIds ?? this.downloadedCityIds,
    );
  }
}
