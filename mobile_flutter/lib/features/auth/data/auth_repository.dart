import 'auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<String> loginWithEmail(String email, String password) =>
      _authService.loginWithEmail(email, password);

  Future<void> sendPhoneOtp(String phone) =>
      _authService.sendPhoneOtp(phone);

  Future<String> verifyPhoneOtp(String phone, String code) =>
      _authService.verifyPhoneOtp(phone, code);

  Future<void> registerWithEmail({required String email, required String password, required String fullName, String? phone}) =>
      _authService.registerWithEmail(email: email, password: password, fullName: fullName, phone: phone);

  Future<String?> getStoredToken() => _authService.getStoredToken();

  Future<void> clearToken() => _authService.clearToken();

  Future<Map<String, dynamic>?> getCurrentUser(String token) =>
      _authService.getCurrentUser(token);
}
