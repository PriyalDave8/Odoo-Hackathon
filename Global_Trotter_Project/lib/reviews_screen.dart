import 'package:flutter/material.dart';
import 'api_service.dart';

class ReviewsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ReviewsScreen({super.key, required this.user});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool isLoading = true;
  double averageRating = 4.9;
  int totalReviews = 6;
  Map<int, int> ratingCounts = {5: 5, 4: 1, 3: 0, 2: 0, 1: 0};
  List<dynamic> reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiService.fetchReviews();
      if (res['success'] == true) {
        setState(() {
          averageRating = (res['average_rating'] as num).toDouble();
          totalReviews = (res['total_reviews'] as num).toInt();
          reviews = res['reviews'];
          if (res['rating_counts'] != null) {
            final Map<String, dynamic> rawCounts = Map<String, dynamic>.from(res['rating_counts']);
            ratingCounts = {
              5: (rawCounts['5'] as num?)?.toInt() ?? 0,
              4: (rawCounts['4'] as num?)?.toInt() ?? 0,
              3: (rawCounts['3'] as num?)?.toInt() ?? 0,
              2: (rawCounts['2'] as num?)?.toInt() ?? 0,
              1: (rawCounts['1'] as num?)?.toInt() ?? 0,
            };
          }
        });
      }
    } catch (e) {
      // Fallback
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showWriteReviewDialog() {
    int selectedRating = 5;
    String selectedDestination = 'Paris, France';
    final titleController = TextEditingController();
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.rate_review, color: Color(0xFF2563EB)),
                  SizedBox(width: 10),
                  Text('Write a Review & Rate Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Destination / City:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedDestination,
                            items: [
                              'Paris, France',
                              'Tokyo, Japan',
                              'Rome, Italy',
                              'Bali, Indonesia',
                              'Zurich, Switzerland',
                              'Kyoto, Japan',
                              'Reykjavik, Iceland',
                              'London, United Kingdom',
                              'New York, United States',
                              'Barcelona, Spain',
                            ].map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14)))).toList(),
                            onChanged: (v) {
                              if (v != null) setModalState(() => selectedDestination = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Overall Rating:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          return IconButton(
                            icon: Icon(
                              star <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: const Color(0xFFD97706),
                              size: 32,
                            ),
                            onPressed: () => setModalState(() => selectedRating = star),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      const Text('Review Title:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Incredible Paris Sunset & Dinner Cruise',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Detailed Review & Experience:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Share details about the itinerary, sightseeing, meals, hotel stay, or transport...',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                    ],
                  ),
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
                            userId: widget.user['id'],
                            destinationName: selectedDestination,
                            rating: selectedRating,
                            title: titleController.text.trim(),
                            comment: commentController.text.trim(),
                          );
                          navigator.pop();
                          if (res['success'] == true) {
                            messenger.showSnackBar(const SnackBar(content: Text('Review submitted successfully!')));
                            _loadReviews();
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Post Review'),
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
                  Text('Reviews & Ratings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Read traveler experiences and rate your favorite destinations & itineraries.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showWriteReviewDialog,
                icon: const Icon(Icons.rate_review, size: 18),
                label: const Text('Write a Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // RATINGS OVERVIEW CARD
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -1),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 20),
                        Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 20),
                        Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 20),
                        Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 20),
                        Icon(Icons.star_half_rounded, color: Color(0xFFD97706), size: 20),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Based on $totalReviews reviews', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(width: 40),
                const SizedBox(height: 90, child: VerticalDivider(color: Color(0xFFE2E8F0))),
                const SizedBox(width: 40),

                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((star) {
                      final count = ratingCounts[star] ?? 0;
                      final double pct = totalReviews > 0 ? count / totalReviews : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          children: [
                            Text('$star ★', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: const Color(0xFFF1F5F9),
                                color: const Color(0xFFD97706),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('$count', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text('Traveler Reviews Feed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),

          isLoading
              ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF2563EB))))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final rev = Map<String, dynamic>.from(reviews[index]);
                    final int rating = (rev['rating'] as num?)?.toInt() ?? 5;

                    return Container(
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
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF2563EB),
                                child: Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(rev['user_name'] ?? 'Traveler', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                                    Text('Reviewed: ${rev['destination_name']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: const Color(0xFFD97706),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(rev['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                          const SizedBox(height: 6),
                          Text(rev['comment'] ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4)),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
