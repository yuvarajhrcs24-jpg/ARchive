import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/core/utils/audio_utils.dart';
import 'package:archive/presentation/providers/audio_provider.dart';

class AudioPlayerWidget extends ConsumerWidget {
  final String audioUrl;
  final String trackTitle;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.trackTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final isThisTrack = audioState.url == audioUrl;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.headphones, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trackTitle.isEmpty ? 'Audio Guide' : trackTitle,
                  style: AppTextStyles.title2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isThisTrack) ...[
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.grey.shade700,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: audioState.duration.inMilliseconds > 0
                    ? audioState.position.inMilliseconds /
                        audioState.duration.inMilliseconds
                    : 0,
                onChanged: (val) {
                  final ms = (val * audioState.duration.inMilliseconds).round();
                  ref
                      .read(audioProvider.notifier)
                      .seek(Duration(milliseconds: ms));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AudioUtils.formatDuration(audioState.position),
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    AudioUtils.formatDuration(audioState.duration),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isThisTrack)
                IconButton(
                  onPressed: () async {
                    await ref.read(audioProvider.notifier).seek(
                          Duration(
                            milliseconds: (audioState.position.inMilliseconds -
                                    10000)
                                .clamp(0, audioState.duration.inMilliseconds),
                          ),
                        );
                  },
                  icon: const Icon(Icons.replay_10, color: AppColors.primary),
                  iconSize: 28,
                ),
              _buildPlayButton(context, ref, audioState, isThisTrack),
              if (isThisTrack)
                IconButton(
                  onPressed: () async {
                    await ref.read(audioProvider.notifier).seek(
                          Duration(
                            milliseconds: (audioState.position.inMilliseconds +
                                    10000)
                                .clamp(0, audioState.duration.inMilliseconds),
                          ),
                        );
                  },
                  icon: const Icon(Icons.forward_10, color: AppColors.primary),
                  iconSize: 28,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(
    BuildContext context,
    WidgetRef ref,
    AudioState audioState,
    bool isThisTrack,
  ) {
    if (isThisTrack && audioState.isLoading) {
      return Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    final isPlaying = isThisTrack && audioState.isPlaying;

    return GestureDetector(
      onTap: () async {
        if (audioUrl.isEmpty) return;
        if (isPlaying) {
          await ref.read(audioProvider.notifier).pause();
        } else if (isThisTrack) {
          await ref.read(audioProvider.notifier).resume();
        } else {
          await ref.read(audioProvider.notifier).play(audioUrl);
        }
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: audioUrl.isEmpty ? Colors.grey : AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
