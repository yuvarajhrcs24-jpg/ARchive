import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/presentation/navigation/app_router.dart';
import 'package:archive/presentation/providers/user_prefs_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPrefsProvider);

    return MaterialApp.router(
      title: 'ARchive',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      cardColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
