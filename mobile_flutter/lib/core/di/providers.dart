import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/trips/data/trip_repository.dart';
import '../../features/trips/data/trip_service.dart';
import '../../features/bookings/data/booking_repository.dart';
import '../../features/bookings/data/booking_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider), ref.watch(sharedPreferencesProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authServiceProvider));
});

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(ref.watch(dioProvider));
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(ref.watch(tripServiceProvider));
});

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService(ref.watch(dioProvider));
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(bookingServiceProvider));
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authRepositoryProvider));
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? token;
  final String? error;
  AuthState({this.isLoading = false, this.isAuthenticated = false, this.user, this.token, this.error});
  AuthState copyWith({bool? isLoading, bool? isAuthenticated, UserModel? user, String? token, String? error}) {
    return AuthState(isLoading: isLoading ?? this.isLoading, isAuthenticated: isAuthenticated ?? this.isAuthenticated, user: user ?? this.user, token: token ?? this.token, error: error);
  }
}

class UserModel {
  final String id;
  final String phone;
  final String? displayName;
  final String? email;
  final String role;
  final String kycStatus;
  final double rating;
  final int reviewCount;
  UserModel({required this.id, required this.phone, this.displayName, this.email, this.role = 'passenger', this.kycStatus = 'none', this.rating = 0, this.reviewCount = 0});
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['uid'] ?? '',
      phone: json['phone'] ?? '',
      displayName: json['displayName'] ?? json['fullName'],
      email: json['email'],
      role: json['role'] ?? 'passenger',
      kycStatus: json['kycStatus'] ?? 'none',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  AuthStateNotifier(this._authRepository) : super(AuthState());

  Future<void> checkAuth() async {
    final token = await _authRepository.getStoredToken();
    if (token != null) {
      try {
        final userData = await _authRepository.getCurrentUser(token);
        if (userData != null) {
          state = state.copyWith(isAuthenticated: true, user: UserModel.fromJson(userData), token: token);
        }
      } catch (e) {
        await _authRepository.clearToken();
        state = AuthState();
      }
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authRepository.loginWithEmail(email, password);
      state = state.copyWith(isLoading: false, isAuthenticated: true, token: result);
    } catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }

  Future<void> loginWithPhone(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.sendPhoneOtp(phone);
      state = state.copyWith(isLoading: false);
    } catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }

  Future<void> verifyPhoneOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _authRepository.verifyPhoneOtp(phone, code);
      state = state.copyWith(isLoading: false, isAuthenticated: true, token: token);
    } catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }

  Future<void> register(String email, String password, String displayName, String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.registerWithEmail(email: email, password: password, fullName: displayName, phone: phone);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }

  Future<void> logout() async {
    await _authRepository.clearToken();
    state = AuthState();
  }
}
