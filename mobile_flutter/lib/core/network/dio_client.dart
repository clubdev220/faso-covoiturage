import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
    receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
    logPrint: (obj) => print('[DIO] $obj'),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        print('[DIO] Unauthorized');
      }
      handler.next(error);
    },
  ));

  return dio;
});

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}