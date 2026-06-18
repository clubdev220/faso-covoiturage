import 'package:dio/dio.dart';

class TripService {
  final Dio _dio;
  TripService(this._dio);

  Future<List<dynamic>> searchTrips({String? originCity, String? destinationCity, String? date, int? minSeats, int? maxPrice, int page = 1, int limit = 20}) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (originCity != null) queryParams['originCity'] = originCity;
      if (destinationCity != null) queryParams['destinationCity'] = destinationCity;
      if (date != null) queryParams['date'] = date;
      if (minSeats != null) queryParams['minSeats'] = minSeats;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      final response = await _dio.get('/trips', queryParameters: queryParams);
      return response.data['trips'] ?? [];
    } catch (e) { throw Exception('Erreur recherche: $e'); }
  }

  Future<Map<String, dynamic>> getTripById(String tripId) async {
    try {
      final response = await _dio.get('/trips/$tripId');
      return response.data['trip'];
    } catch (e) { throw Exception('Erreur chargement trajet: $e'); }
  }

  Future<List<dynamic>> getMyTrips(String token) async {
    try {
      final response = await _dio.get('/trips/my', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['trips'] ?? [];
    } catch (e) { throw Exception('Erreur chargement: $e'); }
  }

  Future<Map<String, dynamic>> createTrip(String token, Map<String, dynamic> tripData) async {
    try {
      final response = await _dio.post('/trips', data: tripData, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['trip'];
    } catch (e) { throw Exception('Erreur création: $e'); }
  }
}
