import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/presentation/providers/download_provider.dart';
import 'package:archive/presentation/providers/user_prefs_provider.dart';
import 'package:archive/presentation/screens/profile/widgets/download_tile.dart';
import 'package:archive/presentation/screens/profile/widgets/language_selector.dart';
import 'package:archive/presentation/widgets/error_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPrefsProvider);
    final packsAsync = ref.watch(cityPacksProvider);
    final storageAsync = ref.watch(storageUsageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.headline3),
      ),
      body: ListView(
        children: [
          // Avatar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Explorer', style: AppTextStyles.title1),
                Text(
                  'Tour enthusiast',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Language section
          const LanguageSelector(),
          const Divider(),

          // Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Settings', style: AppTextStyles.title2),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: prefs.isDarkMode,
            activeColor: AppColors.primary,
            onChanged: (val) {
              ref.read(userPrefsProvider.notifier).setDarkMode(val);
            },
          ),
          const Divider(),

          // Downloads
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Offline Packs', style: AppTextStyles.title2),
                storageAsync.when(
                  data: (bytes) => Text(
                    _formatBytes(bytes),
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          packsAsync.when(
            data: (packs) => Column(
              children: packs.map((p) => DownloadTile(pack: p)).toList(),
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => AppErrorWidget(
              message: e.toString(),
              onRetry: () => ref.invalidate(cityPacksProvider),
            ),
          ),
          const SizedBox(height: 32),

          // Storage indicator
          storageAsync.when(
            data: (bytes) => bytes > 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Storage Used', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (bytes / (500 * 1024 * 1024)).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade700,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatBytes(bytes)} of 500 MB',
                          style: AppTextStyles.caption.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
