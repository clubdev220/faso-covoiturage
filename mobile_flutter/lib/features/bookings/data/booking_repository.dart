import 'booking_service.dart';

class BookingRepository {
  final BookingService _bookingService;
  BookingRepository(this._bookingService);

  Future<Map<String, dynamic>> createBooking(String token, String tripId, int seats, String paymentMethod) {
    return _bookingService.createBooking(token, tripId, seats, paymentMethod);
  }

  Future<List<dynamic>> getMyBookings(String token) {
    return _bookingService.getMyBookings(token);
  }

  Future<void> updateBookingStatus(String token, String bookingId, String status) {
    return _bookingService.updateBookingStatus(token, bookingId, status);
  }

  Future<List<dynamic>> getTripBookings(String token, String tripId) {
    return _bookingService.getTripBookings(token, tripId);
  }

  // Aliases for screen compatibility
  Future<void> confirmBooking(String token, String bookingId) {
    return _bookingService.updateBookingStatus(token, bookingId, 'confirmed');
  }

  Future<void> rejectBooking(String token, String bookingId) {
    return _bookingService.updateBookingStatus(token, bookingId, 'rejected');
  }
}
