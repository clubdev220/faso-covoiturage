import 'package:dio/dio.dart';

class BookingService {
  final Dio _dio;
  BookingService(this._dio);

  Future<Map<String, dynamic>> createBooking(String token, String tripId, int seats, String paymentMethod) async {
    try {
      final response = await _dio.post('/bookings', data: {'tripId': tripId, 'seats': seats, 'paymentMethod': paymentMethod}, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['booking'];
    } catch (e) { throw Exception('Erreur réservation: $e'); }
  }

  Future<List<dynamic>> getMyBookings(String token) async {
    try {
      final response = await _dio.get('/bookings/my', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['bookings'] ?? [];
    } catch (e) { throw Exception('Erreur: $e'); }
  }

  Future<void> updateBookingStatus(String token, String bookingId, String status) async {
    try {
      await _dio.put('/bookings/$bookingId/status', data: {'status': status}, options: Options(headers: {'Authorization': 'Bearer $token'}));
    } catch (e) { throw Exception('Erreur: $e'); }
  }

  Future<List<dynamic>> getTripBookings(String token, String tripId) async {
    try {
      final response = await _dio.get('/bookings/trip/$tripId', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['bookings'] ?? [];
    } catch (e) { throw Exception('Erreur: $e'); }
  }
}
