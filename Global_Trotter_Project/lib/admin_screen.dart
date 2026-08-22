import 'package:flutter/material.dart';
import 'api_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminAnalyticsScreen({super.key, required this.user});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  bool isLoading = true;
  String? error;

  Map<String, dynamic> kpis = {'total_users': 0, 'total_trips': 0, 'total_budget': 0.0, 'total_activities': 0};
  List<dynamic> popularCities = [];
  List<dynamic> popularActivities = [];
  List<dynamic> userManagement = [];
  List<dynamic> categoryBreakdown = [];

  @override
  void initState() {
    super.initState();
    _loadAdminAnalytics();
  }

  Future<void> _loadAdminAnalytics() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final res = await ApiService.fetchAdminAnalytics(widget.user['id']);
      if (res['success'] == true) {
        setState(() {
          kpis = res['kpis'];
          popularCities = res['popular_cities'];
          popularActivities = res['popular_activities'];
          userManagement = res['user_management'];
          categoryBreakdown = res['category_breakdown'];
        });
      } else {
        setState(() => error = res['message'] ?? 'Access denied or failed to load admin stats.');
      }
    } catch (e) {
      setState(() => error = 'Unable to connect to admin API.');
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
                    const Icon(Icons.lock_outline, size: 48, color: Color(0xFFDC2626)),
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadAdminAnalytics, child: const Text('Retry')),
                  ],
                ),
              )
            : SingleChildScrollView(
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
                            Text('Platform Admin & Analytics Dashboard', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            SizedBox(height: 4),
                            Text('Monitor system performance, user engagement, and popular destination statistics.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFBFDBFE))),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_outlined, size: 18, color: Color(0xFF2563EB)),
                              SizedBox(width: 8),
                              Text('Admin Access Granted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2563EB))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // PLATFORM KPI STAT CARDS
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = (constraints.maxWidth - 48) / 4;
                        return Row(
                          children: [
                            _buildKPICard(width: width, label: 'Total Users', value: '${kpis['total_users']}', icon: Icons.people_outline, color: const Color(0xFF2563EB)),
                            const SizedBox(width: 16),
                            _buildKPICard(width: width, label: 'Trips Created', value: '${kpis['total_trips']}', icon: Icons.card_travel_outlined, color: const Color(0xFF059669)),
                            const SizedBox(width: 16),
                            _buildKPICard(width: width, label: 'Total Budget Managed', value: '\$${(kpis['total_budget'] as num).toStringAsFixed(0)}', icon: Icons.account_balance_wallet_outlined, color: const Color(0xFFD97706)),
                            const SizedBox(width: 16),
                            _buildKPICard(width: width, label: 'Scheduled Activities', value: '${kpis['total_activities']}', icon: Icons.local_activity_outlined, color: const Color(0xFF7C3AED)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // POPULAR CITIES RANKING TABLE
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Most Popular Cities (Views & Visits)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                    Text('Dynamic Ranking 🔥', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: popularCities.length,
                                  separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9)),
                                  itemBuilder: (context, index) {
                                    final city = popularCities[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: const Color(0xFFF1F5F9),
                                            child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
                                          ),
                                          const SizedBox(width: 14),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.network(city['image_url'] ?? '', width: 50, height: 40, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 40, color: const Color(0xFFE2E8F0))),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${city['name']}, ${city['country']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                Text('Cost Index: ${city['cost_index']} • \$${(city['average_cost'] as num).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text('👁️ ${city['view_count']} views', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                              Text('✈️ ${city['visit_count']} visits', style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // CATEGORY ENGAGEMENT BREAKDOWN CHARTS
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Activity Category Breakdown', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                const SizedBox(height: 20),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: categoryBreakdown.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final cat = categoryBreakdown[index];
                                    final int count = (cat['count'] as num).toInt();
                                    final double cost = (cat['total_cost'] as num).toDouble();
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(cat['category'] ?? 'Other', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                            Text('$count bookings (\$${cost.toStringAsFixed(0)})', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        LinearProgressIndicator(
                                          value: (count / 5.0).clamp(0.1, 1.0),
                                          backgroundColor: const Color(0xFFF1F5F9),
                                          color: const Color(0xFF2563EB),
                                          minHeight: 8,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // USER MANAGEMENT TABLE
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Platform User Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Text('Total Registered Users: ${userManagement.length}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Trips Created', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: userManagement.map((u) {
                                final bool isAdmin = (u['is_admin'] == 1);
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundImage: NetworkImage(u['profile_photo_url'] ?? ''),
                                            backgroundColor: const Color(0xFF2563EB),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(u['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(u['email'] ?? '')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: isAdmin ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                        child: Text(isAdmin ? 'Admin' : 'Traveler', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isAdmin ? const Color(0xFF2563EB) : const Color(0xFF475569))),
                                      ),
                                    ),
                                    DataCell(Text((u['created_at'] ?? '').toString().split(' ')[0])),
                                    DataCell(Text('${u['trip_count']} trips', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
  }

  Widget _buildKPICard({required double width, required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      width: width < 200 ? double.infinity : width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
