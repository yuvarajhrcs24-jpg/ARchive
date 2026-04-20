import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class AudioGuideService extends ChangeNotifier {
  final Logger _logger = Logger();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  String? _currentPlayingId;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String _currentLanguage = 'English'; // English, Kannada, Hindi

  String? get currentPlayingId => _currentPlayingId;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  String get currentLanguage => _currentLanguage;
  double get volume => _audioPlayer.volume;

  AudioGuideService() {
    _setupAudioListener();
  }

  void _setupAudioListener() {
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;
      if (playerState.processingState == ProcessingState.completed) {
        _currentPlayingId = null;
        _isPlaying = false;
      }
      notifyListeners();
    });
  }

  Future<void> playAudioGuide(String audioUrl, {String? placeId}) async {
    try {
      if (_currentPlayingId == placeId && _isPlaying) {
        await pause();
        return;
      }

      _currentPlayingId = placeId;
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      _logger.e('Error playing audio: $e');
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error pausing audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      _logger.e('Error resuming audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentPlayingId = null;
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    } catch (e) {
      _logger.e('Error stopping audio: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      notifyListeners();
    } catch (e) {
      _logger.e('Error seeking: $e');
    }
  }

  void setVolume(double volume) {
    _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    // In a real app, this would switch the audio URL based on language
    notifyListeners();
  }

  String getAudioUrlForLanguage(String englishUrl, String kannadaUrl, String hindiUrl) {
    switch (_currentLanguage) {
      case 'Kannada':
        return kannadaUrl;
      case 'Hindi':
        return hindiUrl;
      default:
        return englishUrl;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
