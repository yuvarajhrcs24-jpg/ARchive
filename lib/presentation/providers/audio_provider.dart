import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/utils/logger.dart';

class AudioState {
  final String? url;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isLoading;

  const AudioState({
    this.url,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isLoading = false,
  });

  AudioState copyWith({
    String? url,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isLoading,
  }) {
    return AudioState(
      url: url ?? this.url,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _player;

  AudioNotifier()
      : _player = AudioPlayer(),
        super(const AudioState()) {
    _player.onPlayerStateChanged.listen((playerState) {
      if (mounted) {
        state = state.copyWith(
          isPlaying: playerState == PlayerState.playing,
        );
      }
    });

    _player.onPositionChanged.listen((pos) {
      if (mounted) state = state.copyWith(position: pos);
    });

    _player.onDurationChanged.listen((dur) {
      if (mounted) state = state.copyWith(duration: dur);
    });

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        state = state.copyWith(
          isPlaying: false,
          position: Duration.zero,
        );
      }
    });
  }

  Future<void> play(String url) async {
    try {
      if (state.url == url && state.isPlaying) {
        await pause();
        return;
      }

      state = state.copyWith(url: url, isLoading: true, isPlaying: false);

      if (url.startsWith('/')) {
        await _player.play(DeviceFileSource(url));
      } else {
        await _player.play(UrlSource(url));
      }

      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      AppLogger.error('Audio play error', e, st);
      state = state.copyWith(isLoading: false, isPlaying: false);
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.resume();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
    state = const AudioState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>(
  (ref) => AudioNotifier(),
);
