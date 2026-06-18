import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';

  AuthService(this._dio, this._prefs);

  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      final response = await _dio.post('/auth/email/login', data: {'email': email, 'password': password});
      final token = response.data['token'] as String;
      final user = response.data['user'];
      await _prefs.setString(_tokenKey, token);
      return {'token': token, 'user': user};
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<void> sendPhoneOtp(String phone) async {
    try {
      await _dio.post('/auth/phone/send', data: {'phone': phone});
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<Map<String, dynamic>> verifyPhoneOtp(String phone, String code) async {
    try {
      final response = await _dio.post('/auth/phone/verify', data: {'phone': phone, 'code': code});
      final token = response.data['token'] as String;
      final user = response.data['user'];
      await _prefs.setString(_tokenKey, token);
      return {'token': token, 'user': user};
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<Map<String, dynamic>> registerWithEmail(String email, String password, String displayName, String phone) async {
    try {
      final response = await _dio.post('/auth/email/register', data: {'email': email, 'password': password, 'displayName': displayName, 'phone': phone});
      final token = response.data['token'] as String;
      final user = response.data['user'];
      await _prefs.setString(_tokenKey, token);
      return {'token': token, 'user': user};
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<String?> getStoredToken() async => _prefs.getString(_tokenKey);

  Future<void> clearToken() async => await _prefs.remove(_tokenKey);

  Future<Map<String, dynamic>?> getCurrentUser(String token) async {
    try {
      final response = await _dio.get('/users/me', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['user'];
    } catch { return null; }
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
