class UserPrefs {
  final String preferredLanguage;
  final List<String> selectedCategoryIds;
  final List<String> downloadedCityIds;
  final bool isDarkMode;

  const UserPrefs({
    this.preferredLanguage = 'en',
    this.selectedCategoryIds = const [],
    this.downloadedCityIds = const [],
    this.isDarkMode = true,
  });

  UserPrefs copyWith({
    String? preferredLanguage,
    List<String>? selectedCategoryIds,
    List<String>? downloadedCityIds,
    bool? isDarkMode,
  }) {
    return UserPrefs(
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      downloadedCityIds: downloadedCityIds ?? this.downloadedCityIds,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
