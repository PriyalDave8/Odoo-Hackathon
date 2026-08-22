import 'package:flutter/material.dart';
import 'api_service.dart';

// ==========================================
// 1. AUTH SCREEN (Login & Registration)
// ==========================================
class AuthScreen extends StatefulWidget {
  final Function(Map<String, dynamic> user) onLoginSuccess;

  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final res = isLogin
          ? await ApiService.login(_emailController.text.trim(), _passwordController.text)
          : await ApiService.register(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text);

      if (res['success'] == true) {
        widget.onLoginSuccess(res['user']);
      } else {
        setState(() => errorMessage = res['message'] ?? 'Authentication failed.');
      }
    } catch (e) {
      setState(() => errorMessage = 'Connection error ($e). Please ensure backend API is accessible.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(36.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Text('GlobeTrotter', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(isLogin ? 'Welcome Back' : 'Create an Account', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Text(
                    isLogin ? 'Sign in to access your personal travel itineraries and plans.' : 'Join GlobeTrotter to start planning multi-city journeys seamlessly.',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),

                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFCA5A5))),
                      child: Text(errorMessage!, style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!isLogin) ...[
                    const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Alex Morgan', Icons.person_outline),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('alex@globetrotter.com', Icons.email_outlined),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                      if (isLogin)
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent to your email.')));
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('Forgot Password?', style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      '••••••••',
                      Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isLogin ? "Don't have an account? " : "Already have an account? ", style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                      GestureDetector(
                        onTap: () => setState(() => isLogin = !isLogin),
                        child: Text(isLogin ? 'Sign Up' : 'Sign In', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    );
  }
}

// ==========================================
// 2. DASHBOARD SCREEN (Full Rich Original Design)
// ==========================================
class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;
  final VoidCallback onNavigateToMyTrips;
  final VoidCallback onNavigateToCreateTrip;
  final Function(Map<String, dynamic> trip) onBuildItinerary;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onNavigateToMyTrips,
    required this.onNavigateToCreateTrip,
    required this.onBuildItinerary,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  String? error;

  Map<String, dynamic> stats = {'total_trips': 0, 'active_trips': 0, 'total_budget': 0.0};
  List<dynamic> trips = [];
  List<dynamic> destinations = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final res = await ApiService.fetchDashboard(widget.user['id']);
      if (res['success'] == true) {
        setState(() {
          stats = res['stats'];
          trips = res['trips'];
          destinations = res['recommended_destinations'];
        });
      } else {
        setState(() => error = res['message'] ?? 'Failed to load dashboard.');
      }
    } catch (e) {
      setState(() => error = 'Unable to connect to server.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
        : error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(error!, style: const TextStyle(color: Color(0xFFDC2626))),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadDashboardData, child: const Text('Retry')),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${widget.user['name']} 👋',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Here is an overview of your planned journeys and travel budget.',
                              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: widget.onNavigateToCreateTrip,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Plan New Trip', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Metric Stats Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = (constraints.maxWidth - 32) / 3;
                        return Row(
                          children: [
                            _buildMetricCard(
                              width: width,
                              title: 'Total Trips',
                              value: '${stats['total_trips']}',
                              icon: Icons.map_outlined,
                              accentColor: const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 16),
                            _buildMetricCard(
                              width: width,
                              title: 'Active / Upcoming',
                              value: '${stats['active_trips']}',
                              icon: Icons.flight_outlined,
                              accentColor: const Color(0xFF059669),
                            ),
                            const SizedBox(width: 16),
                            _buildMetricCard(
                              width: width,
                              title: 'Estimated Budget',
                              value: '\$${(stats['total_budget'] as num).toStringAsFixed(2)}',
                              icon: Icons.account_balance_wallet_outlined,
                              accentColor: const Color(0xFFD97706),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // Trips & Destinations Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recent Trips Section (Left column)
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'My Recent Trips',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: widget.onNavigateToMyTrips,
                                      child: const Text('View All Trips →', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                if (trips.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const Text('No trips planned yet.', style: TextStyle(color: Color(0xFF94A3B8))),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: widget.onNavigateToCreateTrip,
                                            child: const Text('Plan New Trip'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: trips.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final trip = Map<String, dynamic>.from(trips[index]);
                                      return _buildTripTile(trip);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Popular Destinations (Right column)
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recommended Cities',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Popular destinations for your next journey',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 18),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: destinations.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                    final dest = destinations[index];
                                    return _buildDestinationCard(dest);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
  }

  Widget _buildMetricCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripTile(Map<String, dynamic> trip) {
    return InkWell(
      onTap: () => widget.onBuildItinerary(trip),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const Icon(Icons.explore_outlined, color: Color(0xFF2563EB), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip['title'] ?? 'Untitled Trip',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        trip['destination'] ?? '',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        '${trip['start_date']} to ${trip['end_date']}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${(trip['budget'] as num).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Text(
                    trip['status'] ?? 'Planned',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF047857)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> dest) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Image.network(
            dest['image_url'] ?? '',
            width: 90,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 90,
              height: 70,
              color: const Color(0xFFE2E8F0),
              child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dest['name']}, ${dest['country']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  dest['description'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Text(
              '~\$${(dest['average_cost'] as num).toInt()}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. CREATE TRIP SCREEN
// ==========================================
class CreateTripScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTripCreated;
  final VoidCallback onCancel;

  const CreateTripScreen({
    super.key,
    required this.user,
    required this.onTripCreated,
    required this.onCancel,
  });

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController(text: '2026-09-10');
  final _endDateController = TextEditingController(text: '2026-09-20');
  final _budgetController = TextEditingController(text: '2500');
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();

  bool isSubmitting = false;
  String? error;

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
      error = null;
    });

    try {
      final res = await ApiService.createTrip(
        userId: widget.user['id'],
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        budget: double.tryParse(_budgetController.text) ?? 1000.0,
        description: _descriptionController.text.trim(),
        coverImageUrl: _coverUrlController.text.trim(),
      );

      if (res['success'] == true) {
        widget.onTripCreated();
      } else {
        setState(() => error = res['message'] ?? 'Failed to create trip.');
      }
    } catch (e) {
      setState(() => error = 'Network error. Please try again.');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Color(0xFF2563EB), size: 28),
                        SizedBox(width: 12),
                        Text('Create New Trip', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)), onPressed: widget.onCancel),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Initiate a new travel itinerary by filling in your primary destination and travel dates.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                const SizedBox(height: 24),

                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFCA5A5))),
                    child: Text(error!, style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13)),
                  ),
                ],

                const Text('Trip Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('e.g. Euro Summer Getaway', Icons.card_travel_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a trip name' : null,
                ),
                const SizedBox(height: 16),

                const Text('Primary Destination(s) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _destinationController,
                  decoration: _inputDecoration('e.g. Paris & Rome', Icons.location_on_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter destination' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextFormField(controller: _startDateController, decoration: _inputDecoration('YYYY-MM-DD', Icons.calendar_today_outlined), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextFormField(controller: _endDateController, decoration: _inputDecoration('YYYY-MM-DD', Icons.event_outlined), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Estimated Total Budget (\$)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(controller: _budgetController, keyboardType: TextInputType.number, decoration: _inputDecoration('2500.00', Icons.attach_money_outlined)),
                const SizedBox(height: 16),

                const Text('Cover Image URL (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(controller: _coverUrlController, decoration: _inputDecoration('https://images.unsplash.com/...', Icons.image_outlined)),
                const SizedBox(height: 16),

                const Text('Trip Description & Notes (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(controller: _descriptionController, maxLines: 3, decoration: _inputDecoration('Describe your trip goals and vision...', Icons.notes_outlined)),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: widget.onCancel, child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: isSubmitting ? null : _submit,
                      icon: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    );
  }
}

// ==========================================
// 4. MY TRIPS SCREEN
// ==========================================
class MyTripsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(Map<String, dynamic> trip) onBuildItinerary;
  final Function(Map<String, dynamic> trip) onViewItinerary;
  final VoidCallback onCreateNewTrip;

  const MyTripsScreen({
    super.key,
    required this.user,
    required this.onBuildItinerary,
    required this.onViewItinerary,
    required this.onCreateNewTrip,
  });

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  bool isLoading = true;
  String? error;
  List<dynamic> trips = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final res = await ApiService.fetchTrips(widget.user['id']);
      if (res['success'] == true) {
        setState(() => trips = res['trips']);
      } else {
        setState(() => error = res['message'] ?? 'Failed to load trips.');
      }
    } catch (e) {
      setState(() => error = 'Unable to connect to backend server.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteTrip(int tripId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final res = await ApiService.deleteTrip(tripId);
        if (res['success'] == true) _loadTrips();
      } catch (e) {
        // handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrips = trips.where((t) {
      final title = (t['title'] ?? '').toString().toLowerCase();
      final dest = (t['destination'] ?? '').toString().toLowerCase();
      final q = searchQuery.toLowerCase();
      return title.contains(q) || dest.contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Travel Itineraries', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                  SizedBox(height: 4),
                  Text('Access, build, and review all your planned multi-city journeys.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: widget.onCreateNewTrip,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Plan New Trip', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Bar
          TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search trips by title or destination...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
          const SizedBox(height: 24),

          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF2563EB))))
          else if (error != null)
            Center(
              child: Column(
                children: [
                  Text(error!, style: const TextStyle(color: Color(0xFFDC2626))),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loadTrips, child: const Text('Retry')),
                ],
              ),
            )
          else if (filteredTrips.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                children: [
                  const Icon(Icons.flight_takeoff, size: 48, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 16),
                  const Text('No trips found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  const Text('Start by creating a new trip itinerary to plan your journey.', style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final double cardWidth = (constraints.maxWidth - 24) / 2;
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: filteredTrips.map((t) {
                    final trip = Map<String, dynamic>.from(t);
                    return _buildTripCard(cardWidth, trip);
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTripCard(double width, Map<String, dynamic> trip) {
    final String coverUrl = (trip['cover_image_url'] != null && trip['cover_image_url'].toString().isNotEmpty)
        ? trip['cover_image_url']
        : 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80';

    return Container(
      width: width < 380 ? double.infinity : width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                coverUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(height: 140, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image_not_supported)),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Text(trip['status'] ?? 'Planned', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip['title'] ?? 'Untitled Trip', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(trip['destination'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text('${trip['start_date']} — ${trip['end_date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Budget', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        Text('\$${(trip['budget'] as num).toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Stops Planned', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        Text('${trip['stop_count'] ?? 0} Cities', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => widget.onBuildItinerary(trip),
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Build Itinerary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          foregroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onViewItinerary(trip),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('View Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 20),
                      onPressed: () => _deleteTrip(trip['id']),
                      tooltip: 'Delete Trip',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. ITINERARY BUILDER & VIEW SCREENS
// ==========================================
class ItineraryBuilderScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onBack;

  const ItineraryBuilderScreen({super.key, required this.trip, required this.onBack});

  @override
  State<ItineraryBuilderScreen> createState() => _ItineraryBuilderScreenState();
}

class _ItineraryBuilderScreenState extends State<ItineraryBuilderScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? itineraryData;

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final res = await ApiService.fetchItinerary(widget.trip['id']);
      if (res['success'] == true) {
        setState(() => itineraryData = res);
      } else {
        setState(() => error = res['message'] ?? 'Failed to load itinerary.');
      }
    } catch (e) {
      setState(() => error = 'Unable to connect to backend server.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showAddStopDialog() {
    final cityController = TextEditingController();
    final countryController = TextEditingController();
    final startDateController = TextEditingController(text: widget.trip['start_date'] ?? '2026-09-10');
    final endDateController = TextEditingController(text: widget.trip['end_date'] ?? '2026-09-15');
    final notesController = TextEditingController();

    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.location_city_outlined, color: Color(0xFF2563EB)),
                  SizedBox(width: 10),
                  Text('Add Travel Stop (City)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: cityController, decoration: _dialogInput('City Name (e.g. Zurich)')),
                    const SizedBox(height: 10),
                    TextField(controller: countryController, decoration: _dialogInput('Country (e.g. Switzerland)')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: startDateController, decoration: _dialogInput('Start Date'))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: endDateController, decoration: _dialogInput('End Date'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: notesController, decoration: _dialogInput('Notes / Accommodation')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (cityController.text.isEmpty || countryController.text.isEmpty) return;
                          setDialogState(() => isSubmitting = true);
                          final res = await ApiService.addTripStop(
                            tripId: widget.trip['id'],
                            cityName: cityController.text.trim(),
                            country: countryController.text.trim(),
                            startDate: startDateController.text.trim(),
                            endDate: endDateController.text.trim(),
                            notes: notesController.text.trim(),
                          );
                          if (res['success'] == true) {
                            if (context.mounted) Navigator.pop(context);
                            _loadItinerary();
                          } else {
                            setDialogState(() => isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Add Stop'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddActivityDialog(int stopId) {
    final titleController = TextEditingController();
    final costController = TextEditingController(text: '25.00');
    final timeSlotController = TextEditingController(text: '10:00 AM');
    final categoryController = TextEditingController(text: 'Sightseeing');
    final notesController = TextEditingController();

    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.local_activity_outlined, color: Color(0xFF059669)),
                  SizedBox(width: 10),
                  Text('Add Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleController, decoration: _dialogInput('Activity Title (e.g. Guided Museum Tour)')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: timeSlotController, decoration: _dialogInput('Time Slot (e.g. 10:00 AM)'))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: costController, keyboardType: TextInputType.number, decoration: _dialogInput('Cost (\$)'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: categoryController, decoration: _dialogInput('Category (Sightseeing, Food, Culture)')),
                    const SizedBox(height: 10),
                    TextField(controller: notesController, decoration: _dialogInput('Notes / Booking Confirmation')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (titleController.text.isEmpty) return;
                          setDialogState(() => isSubmitting = true);
                          final res = await ApiService.addStopActivity(
                            stopId: stopId,
                            title: titleController.text.trim(),
                            category: categoryController.text.trim(),
                            timeSlot: timeSlotController.text.trim(),
                            cost: double.tryParse(costController.text) ?? 0.0,
                            notes: notesController.text.trim(),
                          );
                          if (res['success'] == true) {
                            if (context.mounted) Navigator.pop(context);
                            _loadItinerary();
                          } else {
                            setDialogState(() => isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Add Activity'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _dialogInput(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> stops = itineraryData?['stops'] ?? [];
    final double totalCost = (itineraryData?['total_activities_cost'] as num?)?.toDouble() ?? 0.0;
    final double budget = (widget.trip['budget'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Itinerary Builder: ${widget.trip['title']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text('${widget.trip['destination']} (${widget.trip['start_date']} — ${widget.trip['end_date']})', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddStopDialog,
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Add City Stop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Budget Highlights Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Planned Budget', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 2),
                      Text('\$${budget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Activities Cost Total', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 2),
                      Text('\$${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Remaining Budget', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 2),
                      Text(
                        '\$${(budget - totalCost).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: (budget - totalCost) >= 0 ? const Color(0xFF2563EB) : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF2563EB))))
          else if (error != null)
            Text(error!, style: const TextStyle(color: Color(0xFFDC2626)))
          else if (stops.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Column(
                children: [
                  Icon(Icons.map_outlined, size: 44, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 12),
                  Text('No city stops added yet.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Click "Add City Stop" above to define stops and activities for this trip.', style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stops.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final stop = stops[index];
                return _buildStopBuilderCard(stop, index + 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStopBuilderCard(Map<String, dynamic> stop, int order) {
    final List<dynamic> activities = stop['activities'] ?? [];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text('$order', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Text('${stop['city_name']}, ${stop['country']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(width: 12),
                Text('(${stop['start_date']} — ${stop['end_date']})', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddActivityDialog(stop['id']),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Activity'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 18),
                  onPressed: () async {
                    await ApiService.deleteTripStop(stop['id']);
                    _loadItinerary();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: activities.isEmpty
                ? const Text('No activities scheduled for this stop yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))
                : Column(
                    children: activities.map((act) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(act['time_slot'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(act['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  if (act['notes'] != null && act['notes'].toString().isNotEmpty)
                                    Text(act['notes'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                              child: Text(act['category'] ?? 'General', style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                            ),
                            const SizedBox(width: 16),
                            Text('\$${(act['cost'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
                              onPressed: () async {
                                await ApiService.deleteStopActivity(act['id']);
                                _loadItinerary();
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class ItineraryViewScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onBack;

  const ItineraryViewScreen({super.key, required this.trip, required this.onBack});

  @override
  State<ItineraryViewScreen> createState() => _ItineraryViewScreenState();
}

class _ItineraryViewScreenState extends State<ItineraryViewScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? itineraryData;

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final res = await ApiService.fetchItinerary(widget.trip['id']);
      if (res['success'] == true) {
        setState(() => itineraryData = res);
      } else {
        setState(() => error = res['message'] ?? 'Failed to load itinerary.');
      }
    } catch (e) {
      setState(() => error = 'Unable to connect to server.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> stops = itineraryData?['stops'] ?? [];
    final double totalCost = (itineraryData?['total_activities_cost'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Visual Itinerary: ${widget.trip['title']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text('${widget.trip['destination']} (${widget.trip['start_date']} — ${widget.trip['end_date']})', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2563EB)),
                const SizedBox(width: 10),
                Text('Total Activities Expense: \$${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          const SizedBox(height: 28),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: stops.map((stop) {
                    final List<dynamic> activities = stop['activities'] ?? [];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${stop['city_name']}, ${stop['country']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text('${stop['start_date']} — ${stop['end_date']}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                          const SizedBox(height: 12),
                          ...activities.map((act) => ListTile(
                                dense: true,
                                title: Text(act['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('${act['time_slot']} • ${act['category']}'),
                                trailing: Text('\$${(act['cost'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
