import 'dart:io';

enum MediaTypeCategory { image, video, audio }

class MediaValidators {
  static const int maxFileSizeBytes = 100 * 1024 * 1024; // 100MB limit

  static const List<String> supportedImageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'tmp'];
  static const List<String> supportedVideoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
  static const List<String> supportedAudioExtensions = ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'];

  static String getExtension(String path) {
    if (!path.contains('.')) return '';
    return path.split('.').last.toLowerCase();
  }

  static MediaTypeCategory? detectCategory(String path) {
    final lowerPath = path.toLowerCase();
    final ext = getExtension(path);

    if (supportedImageExtensions.contains(ext)) return MediaTypeCategory.image;
    if (supportedVideoExtensions.contains(ext)) return MediaTypeCategory.video;
    if (supportedAudioExtensions.contains(ext)) return MediaTypeCategory.audio;

    // Fallback detection for raw camera cache streams & temporary picker files
    if (lowerPath.contains('camera') ||
        lowerPath.contains('image_picker') ||
        lowerPath.contains('scaled_') ||
        lowerPath.contains('picker') ||
        ext == 'tmp' ||
        ext == '') {
      return MediaTypeCategory.image;
    }

    return null;
  }

  static String? validateFile(File file) {
    if (!file.existsSync()) {
      return 'Selected file does not exist.';
    }
    final size = file.lengthSync();
    if (size == 0) {
      return 'Selected file is empty.';
    }
    if (size > maxFileSizeBytes) {
      return 'File size exceeds 100MB limit. Please select a smaller file.';
    }
    final category = detectCategory(file.path);
    if (category == null) {
      return 'Unsupported format. Supported: Images (JPG, PNG, WEBP), Videos (MP4, MOV), Audio (MP3, WAV, AAC).';
    }
    return null;
  }

  static String formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.toString().length - 1) ~/ 3;
    if (i >= suffixes.length) i = suffixes.length - 1;
    double num = bytes / (1 << (i * 10));
    return "${num.toStringAsFixed(decimals)} ${suffixes[i]}";
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }
}
