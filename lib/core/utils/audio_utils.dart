class AudioUtils {
  AudioUtils._();

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static String formatSeconds(int seconds) {
    return formatDuration(Duration(seconds: seconds));
  }
}
