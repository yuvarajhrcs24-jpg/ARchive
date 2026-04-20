import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/domain/entities/city_pack.dart';
import 'package:archive/presentation/providers/download_provider.dart';

class DownloadTile extends ConsumerWidget {
  final CityPack pack;

  const DownloadTile({super.key, required this.pack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressMap = ref.watch(downloadProgressProvider);
    final liveProgress = progressMap[pack.id];
    final isDownloading = liveProgress != null ||
        pack.downloadStatus == CityPackDownloadStatus.downloading;
    final isDownloaded = pack.downloadStatus == CityPackDownloadStatus.downloaded;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.download_for_offline,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pack.cityName, style: AppTextStyles.title2),
                      Text(
                        'v${pack.version} • ${pack.formattedSize}',
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButton(context, ref, isDownloading, isDownloaded),
              ],
            ),
            if (isDownloading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: liveProgress ?? pack.downloadProgress,
                backgroundColor: Colors.grey.shade700,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                '${((liveProgress ?? pack.downloadProgress) * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    bool isDownloading,
    bool isDownloaded,
  ) {
    if (isDownloading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      );
    }

    if (isDownloaded) {
      return IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.error),
        tooltip: 'Delete pack',
        onPressed: () => _confirmDelete(context, ref),
      );
    }

    return IconButton(
      icon: const Icon(Icons.download, color: AppColors.primary),
      tooltip: 'Download pack',
      onPressed: () async {
        await ref.read(downloadProgressProvider.notifier).startDownload(pack.id);
        ref.invalidate(cityPacksProvider);
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pack'),
        content: Text('Delete ${pack.cityName} offline pack?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(downloadProgressProvider.notifier)
                  .deletePack(pack.id);
              ref.invalidate(cityPacksProvider);
              ref.invalidate(storageUsageProvider);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
