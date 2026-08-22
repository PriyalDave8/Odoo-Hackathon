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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeepLink();
    });
  }

  void _checkDeepLink() {
    try {
      final Uri uri = Uri.base;
      String query = uri.query;
      if (query.isEmpty && uri.fragment.contains('?')) {
        query = uri.fragment.split('?').last;
      }

      final Map<String, String> params = Uri.splitQueryString(query);

      if (params.containsKey('trip_id')) {
        final int tripId = int.tryParse(params['trip_id']!) ?? 1;
        final String title = params.containsKey('title') ? Uri.decodeComponent(params['title']!) : 'Euro Summer Getaway';
        final String dest = params.containsKey('dest') ? Uri.decodeComponent(params['dest']!) : 'Paris & Rome';

        setState(() {
          selectedTripForItinerary = {
            'id': tripId,
            'title': title,
            'destination': dest,
            'start_date': '2026-09-10',
            'end_date': '2026-09-20',
            'budget': 2500.0,
            'transport_cost': 650.0,
            'hotel_cost': 1100.0,
            'meal_cost': 550.0,
            'cover_image_url': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80',
          };
          currentTabIndex = 9; // Direct to ItineraryViewScreen
        });
      } else if (params.containsKey('city')) {
        final String cityName = Uri.decodeComponent(params['city']!);
        setState(() {
          currentTabIndex = 2; // Direct to CitySearchScreen
        });
        final cityObj = {
          'id': 1,
          'name': cityName,
          'country': 'France',
          'region': 'Europe',
          'description': 'Famous destination with landmarks, museums, and rich culture.',
          'image_url': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80',
          'average_cost': 1200.0,
          'hotel_avg_cost': 150.0,
          'meal_avg_cost': 55.0,
          'popularity_score': 4.9,
          'best_season': 'May – October',
          'view_count': 1420,
          'visit_count': 380,
        };
        showCityDetailsModal(context, cityObj, (dest) => _navigateToTab(4, destination: dest));
      }
    } catch (e) {
      // fallback
    }
  }

  String? prefilledDestinationForCreateTrip;

  void _navigateToTab(int index, {Map<String, dynamic>? trip, String? destination}) {
    setState(() {
      currentTabIndex = index;
      if (trip != null) {
        selectedTripForItinerary = trip;
      }
      if (destination != null) {
        prefilledDestinationForCreateTrip = destination;
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
                _buildSidebarItem(7, 'Reviews & Ratings ⭐', Icons.rate_review_outlined),

                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  child: Text('COMMUNITY & ACCOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1)),
                ),
                _buildSidebarItem(4, 'Create New Trip', Icons.add_circle_outline),
                _buildSidebarItem(5, 'Profile & Settings', Icons.person_outline),
                if (widget.user['is_admin'] == 1 || widget.user['role'] == 'admin')
                  _buildSidebarItem(6, 'Admin & Analytics 👑', Icons.analytics_outlined),

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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(currentTabIndex),
                child: _buildCurrentView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, String label, IconData icon) {
    final bool isSelected = (currentTabIndex == index);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: _HoverableSidebarItem(
        isSelected: isSelected,
        onTap: () => _navigateToTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(icon, key: ValueKey(isSelected), size: 20, color: isSelected ? Colors.white : const Color(0xFF64748B)),
              ),
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
          onNavigateToCreateTrip: ([dest]) => _navigateToTab(4, destination: dest),
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
        return CitySearchScreen(
          user: widget.user,
          onNavigateToCreateTrip: ([dest]) => _navigateToTab(4, destination: dest),
        );
      case 3:
        return ActivitySearchScreen(user: widget.user);
      case 4:
        return CreateTripScreen(
          key: ValueKey('create_${prefilledDestinationForCreateTrip ?? 'new'}'),
          user: widget.user,
          initialDestination: prefilledDestinationForCreateTrip,
          onTripCreated: () {
            prefilledDestinationForCreateTrip = null;
            _navigateToTab(1);
          },
          onCancel: () {
            prefilledDestinationForCreateTrip = null;
            _navigateToTab(0);
          },
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
        final tripToBuild = selectedTripForItinerary ?? {
          'id': 1,
          'title': 'Euro Summer Getaway',
          'destination': 'Paris & Rome',
          'start_date': '2026-09-10',
          'end_date': '2026-09-20',
          'budget': 2500.0,
          'transport_cost': 650.0,
          'hotel_cost': 1100.0,
          'meal_cost': 550.0,
          'cover_image_url': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80',
        };
        return ItineraryBuilderScreen(
          trip: tripToBuild,
          onBack: () => _navigateToTab(1),
        );
      case 9:
        final tripToView = selectedTripForItinerary ?? {
          'id': 1,
          'title': 'Euro Summer Getaway',
          'destination': 'Paris & Rome',
          'start_date': '2026-09-10',
          'end_date': '2026-09-20',
          'budget': 2500.0,
          'transport_cost': 650.0,
          'hotel_cost': 1100.0,
          'meal_cost': 550.0,
          'cover_image_url': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80',
        };
        return ItineraryViewScreen(
          trip: tripToView,
          onBack: () => _navigateToTab(1),
        );
      default:
        return const SizedBox();
    }
  }
}

class _HoverableSidebarItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isSelected;

  const _HoverableSidebarItem({
    required this.child,
    required this.onTap,
    required this.isSelected,
  });

  @override
  State<_HoverableSidebarItem> createState() => _HoverableSidebarItemState();
}

class _HoverableSidebarItemState extends State<_HoverableSidebarItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: (isHovered && !widget.isSelected) ? Matrix4.translationValues(4.0, 0.0, 0.0) : Matrix4.identity(),
          child: widget.child,
        ),
      ),
    );
  }
}
