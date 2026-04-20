import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 2)
class UserPreferences {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final String preferredLanguage; // English, Kannada, Hindi
  
  @HiveField(2)
  final double autoPlayDistance; // meters - auto-play audio when within this distance
  
  @HiveField(3)
  final List<String> favoriteCategories;
  
  @HiveField(4)
  final bool offlineMode;
  
  @HiveField(5)
  final bool notificationsEnabled;
  
  @HiveField(6)
  final String theme; // light, dark, system

  UserPreferences({
    required this.userId,
    this.preferredLanguage = 'English',
    this.autoPlayDistance = 100.0,
    this.favoriteCategories = const [],
    this.offlineMode = false,
    this.notificationsEnabled = true,
    this.theme = 'system',
  });

  UserPreferences copyWith({
    String? userId,
    String? preferredLanguage,
    double? autoPlayDistance,
    List<String>? favoriteCategories,
    bool? offlineMode,
    bool? notificationsEnabled,
    String? theme,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      autoPlayDistance: autoPlayDistance ?? this.autoPlayDistance,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      offlineMode: offlineMode ?? this.offlineMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'preferredLanguage': preferredLanguage,
      'autoPlayDistance': autoPlayDistance,
      'favoriteCategories': favoriteCategories,
      'offlineMode': offlineMode,
      'notificationsEnabled': notificationsEnabled,
      'theme': theme,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['userId'] ?? '',
      preferredLanguage: map['preferredLanguage'] ?? 'English',
      autoPlayDistance: (map['autoPlayDistance'] ?? 100.0).toDouble(),
      favoriteCategories: List<String>.from(map['favoriteCategories'] ?? []),
      offlineMode: map['offlineMode'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      theme: map['theme'] ?? 'system',
    );
  }
}
