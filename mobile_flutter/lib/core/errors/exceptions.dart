class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'Network error occurred']) : super(message);
}

class AuthException extends AppException {
  AuthException([String message = 'Authentication failed']) : super(message, statusCode: 401);
}

class ServerException extends AppException {
  ServerException([String message = 'Server error occurred']) : super(message, statusCode: 500);
}

class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException(String message, {this.errors}) : super(message, statusCode: 400);
}