import 'trip_service.dart';

class TripRepository {
  final TripService _tripService;
  TripRepository(this._tripService);

  Future<List<dynamic>> searchTrips({String? originCity, String? destinationCity, String? date, int? minSeats, int? maxPrice}) {
    return _tripService.searchTrips(originCity: originCity, destinationCity: destinationCity, date: date, minSeats: minSeats, maxPrice: maxPrice);
  }

  Future<Map<String, dynamic>> getTripById(String tripId) {
    return _tripService.getTripById(tripId);
  }

  Future<List<dynamic>> getMyTrips(String token) {
    return _tripService.getMyTrips(token);
  }

  Future<Map<String, dynamic>> createTrip(String token, Map<String, dynamic> data) {
    return _tripService.createTrip(token, data);
  }

  Future<void> cancelTrip(String token, String tripId) async {
    // Not in service yet - stub
    throw UnimplementedError('cancelTrip not implemented in service');
  }

  // Alias for screen compatibility
  Future<List<dynamic>> getDriverTrips(String token) {
    return _tripService.getMyTrips(token);
  }
}
