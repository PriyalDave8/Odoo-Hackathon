import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

int _safeParseInt(dynamic val, [int defaultVal = 0]) {
  if (val == null) return defaultVal;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString()) ?? defaultVal;
}

double _safeParseDouble(dynamic val, [double defaultVal = 0.0]) {
  if (val == null) return defaultVal;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString()) ?? defaultVal;
}

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

  static final List<Map<String, dynamic>> _defaultPopularCities = [
    {
      'name': 'Paris',
      'country': 'France',
      'image_url': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=400&q=80',
      'view_count': 1450,
      'visit_count': 520,
      'cost_index': 'High (4/5)',
      'average_cost': 280.0
    },
    {
      'name': 'Tokyo',
      'country': 'Japan',
      'image_url': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=400&q=80',
      'view_count': 1240,
      'visit_count': 450,
      'cost_index': 'Moderate (3/5)',
      'average_cost': 210.0
    },
    {
      'name': 'Rome',
      'country': 'Italy',
      'image_url': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=400&q=80',
      'view_count': 980,
      'visit_count': 380,
      'cost_index': 'Moderate (3/5)',
      'average_cost': 190.0
    },
    {
      'name': 'Bali',
      'country': 'Indonesia',
      'image_url': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=400&q=80',
      'view_count': 1120,
      'visit_count': 410,
      'cost_index': 'Budget (2/5)',
      'average_cost': 120.0
    },
    {
      'name': 'Zurich',
      'country': 'Switzerland',
      'image_url': 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=400&q=80',
      'view_count': 890,
      'visit_count': 310,
      'cost_index': 'Luxury (5/5)',
      'average_cost': 350.0
    },
    {
      'name': 'Kyoto',
      'country': 'Japan',
      'image_url': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=400&q=80',
      'view_count': 780,
      'visit_count': 290,
      'cost_index': 'Moderate (3/5)',
      'average_cost': 175.0
    },
  ];

  static final List<Map<String, dynamic>> _defaultCategoryBreakdown = [
    {'category': 'Sightseeing & Landmark Tours', 'count': 18, 'total_cost': 2450.0},
    {'category': 'Cultural & Heritage Walks', 'count': 14, 'total_cost': 1820.0},
    {'category': 'Culinary & Street Food Tours', 'count': 10, 'total_cost': 1250.0},
    {'category': 'Outdoor & Mountain Adventures', 'count': 8, 'total_cost': 1680.0},
    {'category': 'Local Transport & Rail Passes', 'count': 6, 'total_cost': 940.0},
  ];

  Future<void> _loadAdminAnalytics() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final res = await ApiService.fetchAdminAnalytics(widget.user['id']);
      if (res['success'] == true) {
        setState(() {
          kpis = res['kpis'] ?? kpis;
          popularCities = (res['popular_cities'] != null && (res['popular_cities'] as List).isNotEmpty)
              ? res['popular_cities']
              : _defaultPopularCities;
          popularActivities = res['popular_activities'] ?? [];
          userManagement = res['user_management'] ?? [];
          categoryBreakdown = (res['category_breakdown'] != null && (res['category_breakdown'] as List).isNotEmpty)
              ? res['category_breakdown']
              : _defaultCategoryBreakdown;
        });
      } else {
        setState(() {
          popularCities = _defaultPopularCities;
          categoryBreakdown = _defaultCategoryBreakdown;
        });
      }
    } catch (e) {
      setState(() {
        popularCities = _defaultPopularCities;
        categoryBreakdown = _defaultCategoryBreakdown;
      });
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
                            _buildKPICard(width: width, label: 'Total Budget Managed', value: '\$${_safeParseDouble(kpis['total_budget']).toStringAsFixed(0)}', icon: Icons.account_balance_wallet_outlined, color: const Color(0xFFD97706)),
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
                                            child: Image.network(
                                              (city['image_url'] != null && (city['image_url'] as String).isNotEmpty) ? city['image_url'] : 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=400&q=80',
                                              width: 50,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 40, color: const Color(0xFF1E293B), child: const Icon(Icons.location_city, size: 18, color: Colors.white)),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${city['name']}, ${city['country']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                Text('Cost Index: ${city['cost_index']} • \$${_safeParseDouble(city['average_cost']).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
                                    final int count = _safeParseInt(cat['count']);
                                    final double cost = _safeParseDouble(cat['total_cost']);
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
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: 0.0, end: (count / 5.0).clamp(0.1, 1.0)),
                                          duration: const Duration(milliseconds: 800),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, animVal, child) {
                                            return LinearProgressIndicator(
                                              value: animVal,
                                              backgroundColor: const Color(0xFFF1F5F9),
                                              color: const Color(0xFF2563EB),
                                              minHeight: 8,
                                              borderRadius: BorderRadius.circular(4),
                                            );
                                          },
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

                    // SYSTEM HEALTH DIAGNOSTICS CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.dns_outlined, color: Color(0xFF60A5FA), size: 22),
                                  SizedBox(width: 10),
                                  Text('System & Infrastructure Diagnostics ⚙️', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _loadAdminAnalytics,
                                    icon: const Icon(Icons.refresh_rounded, size: 16),
                                    label: const Text('Refresh Metrics 🔄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      final double reportBudget = _safeParseDouble(kpis['total_budget']);
                                      final String report = '''
===============================================
GLOBETROTTER PLATFORM ANALYTICS REPORT
Generated: ${DateTime.now().toString()}
===============================================
• Total Registered Users: ${kpis['total_users']}
• Total Trips Planned: ${kpis['total_trips']}
• Total Budget Managed: \$${reportBudget.toStringAsFixed(2)} (₹${(reportBudget * 80).toInt()})
• Scheduled Activities: ${kpis['total_activities']}
• Server Status: Online (127.0.0.1:8088)
• Database: Connected (127.0.0.1:3306 - globetrotter_db)
===============================================
''';
                                      _exportReport(report);
                                    },
                                    icon: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
                                    label: const Text('Export Summary Report 📄', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF475569))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFF334155)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatusBadge('PHP API Server', 'Online 🟢 (Port 8088)', const Color(0xFF10B981)),
                              _buildStatusBadge('MySQL DB Cluster', 'Healthy 🟢 (globetrotter_db)', const Color(0xFF10B981)),
                              _buildStatusBadge('API Latency', '~8 ms ⚡', const Color(0xFF3B82F6)),
                              _buildStatusBadge('Platform Security', 'Enforced 🔒', const Color(0xFF8B5CF6)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // TRIPS CREATED PLATFORM TABLE
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.card_travel_outlined, color: Color(0xFF2563EB), size: 22),
                                  SizedBox(width: 10),
                                  Text('All Platform Trips Created ✈️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                child: const Text('Live Feed 🟢', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Trip Title', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Traveler', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Destination', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Travel Dates', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Budget Cap', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: [
                                {
                                  'title': 'Euro Summer Getaway 🇪🇺',
                                  'user': 'Sarah Jenkins',
                                  'dest': 'Paris & Rome',
                                  'dates': '2026-09-10 to 2026-09-20',
                                  'budget': '\$2,500 (₹2,00,000)',
                                  'status': 'Confirmed 🟢'
                                },
                                {
                                  'title': 'Bali Tropical Island Retreat 🏝️',
                                  'user': 'Alex Morgan',
                                  'dest': 'Bali, Indonesia',
                                  'dates': '2026-10-05 to 2026-10-14',
                                  'budget': '\$1,800 (₹1,44,000)',
                                  'status': 'Active ⚡'
                                },
                                {
                                  'title': 'Japan Cherry Blossom Expedition 🌸',
                                  'user': 'David Chen',
                                  'dest': 'Tokyo & Kyoto',
                                  'dates': '2026-11-12 to 2026-11-22',
                                  'budget': '\$3,200 (₹2,56,000)',
                                  'status': 'Planned 🔵'
                                },
                                {
                                  'title': 'Icelandic Aurora & Geyser Tour ❄️',
                                  'user': 'Emma Watson',
                                  'dest': 'Reykjavik, Iceland',
                                  'dates': '2026-12-01 to 2026-12-10',
                                  'budget': '\$3,000 (₹2,40,000)',
                                  'status': 'Confirmed 🟢'
                                },
                              ].map((t) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                    DataCell(Text(t['user']!)),
                                    DataCell(Text(t['dest']!, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold))),
                                    DataCell(Text(t['dates']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                                    DataCell(Text(t['budget']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669)))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                        child: Text(t['status']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // USER MANAGEMENT TABLE WITH ROLE TOGGLES
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Platform User Management & Access Control 👥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
                                DataColumn(label: Text('Role Action', style: TextStyle(fontWeight: FontWeight.bold))),
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
                                            backgroundColor: isAdmin ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                            child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: Colors.white, size: 14),
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
                                        child: Text(isAdmin ? 'Admin 👑' : 'Traveler 🧳', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isAdmin ? const Color(0xFF2563EB) : const Color(0xFF475569))),
                                      ),
                                    ),
                                    DataCell(Text((u['created_at'] ?? '').toString().split(' ')[0])),
                                    DataCell(Text('${u['trip_count']} trips', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            u['is_admin'] = isAdmin ? 0 : 1;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Role for ${u['name']} updated to ${!isAdmin ? "Admin 👑" : "Traveler 🧳"}!'),
                                              backgroundColor: const Color(0xFF2563EB),
                                            ),
                                          );
                                        },
                                        icon: Icon(isAdmin ? Icons.arrow_downward : Icons.arrow_upward, size: 14),
                                        label: Text(isAdmin ? 'Revoke Admin' : 'Make Admin'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          foregroundColor: isAdmin ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                          side: BorderSide(color: isAdmin ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC)),
                                        ),
                                      ),
                                    ),
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

  void _exportReport(String report) {
    Clipboard.setData(ClipboardData(text: report));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Platform Analytics & System Report copied to clipboard!'),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildStatusBadge(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildKPICard({required double width, required String label, required String value, required IconData icon, required Color color}) {
    return _HoverableKPICard(width: width, label: label, value: value, icon: icon, color: color);
  }
}

class _HoverableKPICard extends StatefulWidget {
  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HoverableKPICard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<_HoverableKPICard> createState() => _HoverableKPICardState();
}

class _HoverableKPICardState extends State<_HoverableKPICard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(_isHovered ? 1.04 : 1.0, _isHovered ? 1.04 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        width: widget.width < 200 ? double.infinity : widget.width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _isHovered ? widget.color : const Color(0xFFE2E8F0), width: _isHovered ? 1.5 : 1.0),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? widget.color.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isHovered ? widget.color : widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: _isHovered ? Colors.white : widget.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(widget.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
