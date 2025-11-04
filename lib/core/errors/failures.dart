abstract class Failure implements Exception {
  final String message;
  final Object? cause;
  const Failure(this.message, {this.cause});

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {Object? cause})
    : super(message, cause: cause);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, {Object? cause})
    : super(message, cause: cause);
}
