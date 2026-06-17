import 'package:dio/dio.dart';

class TripRepository {
  final Dio _dio;

  TripRepository(this._dio);

  /// Search for available trips
  Future<List<Map<String, dynamic>>> searchTrips({
    required String departure,
    required String arrival,
    required DateTime date,
    int? passengers,
  }) async {
    final response = await _dio.get('/trips/search', queryParameters: {
      'departure': departure,
      'arrival': arrival,
      'date': date.toIso8601String(),
      'passengers': passengers ?? 1,
    });
    return List<Map<String, dynamic>>.from(response.data['trips']);
  }

  /// Get trip details by ID
  Future<Map<String, dynamic>> getTripById(String tripId) async {
    final response = await _dio.get('/trips/$tripId');
    return response.data as Map<String, dynamic>;
  }

  /// Create a new trip (driver)
  Future<String> createTrip(Map<String, dynamic> tripData) async {
    final response = await _dio.post('/trips', data: tripData);
    return response.data['tripId'] as String;
  }

  /// Update a trip
  Future<void> updateTrip(String tripId, Map<String, dynamic> tripData) async {
    await _dio.patch('/trips/$tripId', data: tripData);
  }

  /// Cancel a trip
  Future<void> cancelTrip(String tripId) async {
    await _dio.delete('/trips/$tripId');
  }

  /// Get driver's trips
  Future<List<Map<String, dynamic>>> getDriverTrips() async {
    final response = await _dio.get('/trips/driver/my-trips');
    return List<Map<String, dynamic>>.from(response.data['trips']);
  }

  /// Get trip offers (published trips)
  Future<List<Map<String, dynamic>>> getTripOffers({
    String? departure,
    String? arrival,
    DateTime? date,
  }) async {
    final response = await _dio.get('/trips/offers', queryParameters: {
      if (departure != null) 'departure': departure,
      if (arrival != null) 'arrival': arrival,
      if (date != null) 'date': date.toIso8601String(),
    });
    return List<Map<String, dynamic>>.from(response.data['trips']);
  }
}