import 'package:flutter/material.dart';
import 'screens.dart';

void main() {
  runApp(const GlobeTrotterApp());
}

class GlobeTrotterApp extends StatefulWidget {
  const GlobeTrotterApp({super.key});

  @override
  State<GlobeTrotterApp> createState() => _GlobeTrotterAppState();
}

class _GlobeTrotterAppState extends State<GlobeTrotterApp> {
  Map<String, dynamic>? currentUser;

  @override
  Widget build(BuildContext context) {
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
          ? AuthScreen(onLoginSuccess: (user) => setState(() => currentUser = user))
          : MainShellScreen(
              user: currentUser!,
              onLogout: () => setState(() => currentUser = null),
            ),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const MainShellScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int currentTabIndex = 0; // 0: Dashboard, 1: My Trips, 2: City Search, 3: Activity Search, 4: Create Trip, 5: Builder, 6: View
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'GlobeTrotter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 28),
            _buildNavTab(0, 'Dashboard', Icons.dashboard_outlined),
            _buildNavTab(1, 'My Trips', Icons.card_travel_outlined),
            _buildNavTab(2, 'Explore Cities', Icons.location_city_outlined),
            _buildNavTab(3, 'Explore Activities', Icons.local_activity_outlined),
            _buildNavTab(4, 'Create Trip', Icons.add_circle_outline),
          ],
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_outlined, size: 18, color: Color(0xFF475569)),
                  const SizedBox(width: 6),
                  Text(
                    widget.user['name'] ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
            tooltip: 'Sign Out',
            onPressed: widget.onLogout,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _buildCurrentView(),
    );
  }

  Widget _buildNavTab(int index, String label, IconData icon) {
    final bool isSelected = (currentTabIndex == index);
    return InkWell(
      onTap: () => _navigateToTab(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              ),
            ),
          ],
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
          onBuildItinerary: (trip) => _navigateToTab(5, trip: trip),
        );
      case 1:
        return MyTripsScreen(
          user: widget.user,
          onCreateNewTrip: () => _navigateToTab(4),
          onBuildItinerary: (trip) => _navigateToTab(5, trip: trip),
          onViewItinerary: (trip) => _navigateToTab(6, trip: trip),
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
        if (selectedTripForItinerary == null) return const Center(child: Text('No trip selected'));
        return ItineraryBuilderScreen(
          trip: selectedTripForItinerary!,
          onBack: () => _navigateToTab(1),
        );
      case 6:
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
