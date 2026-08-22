import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8088/api.php';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'new_password': newPassword}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchReviews() async {
    final response = await http.get(Uri.parse('$baseUrl?action=reviews'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addReview({
    required int userId,
    required String destinationName,
    required int rating,
    required String title,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=add_review'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'destination_name': destinationName,
        'rating': rating,
        'title': title,
        'comment': comment,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteReview(int reviewId, int adminUserId) async {
    final response = await http.delete(Uri.parse('$baseUrl?action=delete_review&id=$reviewId&user_id=$adminUserId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    required String email,
    required String profilePhotoUrl,
    required String languagePreference,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=update_profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'name': name,
        'email': email,
        'profile_photo_url': profilePhotoUrl,
        'language_preference': languagePreference,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteAccount(int userId) async {
    final response = await http.delete(Uri.parse('$baseUrl?action=delete_account&user_id=$userId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchSavedDestinations(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl?action=saved_destinations&user_id=$userId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> toggleSavedDestination(int userId, int destinationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=toggle_saved_destination'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'destination_id': destinationId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchAdminAnalytics(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl?action=admin_analytics&user_id=$userId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchDashboard(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl?action=dashboard&user_id=$userId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchTrips(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl?action=trips&user_id=$userId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createTrip({
    required int userId,
    required String title,
    required String destination,
    required String startDate,
    required String endDate,
    required double budget,
    double transportCost = 0.0,
    double hotelCost = 0.0,
    double mealCost = 0.0,
    String travelStyle = 'Cultural Exploration 🏛️',
    String transportType = 'Flight ✈️',
    String accommodationType = 'Boutique Hotel 🏨',
    String groupSize = 'Couple (2)',
    String currency = 'USD (\$)',
    String description = '',
    String coverImageUrl = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=create_trip'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'destination': destination,
        'start_date': startDate,
        'end_date': endDate,
        'budget': budget,
        'transport_cost': transportCost,
        'hotel_cost': hotelCost,
        'meal_cost': mealCost,
        'travel_style': travelStyle,
        'transport_type': transportType,
        'accommodation_type': accommodationType,
        'group_size': groupSize,
        'currency': currency,
        'description': description,
        'cover_image_url': coverImageUrl,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteTrip(int tripId) async {
    final response = await http.delete(Uri.parse('$baseUrl?action=delete_trip&id=$tripId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchItinerary(int tripId) async {
    final response = await http.get(Uri.parse('$baseUrl?action=itinerary&trip_id=$tripId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addTripStop({
    required int tripId,
    required String cityName,
    required String country,
    required String startDate,
    required String endDate,
    String notes = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=add_stop'),
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

  static Future<Map<String, dynamic>> deleteTripStop(int stopId) async {
    final response = await http.delete(Uri.parse('$baseUrl?action=delete_stop&id=$stopId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addStopActivity({
    required int stopId,
    required String title,
    required String category,
    required String timeSlot,
    required double cost,
    String notes = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=add_activity'),
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

  static Future<Map<String, dynamic>> deleteStopActivity(int activityId) async {
    final response = await http.delete(Uri.parse('$baseUrl?action=delete_activity&id=$activityId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateTripExpenses({
    required int tripId,
    required double transportCost,
    required double hotelCost,
    required double mealCost,
    double budget = 0.0,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=update_trip_expenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'trip_id': tripId,
        'transport_cost': transportCost,
        'hotel_cost': hotelCost,
        'meal_cost': mealCost,
        'budget': budget,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> copyTrip(int tripId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=copy_trip'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'trip_id': tripId,
        'user_id': userId,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> searchCities({String query = '', String region = 'All', String sort = 'popular'}) async {
    final Uri uri = Uri.parse('$baseUrl?action=cities&q=${Uri.encodeComponent(query)}&region=${Uri.encodeComponent(region)}&sort=${Uri.encodeComponent(sort)}');
    final response = await http.get(uri);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> recordCityView(int cityId) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=record_city_view'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'city_id': cityId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> searchActivities({String query = '', String category = 'All', double maxCost = 0.0}) async {
    final Uri uri = Uri.parse('$baseUrl?action=activities&q=${Uri.encodeComponent(query)}&category=${Uri.encodeComponent(category)}&max_cost=$maxCost');
    final response = await http.get(uri);
    return jsonDecode(response.body);
  }
}
