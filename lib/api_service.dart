import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  // Login User
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth.php?action=login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // Register User
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth.php?action=register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // Fetch Dashboard Data
  static Future<Map<String, dynamic>> fetchDashboard(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard.php?user_id=$userId'),
    );
    return jsonDecode(response.body);
  }

  // Create New Trip
  static Future<Map<String, dynamic>> createTrip({
    required int userId,
    required String title,
    required String destination,
    required String startDate,
    required String endDate,
    required double budget,
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
      }),
    );
    return jsonDecode(response.body);
  }
}
