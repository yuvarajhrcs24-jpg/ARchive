abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Location unavailable']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

class AudioFailure extends Failure {
  const AudioFailure([super.message = 'Audio playback error']);
}

class DownloadFailure extends Failure {
  const DownloadFailure([super.message = 'Download failed']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}
