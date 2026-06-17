import 'package:dio/dio.dart';

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  /// Book a seat on a trip
  Future<String> bookTrip({
    required String tripId,
    required int seats,
    String? message,
  }) async {
    final response = await _dio.post('/bookings', data: {
      'tripId': tripId,
      'seats': seats,
      'message': message,
    });
    return response.data['bookingId'] as String;
  }

  /// Get booking details
  Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    final response = await _dio.get('/bookings/$bookingId');
    return response.data as Map<String, dynamic>;
  }

  /// Get user's bookings (passenger)
  Future<List<Map<String, dynamic>>> getUserBookings({
    String? status,
  }) async {
    final response = await _dio.get('/bookings/my-bookings', queryParameters: {
      if (status != null) 'status': status,
    });
    return List<Map<String, dynamic>>.from(response.data['bookings']);
  }

  /// Get trip bookings (driver)
  Future<List<Map<String, dynamic>>> getTripBookings(String tripId) async {
    final response = await _dio.get('/bookings/trip/$tripId');
    return List<Map<String, dynamic>>.from(response.data['bookings']);
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await _dio.delete('/bookings/$bookingId');
  }

  /// Confirm a booking (driver)
  Future<void> confirmBooking(String bookingId) async {
    await _dio.patch('/bookings/$bookingId/confirm');
  }

  /// Reject a booking (driver)
  Future<void> rejectBooking(String bookingId) async {
    await _dio.patch('/bookings/$bookingId/reject');
  }

  /// Rate a trip after completion
  Future<void> rateTrip({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    await _dio.post('/bookings/$bookingId/rate', data: {
      'rating': rating,
      'comment': comment,
    });
  }
}