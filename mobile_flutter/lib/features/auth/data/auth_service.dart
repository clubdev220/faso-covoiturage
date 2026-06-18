import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthService(this._dio, this._prefs);

  // Token management
  Future<String?> getStoredToken() async => _prefs.getString(_tokenKey);

  Future<void> saveToken(String token) async => await _prefs.setString(_tokenKey, token);

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  // Auth operations
  Future<String> loginWithEmail(String email, String password) async {
    try {
      final response = await _dio.post('/auth/email/login', data: {'email': email, 'password': password});
      final token = response.data['token'] as String;
      await saveToken(token);
      return token;
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<void> sendPhoneOtp(String phone) async {
    try {
      await _dio.post('/auth/phone/send', data: {'phone': phone});
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<String> verifyPhoneOtp(String phone, String code) async {
    try {
      final response = await _dio.post('/auth/phone/verify', data: {'phone': phone, 'code': code});
      final token = response.data['token'] as String;
      await saveToken(token);
      return token;
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<void> registerWithEmail({required String email, required String password, required String fullName, String? phone}) async {
    try {
      await _dio.post('/auth/email/register', data: {'email': email, 'password': password, 'fullName': fullName, 'phone': phone});
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<Map<String, dynamic>?> getCurrentUser(String token) async {
    try {
      final response = await _dio.get('/users/me', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['user'] as Map<String, dynamic>?;
    } catch (e) { return null; }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('error')) return Exception(data['error']);
      return Exception('Erreur ${e.response!.statusCode}');
    }
    if (e.type == DioExceptionType.connectionTimeout) return Exception('Connexion timeout. Vérifiez votre internet.');
    return Exception('Erreur de connexion');
  }
}
