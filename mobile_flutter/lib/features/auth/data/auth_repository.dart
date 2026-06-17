import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Send OTP to phone number
  Future<void> sendPhoneOtp(String phoneNumber) async {
    await _dio.post('/auth/phone/send-otp', data: {'phone': phoneNumber});
  }

  /// Verify phone OTP
  Future<String> verifyPhoneOtp(String phoneNumber, String otp) async {
    final response = await _dio.post('/auth/phone/verify-otp', data: {
      'phone': phoneNumber,
      'otp': otp,
    });
    return response.data['token'] as String;
  }

  /// Login with email and password
  Future<String> loginWithEmail(String email, String password) async {
    final response = await _dio.post('/auth/email/login', data: {
      'email': email,
      'password': password,
    });
    return response.data['token'] as String;
  }

  /// Register with email
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    await _dio.post('/auth/email/register', data: {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
    });
  }

  /// Logout
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _dio.patch('/auth/profile', data: data);
  }
}