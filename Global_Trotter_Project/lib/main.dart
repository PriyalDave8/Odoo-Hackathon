import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';
import 'reviews_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GlobeTrotterApp());
}

class GlobeTrotterApp extends StatefulWidget {
  const GlobeTrotterApp({super.key});

  @override
  State<GlobeTrotterApp> createState() => _GlobeTrotterAppState();
}

class _GlobeTrotterAppState extends State<GlobeTrotterApp> {
  Map<String, dynamic>? currentUser;
  bool isInitializing = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('globetrotter_user');
      if (userJson != null && userJson.isNotEmpty) {
        setState(() {
          currentUser = jsonDecode(userJson);
        });
      }
    } catch (e) {
      // session fallback
    } finally {
      if (mounted) setState(() => isInitializing = false);
    }
  }

  Future<void> _saveSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('globetrotter_user', jsonEncode(user));
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('globetrotter_user');
    setState(() {
      currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Segoe UI'),
        home: const Scaffold(
          backgroundColor: Color(0xFFF8FAFC),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'GlobeTrotter - Travel Planning Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: currentUser == null
          ? AuthScreen(onLoginSuccess: (user) => _saveSession(user))
          : MainShellScreen(
              user: currentUser!,
              onUserUpdated: (updatedUser) => _saveSession(updatedUser),
              onLogout: _logout,
            ),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(Map<String, dynamic> user) onUserUpdated;
  final VoidCallback onLogout;

  const MainShellScreen({
    super.key,
    required this.user,
    required this.onUserUpdated,
    required this.onLogout,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int currentTabIndex = 0; // 0: Dashboard, 1: My Trips, 2: City Search, 3: Activity Search, 4: Create Trip, 5: Profile, 6: Admin, 7: Reviews, 8: Builder, 9: View
  Map<String, dynamic>? selectedTripForItinerary;

  void _navigateToTab(int index, {Map<String, dynamic>? trip}) {
    setState(() {
      currentTabIndex = index;
      if (trip != null) {
        selectedTripForItinerary = trip;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // LEFT SIDEBAR NAVIGATION
          Container(
            width: 250,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'GlobeTrotter',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 16),

                // Main Menu Label
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  child: Text('NAVIGATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1)),
                ),
                _buildSidebarItem(0, 'Dashboard', Icons.dashboard_outlined),
                _buildSidebarItem(1, 'My Trips', Icons.card_travel_outlined),
                _buildSidebarItem(2, 'Explore Cities', Icons.location_city_outlined),
                _buildSidebarItem(3, 'Explore Activities', Icons.local_activity_outlined),

                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  child: Text('COMMUNITY & ADMIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1)),
                ),
                _buildSidebarItem(4, 'Create New Trip', Icons.add_circle_outline),
                _buildSidebarItem(7, 'Reviews & Ratings', Icons.rate_review_outlined),
                _buildSidebarItem(5, 'Profile & Settings', Icons.person_outline),
                _buildSidebarItem(6, 'Admin & Analytics', Icons.analytics_outlined),

                const Spacer(),
                const Divider(color: Color(0xFFF1F5F9), height: 1),

                // Bottom User Profile & Sign Out
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF2563EB),
                          child: Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user['name'] ?? 'User',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                              Text(
                                widget.user['email'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
                          tooltip: 'Sign Out',
                          onPressed: widget.onLogout,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // MAIN CONTENT AREA
          Expanded(
            child: _buildCurrentView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, String label, IconData icon) {
    final bool isSelected = (currentTabIndex == index);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: InkWell(
        onTap: () => _navigateToTab(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (currentTabIndex) {
      case 0:
        return DashboardScreen(
          user: widget.user,
          onLogout: widget.onLogout,
          onNavigateToMyTrips: () => _navigateToTab(1),
          onNavigateToCreateTrip: () => _navigateToTab(4),
          onBuildItinerary: (trip) => _navigateToTab(8, trip: trip),
        );
      case 1:
        return MyTripsScreen(
          user: widget.user,
          onCreateNewTrip: () => _navigateToTab(4),
          onBuildItinerary: (trip) => _navigateToTab(8, trip: trip),
          onViewItinerary: (trip) => _navigateToTab(9, trip: trip),
        );
      case 2:
        return CitySearchScreen(user: widget.user);
      case 3:
        return ActivitySearchScreen(user: widget.user);
      case 4:
        return CreateTripScreen(
          user: widget.user,
          onTripCreated: () => _navigateToTab(1),
          onCancel: () => _navigateToTab(0),
        );
      case 5:
        return ProfileScreen(
          user: widget.user,
          onProfileUpdated: widget.onUserUpdated,
          onLogout: widget.onLogout,
        );
      case 6:
        return AdminAnalyticsScreen(
          user: widget.user,
        );
      case 7:
        return ReviewsScreen(
          user: widget.user,
        );
      case 8:
        if (selectedTripForItinerary == null) return const Center(child: Text('No trip selected'));
        return ItineraryBuilderScreen(
          trip: selectedTripForItinerary!,
          onBack: () => _navigateToTab(1),
        );
      case 9:
        if (selectedTripForItinerary == null) return const Center(child: Text('No trip selected'));
        return ItineraryViewScreen(
          trip: selectedTripForItinerary!,
          onBack: () => _navigateToTab(1),
        );
      default:
        return const SizedBox();
    }
  }
}
