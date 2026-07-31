class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
  ]) : super(code: 'network');
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error. Please try again later.',
  ]) : super(code: 'server');
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'City not found. Please check the spelling.',
  ]) : super(code: 'not_found');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message =
        'Invalid API key. Set your OpenWeatherMap key in api_constants.dart '
        'or via --dart-define=OWM_API_KEY=your_key.',
  ]) : super(code: 'unauthorized');
}

class AuthException extends AppException {
  const AuthException(super.message) : super(code: 'auth');
}

class ValidationException extends AppException {
  const ValidationException(super.message) : super(code: 'validation');
}
