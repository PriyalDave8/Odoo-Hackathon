import 'package:flutter/material.dart';
import 'api_service.dart';

// Feature 5: Itinerary Builder Screen
class ItineraryBuilderScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onBack;

  const ItineraryBuilderScreen({
    super.key,
    required this.trip,
    required this.onBack,
  });

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
        setState(() {
          itineraryData = res;
        });
      } else {
        setState(() {
          error = res['message'] ?? 'Failed to load itinerary.';
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
                  Text(
                    'Itinerary Builder: ${widget.trip['title']}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.trip['destination']} (${widget.trip['start_date']} — ${widget.trip['end_date']})',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
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
              child: Column(
                children: [
                  const Icon(Icons.map_outlined, size: 44, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 12),
                  const Text('No city stops added yet.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Click "Add City Stop" above to define stops and activities for this trip.', style: TextStyle(color: Color(0xFF64748B))),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
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
                Text(
                  '${stop['city_name']}, ${stop['country']}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 12),
                Text(
                  '(${stop['start_date']} — ${stop['end_date']})',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
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

// Feature 6: Itinerary View Screen
class ItineraryViewScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onBack;

  const ItineraryViewScreen({
    super.key,
    required this.trip,
    required this.onBack,
  });

  @override
  State<ItineraryViewScreen> createState() => _ItineraryViewScreenState();
}

class _ItineraryViewScreenState extends State<ItineraryViewScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? itineraryData;

  bool isTimelineView = true;

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
        setState(() {
          itineraryData = res;
        });
      } else {
        setState(() {
          error = res['message'] ?? 'Failed to load itinerary.';
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
                  Text(
                    'Visual Itinerary View: ${widget.trip['title']}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.trip['destination']} (${widget.trip['start_date']} to ${widget.trip['end_date']})',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const Spacer(),
              // Toggle View Mode
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Timeline View'), icon: Icon(Icons.view_timeline_outlined)),
                  ButtonSegment(value: false, label: Text('City Grouped'), icon: Icon(Icons.location_city_outlined)),
                ],
                selected: {isTimelineView},
                onSelectionChanged: (set) => setState(() => isTimelineView = set.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: const Color(0xFF2563EB),
                  selectedForegroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Total Cost Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2563EB)),
                const SizedBox(width: 10),
                Text(
                  'Estimated Total Expense: \$${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const Spacer(),
                Text(
                  'Total Stops: ${stops.length} Cities',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
            const Center(child: Text('No stops created for this itinerary view yet.', style: TextStyle(color: Color(0xFF94A3B8))))
          else if (isTimelineView)
            _buildTimelineView(stops)
          else
            _buildCityGroupedView(stops),
        ],
      ),
    );
  }

  Widget _buildTimelineView(List<dynamic> stops) {
    return Column(
      children: stops.map((stop) {
        final List<dynamic> activities = stop['activities'] ?? [];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.location_on, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${stop['city_name']}, ${stop['country']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${stop['start_date']} — ${stop['end_date']}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              if (activities.isEmpty)
                const Text('No activities scheduled for this day range.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))
              else
                Column(
                  children: activities.map((act) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(act['time_slot'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2563EB))),
                          ),
                          const Icon(Icons.circle, size: 8, color: Color(0xFFCBD5E1)),
                          const SizedBox(width: 12),
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
                          Text('\$${(act['cost'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCityGroupedView(List<dynamic> stops) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: stops.map((stop) {
        final List<dynamic> activities = stop['activities'] ?? [];
        return Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stop['city_name']}, ${stop['country']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text('${stop['start_date']} — ${stop['end_date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 14),
              Text('${activities.length} Activities Scheduled', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
              const SizedBox(height: 10),
              ...activities.map((act) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('• ${act['title']}', style: const TextStyle(fontSize: 13))),
                        Text('\$${(act['cost'] as num).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }
}
