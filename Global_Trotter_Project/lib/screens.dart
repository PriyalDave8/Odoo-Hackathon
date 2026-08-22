import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('GlobeTrotter', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                  const SizedBox(height: 24),
                  Text(isLogin ? 'Welcome Back' : 'Create an Account', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Text(
                    isLogin ? 'Sign in to access your personal travel itineraries and plans' : 'Join GlobeTrotter to start planning multi-city journeys',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),

                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFCA5A5))),
                      child: Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!isLogin) ...[
                    const Align(alignment: Alignment.centerLeft, child: Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                    const SizedBox(height: 6),
                    TextFormField(controller: _nameController, decoration: _inputDecoration('Alex Morgan', Icons.person_outline), validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null),
                    const SizedBox(height: 16),
                  ],

                  const Align(alignment: Alignment.centerLeft, child: Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                  const SizedBox(height: 6),
                  TextFormField(controller: _emailController, decoration: _inputDecoration('name@company.com', Icons.email_outlined), validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        if (isLogin)
                          TextButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset password instructions sent.'))),
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
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8), size: 20),
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
                      child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
// CITY DETAILS MODAL DIALOG
// ==========================================
void showCityDetailsModal(BuildContext context, Map<String, dynamic> city, VoidCallback onPlanTrip) {
  final int cityId = (city['id'] as num?)?.toInt() ?? 0;
  if (cityId > 0) {
    ApiService.recordCityView(cityId);
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image & Header
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    child: Image.network(
                      city['image_url'] ?? '',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(height: 200, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image)),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                              child: Text(city['region'] ?? 'Europe', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6)),
                              child: Text('${city['popularity_score'] ?? '4.8'} ★ Rating', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${city['name']}, ${city['country']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // View/Visit count badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('👁️ ${city['view_count'] ?? 0} Views • ✈️ ${city['visit_count'] ?? 0} Trips Planned', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                        Text('Avg Cost: \$${(city['average_cost'] as num?)?.toDouble().toStringAsFixed(2) ?? '1,200.00'} (${city['cost_index'] ?? '\$\$\$'})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF059669))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(city['description'] ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4)),
                    const SizedBox(height: 20),

                    // Best Season to Visit
                    const Row(
                      children: [
                        Icon(Icons.wb_sunny_outlined, size: 18, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Text('Best Season to Visit:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 26.0),
                      child: Text(city['best_season'] ?? 'May – October (Spring & Autumn)', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                    ),
                    const SizedBox(height: 20),

                    // Top Attractions & Must-Visit Landmarks
                    const Row(
                      children: [
                        Icon(Icons.place_outlined, size: 18, color: Color(0xFF2563EB)),
                        SizedBox(width: 8),
                        Text('Top Attractions & Highlights:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (city['top_attractions'] != null && city['top_attractions'].toString().isNotEmpty)
                            ? city['top_attractions'].toString().split(',').map((att) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                      Expanded(child: Text(att.trim(), style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                                    ],
                                  ),
                                );
                              }).toList()
                            : [
                                const Text('• Eiffel Tower Summit Access'),
                                const Text('• Louvre Museum Masterpieces Walk'),
                                const Text('• Seine River Dinner Cruise'),
                              ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Expense Breakdown
                    const Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF059669)),
                        SizedBox(width: 8),
                        Text('Estimated Daily Expense Breakdown:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildExpenseChip('Hotel / Stay', '\$${(city['hotel_avg_cost'] as num?)?.toDouble().toStringAsFixed(0) ?? '150'}/night', Icons.hotel),
                        _buildExpenseChip('Meals / Dining', '\$${(city['meal_avg_cost'] as num?)?.toDouble().toStringAsFixed(0) ?? '55'}/day', Icons.restaurant),
                        _buildExpenseChip('Local Transport', '\$20/day', Icons.directions_bus),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onPlanTrip();
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('Plan Trip to ${city['name']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildExpenseChip(String label, String value, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF475569)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    ),
  );
}

// ==========================================
// 2. DASHBOARD SCREEN
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back, ${widget.user['name']} 👋', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                            const SizedBox(height: 4),
                            const Text('Your next adventure awaits. Let\'s start planning!', style: TextStyle(fontSize: 15, color: Color(0xFF64748B))),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: widget.onNavigateToCreateTrip,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Plan New Trip', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = (constraints.maxWidth - 32) / 3;
                        return Row(
                          children: [
                            _buildKPICard(width: width, label: 'Total Trips:', value: '${stats['total_trips']}', icon: Icons.flight_outlined),
                            const SizedBox(width: 16),
                            _buildKPICard(width: width, label: 'Active / Upcoming:', value: '${stats['active_trips']}', icon: Icons.calendar_today_outlined),
                            _buildBudgetKPICard(width: width, totalBudget: (num.tryParse(stats['total_budget']?.toString() ?? '0') ?? 0.0).toDouble()),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('My Recent Trips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                    TextButton(onPressed: widget.onNavigateToMyTrips, child: const Text('View all', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600))),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (trips.isEmpty)
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('No trips planned yet.', style: TextStyle(color: Color(0xFF94A3B8)))))
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: trips.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) => _buildMockupTripCard(Map<String, dynamic>.from(trips[index])),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Recommended Cities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                        Text('Ranked by views & visits', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)), child: const Text('Top Ranked 🔥', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)))),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: destinations.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                                  itemBuilder: (context, index) => _buildMockupCityCard(Map<String, dynamic>.from(destinations[index])),
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

  Widget _buildKPICard({required double width, required String label, required String value, required IconData icon}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFCBD5E1))), child: Icon(icon, color: const Color(0xFF475569), size: 20)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFCBD5E1))), child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF475569), size: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Budget:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('\$${totalBudget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupTripCard(Map<String, dynamic> trip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(trip['cover_image_url'] ?? '', width: 100, height: 80, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 100, height: 80, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text('Destinations: ${trip['destination']}', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                const SizedBox(height: 2),
                Text('Dates: ${trip['start_date']} to ${trip['end_date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          OutlinedButton(onPressed: () => widget.onBuildItinerary(trip), child: const Text('View Plan')),
        ],
      ),
    );
  }

  Widget _buildMockupCityCard(Map<String, dynamic> dest) {
    return InkWell(
      onTap: () => showCityDetailsModal(context, dest, widget.onNavigateToCreateTrip),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(dest['image_url'] ?? '', width: 80, height: 65, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 65, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dest['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                  Text(dest['country'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Text('👁️ ${dest['view_count']} views • ✈️ ${dest['visit_count']} visits', style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text('\$${((dest['average_cost'] is num) ? (dest['average_cost'] as num).toDouble() : (double.tryParse(dest['average_cost']?.toString() ?? '0') ?? 0.0)).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
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
  final _transportController = TextEditingController(text: '650');
  final _hotelController = TextEditingController(text: '1100');
  final _mealController = TextEditingController(text: '550');
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();

  String _selectedTravelStyle = 'Cultural Exploration 🏛️';
  String _selectedTransportType = 'Flight ✈️';
  String _selectedAccommodation = 'Boutique Hotel 🏨';
  String _selectedGroupSize = 'Couple (2)';
  String _selectedCurrency = 'INR (₹)';

  final List<String> _availablePlaces = [
    'Paris, France 🇫🇷',
    'Rome, Italy 🇮🇹',
    'Tokyo, Japan 🇯🇵',
    'Kyoto, Japan 🇯🇵',
    'Zurich, Switzerland 🇨🇭',
    'Lucerne, Switzerland 🇨🇭',
    'Bali, Indonesia 🇮🇩',
    'Reykjavik, Iceland 🇮🇸',
    'Barcelona, Spain 🇪🇸',
    'Prague, Czech Republic 🇨🇿',
    'Vienna, Austria 🇦🇹',
    'Seoul, South Korea 🇰🇷',
    'Bangkok, Thailand 🇹🇭',
    'Santorini, Greece 🇬🇷',
    'London, UK 🇬🇧',
    'New York, USA 🇺🇸',
    'Sydney, Australia 🇦🇺',
    'Dubai, UAE 🇦🇪',
    'Cape Town, South Africa 🇿A',
    'Amsterdam, Netherlands 🇳🇱'
  ];

  final Set<String> _selectedPlaces = {'Paris, France 🇫🇷', 'Rome, Italy 🇮🇹'};
  bool isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _budgetController.dispose();
    _transportController.dispose();
    _hotelController.dispose();
    _mealController.dispose();
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
      transportCost: double.tryParse(_transportController.text) ?? 0.0,
      hotelCost: double.tryParse(_hotelController.text) ?? 0.0,
      mealCost: double.tryParse(_mealController.text) ?? 0.0,
      travelStyle: _selectedTravelStyle,
      transportType: _selectedTransportType,
      accommodationType: _selectedAccommodation,
      groupSize: _selectedGroupSize,
      currency: _selectedCurrency,
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
          constraints: const BoxConstraints(maxWidth: 750),
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
                    const Row(children: [Icon(Icons.add_circle_outline, color: Color(0xFF2563EB), size: 28), SizedBox(width: 12), Text('Plan New Trip Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))]),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)), onPressed: widget.onCancel),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('1. Basic Trip Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                const SizedBox(height: 12),
                TextFormField(controller: _titleController, decoration: _inputDecoration('e.g. Euro Summer Getaway', Icons.card_travel_outlined), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _destinationController, decoration: _inputDecoration('e.g. Paris & Rome', Icons.location_on_outlined), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _startDateController, decoration: _inputDecoration('Start Date', Icons.calendar_today))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _endDateController, decoration: _inputDecoration('End Date', Icons.event))),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('2. Travel Style & Preferences', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Travel Style / Vibe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildDropdown(['Cultural Exploration 🏛️', 'Relaxing Beach Escape 🏖️', 'Food & Culinary Tour 🍣', 'High Adventure 🏔️', 'Wildlife Safari 🦁', 'Luxury Travel 👑'], _selectedTravelStyle, (v) => setState(() => _selectedTravelStyle = v!)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Preferred Transport', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildDropdown(['Flight ✈️', 'High-Speed Train 🚆', 'Rental Car 🚗', 'Cruise Ship 🚢', 'Bus 🚌'], _selectedTransportType, (v) => setState(() => _selectedTransportType = v!)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Accommodation Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildDropdown(['Boutique Hotel 🏨', 'Luxury Villa 🏝️', 'Alpine Chalet ❄️', 'Hostel 🎒', 'Apartment 🏙️'], _selectedAccommodation, (v) => setState(() => _selectedAccommodation = v!)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Group Size', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildDropdown(['Solo Traveler (1)', 'Couple (2)', 'Small Group (3-5)', 'Large Group / Family (6+)'], _selectedGroupSize, (v) => setState(() => _selectedGroupSize = v!)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('3. Budget & Expense Allocation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 2, child: TextFormField(controller: _budgetController, keyboardType: TextInputType.number, decoration: _inputDecoration('Planned Budget', Icons.attach_money))),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)', 'JPY (¥)'], _selectedCurrency, (v) => setState(() => _selectedCurrency = v!)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _transportController, keyboardType: TextInputType.number, decoration: _inputDecoration('Transport Cost', Icons.directions_bus))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _hotelController, keyboardType: TextInputType.number, decoration: _inputDecoration('Hotel / Stay Cost', Icons.hotel))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _mealController, keyboardType: TextInputType.number, decoration: _inputDecoration('Meal Cost', Icons.restaurant))),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(controller: _descriptionController, maxLines: 2, decoration: _inputDecoration('Trip Description & Notes (e.g. Dietary preferences, flight numbers)', Icons.notes)),
                const SizedBox(height: 16),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('4. Customise Included Places & City Stops 📍', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    Text('${_selectedPlaces.length} places selected', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Select or unselect which destinations you want to include in your customized trip itinerary:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availablePlaces.map((place) {
                    final bool isSelected = _selectedPlaces.contains(place);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(place, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569))),
                      selectedColor: const Color(0xFFEFF6FF),
                      checkmarkColor: const Color(0xFF2563EB),
                      backgroundColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0))),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedPlaces.add(place);
                          } else {
                            if (_selectedPlaces.length > 1) {
                              _selectedPlaces.remove(place);
                            }
                          }
                          _destinationController.text = _selectedPlaces.map((p) => p.split(',')[0].trim()).join(' & ');
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: widget.onCancel, child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: isSubmitting ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)), child: const Text('Save & Plan Itinerary')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String currentVal, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentVal,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
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
  List<dynamic> trips = [];
  String selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => isLoading = true);
    final res = await ApiService.fetchTrips(widget.user['id']);
    if (res['success'] == true) setState(() => trips = res['trips']);
    setState(() => isLoading = false);
  }

  void _showShareDialog(Map<String, dynamic> trip) {
    final String shareUrl = 'http://localhost:8090/#/share?token=${trip['share_token'] ?? 'share_demo'}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.share, color: Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Expanded(child: Text('Share Trip: ${trip['title']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share this public itinerary link with friends or allow another user to copy it:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: shareUrl),
                readOnly: true,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFF2563EB)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareUrl));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Public trip link copied to clipboard!')));
                    },
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Share on Social Media:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp share link generated!'))),
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Twitter/X share link generated!'))),
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Twitter / X'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000000), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _copyTripToAccount(Map<String, dynamic> trip) async {
    final res = await ApiService.copyTrip(trip['id'], widget.user['id']);
    if (res['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Trip copied!')));
        _loadTrips();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrips = trips.where((t) {
      if (selectedStatusFilter == 'All') return true;
      final String status = (t['status'] ?? 'Planned').toString();
      if (selectedStatusFilter == 'Upcoming') return status == 'Planned' || status == 'Confirmed';
      if (selectedStatusFilter == 'Ongoing') return status == 'Active' || status == 'Ongoing';
      if (selectedStatusFilter == 'Completed') return status == 'Completed';
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
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
                  Text('Manage, share, build, customize stops, and copy multi-city trip plans.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(onPressed: widget.onCreateNewTrip, icon: const Icon(Icons.add), label: const Text('Plan New Trip'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),

          // TRIP STATUS FILTERS
          Row(
            children: ['All', 'Upcoming', 'Ongoing', 'Completed'].map((filter) {
              final isSelected = selectedStatusFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: ChoiceChip(
                  label: Text('$filter Trips'),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 13),
                  onSelected: (sel) {
                    if (sel) setState(() => selectedStatusFilter = filter);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredTrips.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No trips match the selected filter.', style: TextStyle(color: Color(0xFF94A3B8)))))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final double cardWidth = (constraints.maxWidth - 24) / 2;
                        return Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: filteredTrips.map((t) {
                            final trip = Map<String, dynamic>.from(t);
                            return Container(
                              width: cardWidth < 380 ? double.infinity : cardWidth,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(trip['cover_image_url'] ?? '', height: 130, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 130, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image))),
                                  Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(trip['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 4),
                                        Text('${trip['destination']} (${trip['start_date']} — ${trip['end_date']})', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            Expanded(child: OutlinedButton.icon(onPressed: () => widget.onBuildItinerary(trip), icon: const Icon(Icons.tune_outlined, size: 14), label: const Text('Customize'))),
                                            const SizedBox(width: 6),
                                            Expanded(child: ElevatedButton.icon(onPressed: () => widget.onViewItinerary(trip), icon: const Icon(Icons.visibility, size: 14), label: const Text('View Plan'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white))),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(child: OutlinedButton.icon(onPressed: () => _showShareDialog(trip), icon: const Icon(Icons.share, size: 14), label: const Text('Share'))),
                                            const SizedBox(width: 6),
                                            Expanded(child: OutlinedButton.icon(onPressed: () => _copyTripToAccount(trip), icon: const Icon(Icons.copy, size: 14), label: const Text('Copy Trip'))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. ITINERARY BUILDER & CUSTOMIZE STOPS
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
  Set<int> excludedStopIds = {};

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

  void _toggleStopInclusion(int stopId) {
    setState(() {
      if (excludedStopIds.contains(stopId)) {
        excludedStopIds.remove(stopId);
      } else {
        excludedStopIds.add(stopId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? trip = itineraryData?['trip'];
    final List<dynamic> stops = itineraryData?['stops'] ?? [];

    double includedActivitiesCost = 0.0;
    for (var stop in stops) {
      final int stopId = (stop['id'] as num).toInt();
      if (!excludedStopIds.contains(stopId)) {
        final List<dynamic> activities = stop['activities'] ?? [];
        for (var a in activities) {
          includedActivitiesCost += (a['cost'] as num).toDouble();
        }
      }
    }

    final double plannedBudget = (trip?['budget'] as num?)?.toDouble() ?? 2500.0;
    final double transportCost = (trip?['transport_cost'] as num?)?.toDouble() ?? 650.0;
    final double hotelCost = (trip?['hotel_cost'] as num?)?.toDouble() ?? 1100.0;
    final double mealCost = (trip?['meal_cost'] as num?)?.toDouble() ?? 550.0;

    final double totalEstimatedCost = transportCost + hotelCost + mealCost + includedActivitiesCost;
    final bool isOverBudget = totalEstimatedCost > plannedBudget;
    final double costPerDay = totalEstimatedCost / 10.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customize Itinerary: ${widget.trip['title']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const Text('Select which city stops to include or exclude to customize your budget & timeline.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (isOverBudget) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFCA5A5))),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Over-Budget Alert!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF991B1B))),
                        Text('Total estimated expenses (\$${totalEstimatedCost.toStringAsFixed(2)}) exceed your planned budget (\$${plannedBudget.toStringAsFixed(2)}) by \$${(totalEstimatedCost - plannedBudget).toStringAsFixed(2)}. Try excluding optional city stops below to stay under budget.', style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Customized Budget & Expense Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
                      child: Text('Cost per day: \$${costPerDay.toStringAsFixed(2)}/day', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildExpenseBar('Transport Expenses', transportCost, totalEstimatedCost, const Color(0xFF2563EB)),
                const SizedBox(height: 12),
                _buildExpenseBar('Hotel / Accommodation', hotelCost, totalEstimatedCost, const Color(0xFF059669)),
                const SizedBox(height: 12),
                _buildExpenseBar('Included Activities & Excursions', includedActivitiesCost, totalEstimatedCost, const Color(0xFFD97706)),
                const SizedBox(height: 12),
                _buildExpenseBar('Meals & Dining', mealCost, totalEstimatedCost, const Color(0xFF7C3AED)),
                const SizedBox(height: 18),

                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Estimated Cost: \$${totalEstimatedCost.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isOverBudget ? const Color(0xFFDC2626) : const Color(0xFF0F172A))),
                    Text('Planned Budget: \$${plannedBudget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Customize City Stops (Include / Exclude)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text('${stops.length - excludedStopIds.length} of ${stops.length} Stops Included', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 16),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stops.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    final int stopId = (stop['id'] as num).toInt();
                    final bool isExcluded = excludedStopIds.contains(stopId);

                    return Opacity(
                      opacity: isExcluded ? 0.5 : 1.0,
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isExcluded ? const Color(0xFFCBD5E1) : const Color(0xFF2563EB), width: isExcluded ? 1 : 1.5)),
                        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isExcluded ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0))),
                        backgroundColor: Colors.white,
                        collapsedBackgroundColor: Colors.white,
                        initiallyExpanded: true,
                        leading: Switch(
                          value: !isExcluded,
                          activeTrackColor: const Color(0xFF2563EB),
                          onChanged: (val) => _toggleStopInclusion(stopId),
                        ),
                        title: Row(
                          children: [
                            Text('Stop ${index + 1}: ${stop['city_name']}, ${stop['country']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isExcluded ? const Color(0xFF64748B) : const Color(0xFF0F172A), decoration: isExcluded ? TextDecoration.lineThrough : null)),
                            const SizedBox(width: 10),
                            if (isExcluded)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                child: const Text('EXCLUDED FROM PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              ),
                          ],
                        ),
                        subtitle: Text('Dates: ${stop['start_date']} — ${stop['end_date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: (stop['activities'] as List? ?? []).map<Widget>((act) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 16, color: Color(0xFF64748B)),
                                      const SizedBox(width: 8),
                                      Text(act['time_slot'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 14),
                                      Expanded(child: Text(act['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                                      Text('\$${(act['cost'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildExpenseBar(String label, double amount, double total, Color color) {
    final double pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            Text('\$${amount.toStringAsFixed(2)} (${(pct * 100).toStringAsFixed(0)}%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: const Color(0xFFF1F5F9),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

// ==========================================
// 6. ITINERARY VIEW SCREEN
// ==========================================
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
  int selectedViewTab = 0;
  Set<int> excludedStopIds = {};

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

  void _toggleStopInclusion(int stopId) {
    setState(() {
      if (excludedStopIds.contains(stopId)) {
        excludedStopIds.remove(stopId);
      } else {
        excludedStopIds.add(stopId);
      }
    });
  }

  void _showReviewDialog(String destinationName) {
    int selectedRating = 5;
    final titleController = TextEditingController(text: 'Amazing Experience in $destinationName!');
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Review & Rate: $destinationName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rating:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          icon: Icon(star <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFD97706), size: 30),
                          onPressed: () => setModalState(() => selectedRating = star),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    const Text('Review Headline:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Feedback & Comments:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe what you loved about this itinerary and destination...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty || commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out review title and comment.')));
                            return;
                          }
                          setModalState(() => isSubmitting = true);
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final res = await ApiService.addReview(
                            userId: widget.trip['user_id'] ?? 1,
                            destinationName: destinationName,
                            rating: selectedRating,
                            title: titleController.text.trim(),
                            comment: commentController.text.trim(),
                          );
                          navigator.pop();
                          if (res['success'] == true) {
                            messenger.showSnackBar(const SnackBar(content: Text('Review & feedback saved!')));
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Submit Review'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> trip = itineraryData?['trip'] ?? widget.trip;
    final List<dynamic> stops = itineraryData?['stops'] ?? [];

    double includedActivitiesCost = 0.0;
    for (var stop in stops) {
      final int stopId = (stop['id'] as num).toInt();
      if (!excludedStopIds.contains(stopId)) {
        final List<dynamic> activities = stop['activities'] ?? [];
        for (var a in activities) {
          includedActivitiesCost += (a['cost'] as num).toDouble();
        }
      }
    }

    final double plannedBudget = (trip['budget'] as num?)?.toDouble() ?? 2500.0;
    final double transportCost = (trip['transport_cost'] as num?)?.toDouble() ?? 650.0;
    final double hotelCost = (trip['hotel_cost'] as num?)?.toDouble() ?? 1100.0;
    final double mealCost = (trip['meal_cost'] as num?)?.toDouble() ?? 550.0;
    final double totalEstimatedCost = transportCost + hotelCost + mealCost + includedActivitiesCost;
    final double dailyCost = totalEstimatedCost / 10.0;

    final String coverUrl = (trip['cover_image_url'] != null && trip['cover_image_url'].toString().isNotEmpty)
        ? trip['cover_image_url']
        : 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
              const SizedBox(width: 8),
              const Text('Visual Itinerary & Plan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showReviewDialog(trip['destination'] ?? 'Paris & Rome'),
                icon: const Icon(Icons.star_rate_rounded, size: 18),
                label: const Text('⭐ Review & Feedback'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  final String link = 'http://localhost:8090/#/share?token=${trip['share_token']}';
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Public share link copied to clipboard!')));
                },
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share Plan'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // HERO TRIP BANNER CARD
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(height: 220, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image)),
                    ),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.75)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                                child: Text(trip['status'] ?? 'Confirmed', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                child: Text(trip['travel_style'] ?? 'Cultural Exploration 🏛️', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                child: Text(trip['transport_type'] ?? 'Flight ✈️', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trip['title'] ?? '',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(trip['destination'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 16),
                              const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text('${trip['start_date']} — ${trip['end_date']}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                              const SizedBox(width: 16),
                              const Icon(Icons.people, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(trip['group_size'] ?? 'Couple (2)', style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricSummary('Total Cost', '${(trip['currency'] != null && (trip['currency'].toString().contains('INR') || trip['currency'].toString().contains('₹'))) ? '₹' : (trip['currency'] != null && (trip['currency'].toString().contains('EUR') || trip['currency'].toString().contains('€'))) ? '€' : (trip['currency'] != null && (trip['currency'].toString().contains('GBP') || trip['currency'].toString().contains('£'))) ? '£' : (trip['currency'] != null && (trip['currency'].toString().contains('JPY') || trip['currency'].toString().contains('¥'))) ? '¥' : '\$'}${totalEstimatedCost.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined, const Color(0xFF2563EB)),
                      _buildMetricSummary('Planned Budget', '${(trip['currency'] != null && (trip['currency'].toString().contains('INR') || trip['currency'].toString().contains('₹'))) ? '₹' : (trip['currency'] != null && (trip['currency'].toString().contains('EUR') || trip['currency'].toString().contains('€'))) ? '€' : (trip['currency'] != null && (trip['currency'].toString().contains('GBP') || trip['currency'].toString().contains('£'))) ? '£' : (trip['currency'] != null && (trip['currency'].toString().contains('JPY') || trip['currency'].toString().contains('¥'))) ? '¥' : '\$'}${plannedBudget.toStringAsFixed(2)}', Icons.flag_outlined, const Color(0xFF059669)),
                      _buildMetricSummary('Daily Average', '${(trip['currency'] != null && (trip['currency'].toString().contains('INR') || trip['currency'].toString().contains('₹'))) ? '₹' : (trip['currency'] != null && (trip['currency'].toString().contains('EUR') || trip['currency'].toString().contains('€'))) ? '€' : (trip['currency'] != null && (trip['currency'].toString().contains('GBP') || trip['currency'].toString().contains('£'))) ? '£' : (trip['currency'] != null && (trip['currency'].toString().contains('JPY') || trip['currency'].toString().contains('¥'))) ? '¥' : '\$'}${dailyCost.toStringAsFixed(2)}/day', Icons.today, const Color(0xFFD97706)),
                      _buildMetricSummary('Included Cities', '${stops.length - excludedStopIds.length} of ${stops.length} Cities', Icons.location_city, const Color(0xFF7C3AED)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // TABBED VIEW SWITCHER & CUSTOMIZATION BAR
          Row(
            children: [
              ChoiceChip(
                label: const Text('📅 Day-Wise Calendar Timeline'),
                selected: selectedViewTab == 0,
                selectedColor: const Color(0xFF2563EB),
                labelStyle: TextStyle(color: selectedViewTab == 0 ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.bold),
                onSelected: (sel) {
                  if (sel) setState(() => selectedViewTab = 0);
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('🏙️ City-Grouped Itinerary'),
                selected: selectedViewTab == 1,
                selectedColor: const Color(0xFF2563EB),
                labelStyle: TextStyle(color: selectedViewTab == 1 ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.bold),
                onSelected: (sel) {
                  if (sel) setState(() => selectedViewTab = 1);
                },
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.tune_outlined, size: 16, color: Color(0xFF2563EB)),
                    SizedBox(width: 6),
                    Text('Toggle switches to include / exclude city stops', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF2563EB))))
          else if (selectedViewTab == 0)
            _buildDayWiseTimeline(stops)
          else
            _buildCityGroupedOverview(stops),
        ],
      ),
    );
  }

  Widget _buildMetricSummary(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }

  Widget _buildDayWiseTimeline(List<dynamic> stops) {
    int dayCounter = 1;
    final List<Widget> dayCards = [];

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final int stopId = (stop['id'] as num).toInt();
      final bool isExcluded = excludedStopIds.contains(stopId);
      final List<dynamic> activities = stop['activities'] ?? [];

      dayCards.add(
        Opacity(
          opacity: isExcluded ? 0.45 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isExcluded ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Switch(
                        value: !isExcluded,
                        activeTrackColor: const Color(0xFF2563EB),
                        onChanged: (val) => _toggleStopInclusion(stopId),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: isExcluded ? const Color(0xFF94A3B8) : const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                        child: Text('City Stop ${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Text('${stop['city_name']}, ${stop['country']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), decoration: isExcluded ? TextDecoration.lineThrough : null)),
                      if (isExcluded) ...[
                        const SizedBox(width: 10),
                        const Text('(Excluded)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                      ],
                      const Spacer(),
                      Text('Dates: ${stop['start_date']} — ${stop['end_date']}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: activities.isEmpty
                      ? const Text('No activities scheduled for this city stop.', style: TextStyle(color: Color(0xFF94A3B8)))
                      : Column(
                          children: activities.map<Widget>((act) {
                            final currentDay = dayCounter++;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    child: Text('D$currentDay', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                  ),
                                  const SizedBox(width: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFCBD5E1))),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.schedule, size: 14, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text(act['time_slot'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(act['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                                        if (act['notes'] != null && act['notes'].toString().isNotEmpty)
                                          Text(act['notes'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                    child: Text(act['category'] ?? 'Sightseeing', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                  ),
                                  const SizedBox(width: 16),
                                  Text('\$${(act['cost'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(children: dayCards);
  }

  Widget _buildCityGroupedOverview(List<dynamic> stops) {
    return Column(
      children: stops.map((stop) {
        final int stopId = (stop['id'] as num).toInt();
        final bool isExcluded = excludedStopIds.contains(stopId);
        final List<dynamic> activities = stop['activities'] ?? [];

        double stopTotal = 0.0;
        for (var a in activities) {
          stopTotal += (a['cost'] as num).toDouble();
        }

        return Opacity(
          opacity: isExcluded ? 0.45 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isExcluded ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Switch(
                        value: !isExcluded,
                        activeTrackColor: const Color(0xFF2563EB),
                        onChanged: (val) => _toggleStopInclusion(stopId),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_city, color: Color(0xFF2563EB), size: 22),
                      const SizedBox(width: 12),
                      Text('${stop['city_name']}, ${stop['country']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), decoration: isExcluded ? TextDecoration.lineThrough : null)),
                      const Spacer(),
                      Text('Activities Total: \$${stopTotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: isExcluded ? const Color(0xFF94A3B8) : const Color(0xFF059669), fontSize: 14)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (stop['notes'] != null && stop['notes'].toString().isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.hotel_outlined, size: 16, color: Color(0xFFD97706)),
                              const SizedBox(width: 8),
                              Text('Accommodation / Notes: ${stop['notes']}', style: const TextStyle(fontSize: 12, color: Color(0xFF92400E))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ...activities.map((act) {
                        return ListTile(
                          dense: true,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.star_outline, size: 16, color: Color(0xFF2563EB)),
                          ),
                          title: Text(act['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('${act['time_slot']} • ${act['category']}'),
                          trailing: Text('\$${(act['cost'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
  String selectedSort = 'popular';

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    setState(() => isLoading = true);
    final res = await ApiService.searchCities(query: query, region: selectedRegion, sort: selectedSort);
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
          const Text('Cities automatically alter rank based on maximum views and trip visits.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
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
                    items: ['All', 'Europe', 'Asia', 'Americas', 'Africa', 'Oceania', 'Middle East'].map((r) => DropdownMenuItem(value: r, child: Text('Region: $r'))).toList(),
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
    return InkWell(
      onTap: () => showCityDetailsModal(context, city, () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plan trip to ${city['name']} selected!')))),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(city['image_url'] ?? '', height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 150, color: const Color(0xFFE2E8F0), child: const Icon(Icons.image))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${city['name']}, ${city['country']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                      Text('${city['popularity_score']} ★', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('👁️ ${city['view_count']} views • ✈️ ${city['visit_count']} visits', style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
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
          const SizedBox(height: 24),
          TextField(
            onChanged: (v) {
              query = v;
              _fetchActivities();
            },
            decoration: InputDecoration(
              hintText: 'Search activities...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 28),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final act = activities[index];
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(act['title'] ?? ''),
                        subtitle: Text('${act['category']} • \$${act['cost']}'),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
