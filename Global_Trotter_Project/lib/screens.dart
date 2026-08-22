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
      setState(() => errorMessage = 'Connection error ($e). Please ensure backend API is running.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(36.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Blue Logo Icon Badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'GlobeTrotter',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    isLogin ? 'Welcome Back' : 'Create an Account',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLogin
                        ? 'Sign in to access your personal travel itineraries and plans'
                        : 'Join GlobeTrotter to start planning multi-city journeys',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),

                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!isLogin) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Alex Morgan', Icons.person_outline),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('name@company.com', Icons.email_outlined),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        if (isLogin)
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset password instructions sent.')));
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: const Text('Forgot Password?', style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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
// 2. DASHBOARD SCREEN (Pixel-Perfect Mockup Match)
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
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Your next adventure awaits. Let\'s start planning!',
                              style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: widget.onNavigateToCreateTrip,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Plan New Trip', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // 3 KPI Statistic Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = (constraints.maxWidth - 32) / 3;
                        return Row(
                          children: [
                            _buildKPICard(
                              width: width,
                              label: 'Total Trips:',
                              value: '${stats['total_trips']}',
                              icon: Icons.flight_outlined,
                            ),
                            const SizedBox(width: 16),
                            _buildKPICard(
                              width: width,
                              label: 'Active / Upcoming:',
                              value: '${stats['active_trips']}',
                              icon: Icons.calendar_today_outlined,
                            ),
                            _buildBudgetKPICard(
                              width: width,
                              totalBudget: (stats['total_budget'] as num).toDouble(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // Main Content Split Layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Section: My Recent Trips
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Text('Filter', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                                              Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF475569)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextButton(
                                          onPressed: widget.onNavigateToMyTrips,
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                          child: const Text('View all', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (trips.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const Text('No trips planned yet.', style: TextStyle(color: Color(0xFF94A3B8))),
                                          const SizedBox(height: 10),
                                          ElevatedButton(onPressed: widget.onNavigateToCreateTrip, child: const Text('Plan New Trip')),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: trips.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final trip = Map<String, dynamic>.from(trips[index]);
                                      return _buildMockupTripCard(trip);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right Section: Recommended Cities
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Recommended Cities',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                          child: const Row(
                                            children: [
                                              Text('All', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                              Icon(Icons.keyboard_arrow_down, size: 14),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: destinations.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                    final dest = destinations[index];
                                    return _buildMockupCityCard(dest);
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

  Widget _buildKPICard({
    required double width,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Icon(icon, color: const Color(0xFF475569), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetKPICard({required double width, required double totalBudget}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF475569), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Budget:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('\$${totalBudget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Spent: \$0.00 | Planned: \$${totalBudget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupTripCard(Map<String, dynamic> trip) {
    final String coverUrl = (trip['cover_image_url'] != null && trip['cover_image_url'].toString().isNotEmpty)
        ? trip['cover_image_url']
        : 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              coverUrl,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 100, height: 80, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['title'] ?? 'Untitled Trip',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${trip['destination']}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dates: ${trip['start_date']} to ${trip['end_date']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Status: ${trip['status'] ?? 'Confirmed'}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              OutlinedButton(
                onPressed: () => widget.onBuildItinerary(trip),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('View Details', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
              ),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: () => widget.onBuildItinerary(trip),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Edit Trip', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockupCityCard(Map<String, dynamic> dest) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              dest['image_url'] ?? '',
              width: 80,
              height: 65,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 65, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dest['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  dest['country'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Estimated Budget',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Text(
            '\$${(dest['average_cost'] as num).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
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

  const CreateTripScreen({super.key, required this.user, required this.onTripCreated, required this.onCancel});

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
    setState(() => isSubmitting = true);
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
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
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

                const Text('Trip Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(controller: _titleController, decoration: _inputDecoration('e.g. Euro Summer Getaway', Icons.card_travel_outlined), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                const SizedBox(height: 16),

                const Text('Primary Destination(s) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(controller: _destinationController, decoration: _inputDecoration('e.g. Paris & Rome', Icons.location_on_outlined), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
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
                TextFormField(controller: _descriptionController, maxLines: 3, decoration: _inputDecoration('Describe your trip goals...', Icons.notes_outlined)),
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

  const MyTripsScreen({super.key, required this.user, required this.onBuildItinerary, required this.onViewItinerary, required this.onCreateNewTrip});

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
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      final res = await ApiService.deleteTrip(tripId);
      if (res['success'] == true) _loadTrips();
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
                  Text('My Travel Itineraries', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Access, build, and review all your planned multi-city journeys.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: widget.onCreateNewTrip,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Plan New Trip', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
              ),
            ],
          ),
          const SizedBox(height: 24),

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
          else if (filteredTrips.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Column(
                children: [
                  Icon(Icons.flight_takeoff, size: 48, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 16),
                  Text('No trips found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  children: filteredTrips.map((t) => _buildTripCard(cardWidth, Map<String, dynamic>.from(t))).toList(),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(coverUrl, height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 140, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image_not_supported))),
              Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(trip['status'] ?? 'Planned', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF2563EB)), const SizedBox(width: 4), Text(trip['destination'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)), const SizedBox(width: 4), Text('${trip['start_date']} — ${trip['end_date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))]),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${(trip['budget'] as num).toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('${trip['stop_count'] ?? 0} Cities', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => widget.onBuildItinerary(trip), child: const Text('Build Itinerary'))),
                    const SizedBox(width: 8),
                    Expanded(child: ElevatedButton(onPressed: () => widget.onViewItinerary(trip), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white), child: const Text('View Plan'))),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)), onPressed: () => _deleteTrip(trip['id'])),
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
  Map<String, dynamic>? itineraryData;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final res = await ApiService.fetchItinerary(widget.trip['id']);
    if (res['success'] == true) setState(() => itineraryData = res);
    setState(() => isLoading = false);
  }

  void _showAddStopDialog() {
    final cityController = TextEditingController();
    final countryController = TextEditingController();
    final startDateController = TextEditingController(text: widget.trip['start_date'] ?? '2026-09-10');
    final endDateController = TextEditingController(text: widget.trip['end_date'] ?? '2026-09-15');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Travel Stop (City)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City Name')),
            TextField(controller: countryController, decoration: const InputDecoration(labelText: 'Country')),
            TextField(controller: startDateController, decoration: const InputDecoration(labelText: 'Start Date')),
            TextField(controller: endDateController, decoration: const InputDecoration(labelText: 'End Date')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (cityController.text.isEmpty) return;
              await ApiService.addTripStop(
                tripId: widget.trip['id'],
                cityName: cityController.text.trim(),
                country: countryController.text.trim(),
                startDate: startDateController.text.trim(),
                endDate: endDateController.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
              _load();
            },
            child: const Text('Add Stop'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stops = itineraryData?['stops'] ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
              Text('Itinerary Builder: ${widget.trip['title']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(onPressed: _showAddStopDialog, icon: const Icon(Icons.add), label: const Text('Add City Stop')),
            ],
          ),
          const SizedBox(height: 20),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stops.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stop ${index + 1}: ${stop['city_name']}, ${stop['country']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...(stop['activities'] as List? ?? []).map((act) => ListTile(
                                  title: Text(act['title'] ?? ''),
                                  subtitle: Text('${act['time_slot']} • ${act['category']}'),
                                  trailing: Text('\$${act['cost']}'),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class ItineraryViewScreen extends StatelessWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onBack;

  const ItineraryViewScreen({super.key, required this.trip, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
            Text('Itinerary Timeline: ${trip['title']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Text('Viewing day-wise and city-grouped itinerary for ${trip['destination']}.'),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. CITY SEARCH SCREEN
// ==========================================
class CitySearchScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const CitySearchScreen({super.key, required this.user});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  bool isLoading = true;
  List<dynamic> cities = [];
  String query = '';
  String selectedRegion = 'All';

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    setState(() => isLoading = true);
    final res = await ApiService.searchCities(query: query, region: selectedRegion);
    if (res['success'] == true) {
      setState(() => cities = res['cities']);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Explore & Search Cities', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Discover global destinations, filter by region, view cost index & popularity ratings.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) {
                    query = v;
                    _fetchCities();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search city name or country...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRegion,
                    items: ['All', 'Europe', 'Asia', 'Americas'].map((r) => DropdownMenuItem(value: r, child: Text('Region: $r'))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => selectedRegion = v);
                        _fetchCities();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF2563EB))))
          else if (cities.isEmpty)
            const Center(child: Text('No cities match your search filter.', style: TextStyle(color: Color(0xFF94A3B8))))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = (constraints.maxWidth - 32) / 3;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: cities.map((c) => _buildCityCard(width < 320 ? double.infinity : width, Map<String, dynamic>.from(c))).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCityCard(double width, Map<String, dynamic> city) {
    return Container(
      width: width,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            city['image_url'] ?? '',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(height: 150, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${city['name']}, ${city['country']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                      child: Text('${city['popularity_score']} ★', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Cost Index: ${city['cost_index']} • Avg \$${(city['average_cost'] as num).toInt()}/trip', style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(city['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. ACTIVITY SEARCH SCREEN
// ==========================================
class ActivitySearchScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ActivitySearchScreen({super.key, required this.user});

  @override
  State<ActivitySearchScreen> createState() => _ActivitySearchScreenState();
}

class _ActivitySearchScreenState extends State<ActivitySearchScreen> {
  bool isLoading = true;
  List<dynamic> activities = [];
  String query = '';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() => isLoading = true);
    final res = await ApiService.searchActivities(query: query, category: selectedCategory);
    if (res['success'] == true) {
      setState(() => activities = res['activities']);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Search Things To Do & Activities', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Enrich your trip itineraries with top sightseeing, culture, food tours, and adventures.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 24),

          TextField(
            onChanged: (v) {
              query = v;
              _fetchActivities();
            },
            decoration: InputDecoration(
              hintText: 'Search activities by title, keyword, or city...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: ['All', 'Sightseeing', 'Food & Drink', 'Adventure', 'Culture'].map((cat) {
              final bool isSel = selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSel,
                selectedColor: const Color(0xFF2563EB),
                labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.w600),
                onSelected: (sel) {
                  if (sel) {
                    setState(() => selectedCategory = cat);
                    _fetchActivities();
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF2563EB))))
          else if (activities.isEmpty)
            const Center(child: Text('No activities found.', style: TextStyle(color: Color(0xFF94A3B8))))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = (constraints.maxWidth - 24) / 2;
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: activities.map((a) => _buildActivityCard(width < 360 ? double.infinity : width, Map<String, dynamic>.from(a))).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(double width, Map<String, dynamic> act) {
    return Container(
      width: width,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Image.network(
            act['image_url'] ?? '',
            width: 140,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(width: 140, height: 120, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                        child: Text(act['category'] ?? 'Sightseeing', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      ),
                      Text('\$${(act['cost'] as num).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(act['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text('Duration: ${act['duration']} • ${act['city_name'] ?? ''}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Text(act['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
