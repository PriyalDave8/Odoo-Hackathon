import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  // Auth: Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth.php?action=login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // Auth: Register
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth.php?action=register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // Dashboard Summary
  static Future<Map<String, dynamic>> fetchDashboard(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard.php?user_id=$userId'));
    return jsonDecode(response.body);
  }

  // Trips: Get All
  static Future<Map<String, dynamic>> fetchTrips(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/trips.php?user_id=$userId'));
    return jsonDecode(response.body);
  }

  // Trips: Create
  static Future<Map<String, dynamic>> createTrip({
    required int userId,
    required String title,
    required String destination,
    required String startDate,
    required String endDate,
    required double budget,
    String description = '',
    String coverImageUrl = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trips.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'destination': destination,
        'start_date': startDate,
        'end_date': endDate,
        'budget': budget,
        'status': 'Planned',
        'description': description,
        'cover_image_url': coverImageUrl,
      }),
    );
    return jsonDecode(response.body);
  }

  // Trips: Update
  static Future<Map<String, dynamic>> updateTrip({
    required int id,
    required String title,
    required String destination,
    required String startDate,
    required String endDate,
    required double budget,
    required String status,
    String description = '',
    String coverImageUrl = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/trips.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'title': title,
        'destination': destination,
        'start_date': startDate,
        'end_date': endDate,
        'budget': budget,
        'status': status,
        'description': description,
        'cover_image_url': coverImageUrl,
      }),
    );
    return jsonDecode(response.body);
  }

  // Trips: Delete
  static Future<Map<String, dynamic>> deleteTrip(int tripId) async {
    final response = await http.delete(Uri.parse('$baseUrl/trips.php?id=$tripId'));
    return jsonDecode(response.body);
  }

  // Itinerary: Fetch Full Tree
  static Future<Map<String, dynamic>> fetchItinerary(int tripId) async {
    final response = await http.get(Uri.parse('$baseUrl/itineraries.php?trip_id=$tripId'));
    return jsonDecode(response.body);
  }

  // Itinerary: Add Stop
  static Future<Map<String, dynamic>> addTripStop({
    required int tripId,
    required String cityName,
    required String country,
    required String startDate,
    required String endDate,
    String notes = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/itineraries.php?action=add_stop'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'trip_id': tripId,
        'city_name': cityName,
        'country': country,
        'start_date': startDate,
        'end_date': endDate,
        'notes': notes,
      }),
    );
    return jsonDecode(response.body);
  }

  // Itinerary: Delete Stop
  static Future<Map<String, dynamic>> deleteTripStop(int stopId) async {
    final response = await http.delete(Uri.parse('$baseUrl/itineraries.php?action=delete_stop&id=$stopId'));
    return jsonDecode(response.body);
  }

  // Itinerary: Add Activity
  static Future<Map<String, dynamic>> addStopActivity({
    required int stopId,
    required String title,
    required String category,
    required String timeSlot,
    required double cost,
    String notes = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/itineraries.php?action=add_activity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'stop_id': stopId,
        'title': title,
        'category': category,
        'time_slot': timeSlot,
        'cost': cost,
        'notes': notes,
      }),
    );
    return jsonDecode(response.body);
  }

  // Itinerary: Delete Activity
  static Future<Map<String, dynamic>> deleteStopActivity(int activityId) async {
    final response = await http.delete(Uri.parse('$baseUrl/itineraries.php?action=delete_activity&id=$activityId'));
    return jsonDecode(response.body);
  }
}
