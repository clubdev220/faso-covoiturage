class AppException implements Exception {
  final String message;
  final int? statusCode;
  AppException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'Erreur de connexion']) : super(message, statusCode: 0);
}

class AuthException extends AppException {
  AuthException([String message = 'Identifiants incorrects']) : super(message, statusCode: 401);
}

class ServerException extends AppException {
  ServerException([String message = 'Erreur serveur']) : super(message, statusCode: 500);
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  ValidationException(String message, {this.fieldErrors}) : super(message, statusCode: 400);
}