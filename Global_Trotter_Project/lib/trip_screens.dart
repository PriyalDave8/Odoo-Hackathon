import 'package:flutter/material.dart';
import 'api_service.dart';

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
        setState(() {
          error = res['message'] ?? 'Failed to create trip.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
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
                        Text(
                          'Create New Trip',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: widget.onCancel,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Initiate a new travel itinerary by filling in your primary destination and travel dates.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),

                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
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
                          TextFormField(
                            controller: _startDateController,
                            decoration: _inputDecoration('YYYY-MM-DD', Icons.calendar_today_outlined),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
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
                          TextFormField(
                            controller: _endDateController,
                            decoration: _inputDecoration('YYYY-MM-DD', Icons.event_outlined),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Estimated Total Budget (\$)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('2500.00', Icons.attach_money_outlined),
                ),
                const SizedBox(height: 16),

                const Text('Cover Image URL (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _coverUrlController,
                  decoration: _inputDecoration('https://images.unsplash.com/...', Icons.image_outlined),
                ),
                const SizedBox(height: 16),

                const Text('Trip Description & Notes (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration('Describe your trip goals, activities, and vision...', Icons.notes_outlined),
                ),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF475569))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: isSubmitting ? null : _submit,
                      icon: isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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

// Feature 4: My Trips Screen
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
        setState(() {
          trips = res['trips'];
        });
      } else {
        setState(() {
          error = res['message'] ?? 'Failed to load trips.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Unable to connect to backend server.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTrip(int tripId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip and all its stops/activities? This action cannot be undone.'),
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
        if (res['success'] == true) {
          _loadTrips();
        }
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
                  Text(
                    'My Travel Itineraries',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Access, build, and review all your planned multi-city journeys.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
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
                  elevation: 0,
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.flight_takeoff, size: 48, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 16),
                  const Text('No trips found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  const Text('Start by creating a new trip itinerary to plan your journey.', style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: widget.onCreateNewTrip,
                    icon: const Icon(Icons.add),
                    label: const Text('Plan New Trip'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  ),
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                  ),
                  child: Text(
                    trip['status'] ?? 'Planned',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['title'] ?? 'Untitled Trip',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
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
