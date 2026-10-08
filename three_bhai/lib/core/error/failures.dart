/// Domain-level error. Repositories throw [Failure] subclasses; the
/// presentation layer maps them to user-facing messages.
class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'No connection. Check your internet and try again.']);
}

class ServerFailure extends Failure {
  const ServerFailure(
      [super.message = 'Our servers had a problem. Try again in a moment.']);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Incorrect email or password.']);
}
