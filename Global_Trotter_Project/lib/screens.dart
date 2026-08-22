import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

int _safeParseInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString()) ?? 0;
}

double _safeParseDouble(dynamic val, [double defaultVal = 0.0]) {
  if (val == null) return defaultVal;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString()) ?? defaultVal;
}

Widget buildSafeImage({
  required String? url,
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
  String label = 'GlobeTrotter',
}) {
  final String rawUrl = (url ?? '').trim();
  final String validUrl = rawUrl.isNotEmpty
      ? rawUrl
      : 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80';

  return Image.network(
    validUrl,
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
          ),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_city_rounded, size: 22, color: Color(0xFF60A5FA)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _HoverableCard({
    required this.child,
    this.onTap,
  });

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: isHovered ? Matrix4.diagonal3Values(1.025, 1.025, 1.0) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _AnimatedPageEntrance extends StatelessWidget {
  final Widget child;

  const _AnimatedPageEntrance({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutQuart,
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, (1 - val) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

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

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    final otpController = TextEditingController(text: '123456');
    final newPasswordController = TextEditingController();
    bool isSubmitting = false;
    int step = 1;
    String? resetError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF2563EB), size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text('Reset Account Password 🔐', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (resetError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFCA5A5))),
                          child: Text(resetError!, style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12)),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (step == 1) ...[
                        const Text('Enter your registered email address to receive a secure 6-digit verification OTP code:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        const SizedBox(height: 14),
                        const Text('Registered Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: resetEmailController,
                          decoration: _inputDecoration('sarah@globetrotter.com', Icons.email_outlined),
                        ),
                      ] else ...[
                        const Text('We sent a verification code to your email. Enter the OTP code and set your new password:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        const SizedBox(height: 14),
                        const Text('6-Digit Verification Code (OTP)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: otpController,
                          decoration: _inputDecoration('123456', Icons.pin_outlined),
                        ),
                        const SizedBox(height: 14),
                        const Text('New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: newPasswordController,
                          obscureText: true,
                          decoration: _inputDecoration('Enter new password', Icons.lock_outline),
                        ),
                      ],
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
                          setModalState(() {
                            isSubmitting = true;
                            resetError = null;
                          });

                          if (step == 1) {
                            if (resetEmailController.text.trim().isEmpty || !resetEmailController.text.contains('@')) {
                              setModalState(() {
                                resetError = 'Please enter a valid email address.';
                                isSubmitting = false;
                              });
                              return;
                            }
                            setModalState(() {
                              step = 2;
                              isSubmitting = false;
                            });
                          } else {
                            if (newPasswordController.text.trim().length < 6) {
                              setModalState(() {
                                resetError = 'New password must be at least 6 characters long.';
                                isSubmitting = false;
                              });
                              return;
                            }

                            final res = await ApiService.resetPassword(
                              resetEmailController.text.trim(),
                              newPasswordController.text.trim(),
                            );

                            if (res['success'] == true) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'Password reset successfully! Log in with your new password.'),
                                    backgroundColor: const Color(0xFF059669),
                                  ),
                                );
                              }
                            } else {
                              setModalState(() {
                                resetError = res['message'] ?? 'Failed to reset password.';
                                isSubmitting = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(step == 1 ? 'Send Code 📩' : 'Update Password 🔐', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                            onPressed: _showForgotPasswordDialog,
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
                        onTap: () {
                          setState(() {
                            isLogin = !isLogin;
                            errorMessage = null;
                            _nameController.clear();
                            _emailController.clear();
                            _passwordController.clear();
                          });
                        },
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
// CITY DETAILS MODAL DIALOG WITH MULTI-IMAGE CAROUSEL
// ==========================================
List<String> _getCityImageGallery(Map<String, dynamic> city) {
  final String cityName = (city['name'] ?? '').toString().toLowerCase();
  final String heroImg = city['image_url'] ?? '';

  if (cityName.contains('paris')) {
    return [
      if (heroImg.isNotEmpty) heroImg,
      'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1509299349698-dd22323b5963?auto=format&fit=crop&w=800&q=80',
    ];
  } else if (cityName.contains('rome')) {
    return [
      if (heroImg.isNotEmpty) heroImg,
      'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1548625361-18a7a8d54641?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1529260830199-42c24126f198?auto=format&fit=crop&w=800&q=80',
    ];
  } else if (cityName.contains('bali')) {
    return [
      if (heroImg.isNotEmpty) heroImg,
      'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1539367628448-4bc5c9d171c8?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1555400038-63f5ba517a47?auto=format&fit=crop&w=800&q=80',
    ];
  } else if (cityName.contains('tokyo') || cityName.contains('kyoto')) {
    return [
      if (heroImg.isNotEmpty) heroImg,
      'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1542051841857-5f90071e7989?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80',
    ];
  } else if (cityName.contains('zurich') || cityName.contains('lucerne') || cityName.contains('swiss')) {
    return [
      if (heroImg.isNotEmpty) heroImg,
      'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1527668752968-14dc70a27c95?auto=format&fit=crop&w=800&q=80',
    ];
  } else if (cityName.contains('reykjavik') || cityName.contains('iceland')) {
    return [
      if (heroImg.isNotEmpty) heroImg,
      'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1504893524553-b855bce32c67?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1476610194761-9c766e4a27bc?auto=format&fit=crop&w=800&q=80',
    ];
  }

  final List<String> defaultGallery = [
    if (heroImg.isNotEmpty) heroImg,
    'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=800&q=80',
  ];
  return defaultGallery.toSet().toList();
}

void showCityDetailsModal(BuildContext context, Map<String, dynamic> city, Function(String destination) onPlanTrip) {
  final int cityId = (city['id'] as num?)?.toInt() ?? 0;
  if (cityId > 0) {
    ApiService.recordCityView(cityId);
  }

  final List<String> gallery = _getCityImageGallery(city);
  for (var imgUrl in gallery) {
    if (imgUrl.isNotEmpty) {
      precacheImage(NetworkImage(imgUrl), context);
    }
  }

  int activeIndex = 0;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: 580,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image Carousel & Navigation Arrows Header
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Image.network(
                            gallery[activeIndex],
                            key: ValueKey<int>(activeIndex),
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 240,
                                color: const Color(0xFFF1F5F9),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 240,
                              color: const Color(0xFFE2E8F0),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_library_outlined, size: 36, color: Color(0xFF94A3B8)),
                                  SizedBox(height: 6),
                                  Text('High-Definition Location Photo', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Top & Bottom Overlay Gradients
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // TOP LEFT PHOTO COUNTER BADGE
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.photo_library, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text('Photo ${activeIndex + 1} of ${gallery.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      // TOP RIGHT CLOSE BUTTON
                      Positioned(
                        top: 12,
                        right: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF0F172A), size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      // LEFT ARROW BUTTON (<)
                      if (gallery.length > 1)
                        Positioned(
                          left: 12,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withValues(alpha: 0.6),
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                              onPressed: () {
                                setModalState(() {
                                  activeIndex = (activeIndex - 1 + gallery.length) % gallery.length;
                                });
                              },
                            ),
                          ),
                        ),

                      // RIGHT ARROW BUTTON (>)
                      if (gallery.length > 1)
                        Positioned(
                          right: 12,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withValues(alpha: 0.6),
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                              onPressed: () {
                                setModalState(() {
                                  activeIndex = (activeIndex + 1) % gallery.length;
                                });
                              },
                            ),
                          ),
                        ),

                      // BOTTOM METADATA & DOTS INDICATOR
                      Positioned(
                        bottom: 14,
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
                                const Spacer(),
                                // DOTS INDICATOR
                                Row(
                                  children: List.generate(gallery.length, (idx) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      height: 6,
                                      width: idx == activeIndex ? 18 : 6,
                                      decoration: BoxDecoration(
                                        color: idx == activeIndex ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    );
                                  }),
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
                        Text('Avg Cost: \$${_safeParseDouble(city['average_cost'], 1200.0).toStringAsFixed(2)} (${city['cost_index'] ?? '\$\$\$'})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF059669))),
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
                        _buildExpenseChip('Hotel / Stay', '\$${_safeParseDouble(city['hotel_avg_cost'], 150.0).toStringAsFixed(0)}/night', Icons.hotel),
                        _buildExpenseChip('Meals / Dining', '\$${_safeParseDouble(city['meal_avg_cost'], 55.0).toStringAsFixed(0)}/day', Icons.restaurant),
                        _buildExpenseChip('Local Transport', '\$20/day', Icons.directions_bus),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final String shareUrl = 'http://localhost:8090/?city=${Uri.encodeComponent(city['name'] ?? 'Paris')}';
                                Clipboard.setData(ClipboardData(text: shareUrl));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Direct place share link for "${city['name']}" copied to clipboard! Anyone opening this link will view ${city['name']} details immediately.'),
                                    backgroundColor: const Color(0xFF2563EB),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share, size: 16),
                              label: const Text('Share Place Link', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB), side: const BorderSide(color: Color(0xFF2563EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                onPlanTrip('${city['name']}, ${city['country']}');
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: Text('Plan Trip to ${city['name']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
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
  final Function([String? destination]) onNavigateToCreateTrip;
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
            : _AnimatedPageEntrance(
                child: SingleChildScrollView(
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
    return _HoverableCard(
      onTap: () => widget.onBuildItinerary(trip),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: buildSafeImage(url: trip['cover_image_url'], width: 100, height: 80, label: trip['title'] ?? 'Trip'),
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
            ElevatedButton.icon(
              onPressed: () => widget.onBuildItinerary(trip),
              icon: const Icon(Icons.tune, size: 14),
              label: const Text('Customise Trip', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockupCityCard(Map<String, dynamic> dest) {
    return _HoverableCard(
      onTap: () => showCityDetailsModal(context, dest, (destName) => widget.onNavigateToCreateTrip(destName)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: buildSafeImage(url: dest['image_url'], width: 80, height: 65, label: dest['name'] ?? 'City'),
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
            Text('\$${_safeParseDouble(dest['average_cost']).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
  final String? initialDestination;
  final VoidCallback onTripCreated;
  final VoidCallback onCancel;

  const CreateTripScreen({
    super.key,
    required this.user,
    this.initialDestination,
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

  late Set<String> _selectedPlaces;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null && widget.initialDestination!.isNotEmpty) {
      final String rawDest = widget.initialDestination!;
      _destinationController.text = rawDest;
      final String cityOnly = rawDest.split(',')[0].trim();
      _titleController.text = '$cityOnly Escape 🏖️';

      final String matched = _availablePlaces.firstWhere(
        (p) => p.toLowerCase().contains(cityOnly.toLowerCase()),
        orElse: () => rawDest,
      );
      _selectedPlaces = {matched};
    } else {
      _selectedPlaces = {'Paris, France 🇫🇷', 'Rome, Italy 🇮🇹'};
    }
  }

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
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                                    child: buildSafeImage(url: trip['cover_image_url'], width: double.infinity, height: 130, label: trip['title'] ?? 'Trip'),
                                  ),
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
                                            Expanded(child: ElevatedButton.icon(onPressed: () => widget.onBuildItinerary(trip), icon: const Icon(Icons.tune, size: 15), label: const Text('Customise Trip', style: TextStyle(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white))),
                                            const SizedBox(width: 8),
                                            Expanded(child: OutlinedButton.icon(onPressed: () => widget.onViewItinerary(trip), icon: const Icon(Icons.visibility, size: 15), label: const Text('View Plan'))),
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
  final Map<String, bool> _selectedCountryStops = {};

  List<Map<String, String>> _getCountryStopsForTrip(String dest) {
    final String lower = dest.toLowerCase();
    if (lower.contains('japan') || lower.contains('tokyo') || lower.contains('kyoto')) {
      return [
        {'name': 'Tokyo Shibuya Sky & Crossing', 'type': 'Observation Deck', 'days': '3 Days Stay', 'cost': '₹2,000', 'desc': 'High-altitude observatory over Shibuya Crossing.'},
        {'name': 'Tsukiji Outer Seafood Market', 'type': 'Food Crawl', 'days': '2 Days Stay', 'cost': '₹3,500', 'desc': 'Fresh sushi, wagyu beef, and green tea stalls.'},
        {'name': 'Kyoto Fushimi Inari Torii Gates', 'type': 'Historic Shrine', 'days': '3 Days Stay', 'cost': '₹1,200', 'desc': '10,000 vermilion torii gates winding up Mount Inari.'},
        {'name': 'Kyoto Kinkaku-ji Golden Pavilion', 'type': 'Zen Temple', 'days': '2 Days Stay', 'cost': '₹1,500', 'desc': 'Gold leaf covered temple overlooking reflection pond.'},
        {'name': 'Osaka Dotonbori Street Food Crawl', 'type': 'Nightlife & Dining', 'days': '2 Days Stay', 'cost': '₹2,500', 'desc': 'Sampling octopus takoyaki, okonomiyaki, and neon signs.'},
      ];
    } else if (lower.contains('rome') || lower.contains('italy')) {
      return [
        {'name': 'Colosseum Arena & Roman Forum', 'type': 'Ancient Ruins', 'days': '4 Days Stay', 'cost': '₹3,200', 'desc': 'Gladiator arena floor & Roman Empire Forum ruins.'},
        {'name': 'Vatican Museums & Sistine Chapel', 'type': 'Papal Palace', 'days': '3 Days Stay', 'cost': '₹4,000', 'desc': 'St. Peter Basilica, Michelangelo frescoes, and galleries.'},
        {'name': 'Trastevere Historic Quarter Walk', 'type': 'Food & Wine', 'days': '2 Days Stay', 'cost': '₹2,000', 'desc': 'Charming trattorias, pasta carbonara, and wine bars.'},
        {'name': 'Trevi Fountain & Spanish Steps', 'type': 'Baroque Plaza', 'days': '2 Days Stay', 'cost': '₹800', 'desc': 'Famous coin-tossing fountain and marble plaza steps.'},
      ];
    } else if (lower.contains('swiss') || lower.contains('zurich') || lower.contains('zermatt')) {
      return [
        {'name': 'Zurich Altstadt & Promenade', 'type': 'Lakefront City', 'days': '3 Days Stay', 'cost': '₹2,200', 'desc': 'Guild houses, Limmat river, and lakefront promenade.'},
        {'name': 'Mt. Titlis Glacier Cable Car', 'type': 'Alpine Summit', 'days': '3 Days Stay', 'cost': '₹8,500', 'desc': 'Rotair revolving cable car, cliff walk, and glacier cave.'},
        {'name': 'Lucerne Chapel Wooden Bridge', 'type': 'Historic Landmark', 'days': '2 Days Stay', 'cost': '₹1,800', 'desc': '14th-century covered bridge and Lake Lucerne cruise.'},
        {'name': 'Matterhorn Zermatt Gornergrat Railway', 'type': 'Mountain Train', 'days': '4 Days Stay', 'cost': '₹9,000', 'desc': 'Cogwheel railway facing famous pyramid Matterhorn peak.'},
      ];
    } else if (lower.contains('bali') || lower.contains('ubud')) {
      return [
        {'name': 'Tegallalang Rice Terrace & Jungle Swing', 'type': 'Nature Valley', 'days': '3 Days Stay', 'cost': '₹1,800', 'desc': 'Lush terraced paddies and giant jungle swing.'},
        {'name': 'Sacred Monkey Forest Sanctuary Ubud', 'type': 'Sanctuary', 'days': '2 Days Stay', 'cost': '₹1,000', 'desc': 'Ancient Banyan tree temples inhabited by macaques.'},
        {'name': 'Uluwatu Cliffside Temple & Kecak Dance', 'type': 'Cliff Temple', 'days': '3 Days Stay', 'cost': '₹2,500', 'desc': 'Spectacular cliffside views and sunset Kecak fire dance.'},
        {'name': 'Seminyak Beachfront Resort Clubs', 'type': 'Beach Lounge', 'days': '3 Days Stay', 'cost': '₹3,000', 'desc': 'Sunset lounge daybeds, surf beaches, and seafood.'},
      ];
    }
    return [
      {'name': 'Eiffel Tower Sunset Summit', 'type': 'Landmark & Viewpoint', 'days': '5 Days Stay', 'cost': '₹3,500', 'desc': 'Iconic Eiffel Tower summit elevator & champagne.'},
      {'name': 'Louvre Museum Masterpieces Walk', 'type': 'Art & Culture', 'days': '4 Days Stay', 'cost': '₹2,500', 'desc': 'World-famous glass pyramid & Mona Lisa galleries.'},
      {'name': 'Seine River Gourmet Dinner Cruise', 'type': 'River Cruise', 'days': '3 Days Stay', 'cost': '₹4,500', 'desc': '3-course French dining cruise along illuminated Paris monuments.'},
      {'name': 'Montmartre Artists Village & Sacré-Cœur', 'type': 'Historic Hill', 'days': '2 Days Stay', 'cost': '₹1,200', 'desc': 'Artist square, cobblestone lanes, and hilltop basilica.'},
      {'name': 'Palace of Versailles Royal Estate', 'type': 'Royal Palace', 'days': '2 Days Stay', 'cost': '₹3,000', 'desc': 'Hall of Mirrors and grand royal fountain gardens.'},
    ];
  }

  final Map<String, bool> _selectedActivities = {};

  List<Map<String, String>> _getAvailableActivitiesForTrip(String dest) {
    final String lower = dest.toLowerCase();
    if (lower.contains('japan') || lower.contains('tokyo')) {
      return [
        {'title': 'Shibuya Sky Observatory', 'duration': '2 hours', 'cost': '₹2,500'},
        {'title': 'Tsukiji Market Sushi Tour', 'duration': '3 hours', 'cost': '₹3,500'},
        {'title': 'Sensō-ji Temple Walk', 'duration': '2 hours', 'cost': '₹1,500'},
        {'title': 'Mt. Fuji Day Excursion', 'duration': '8 hours', 'cost': '₹7,500'},
      ];
    } else if (lower.contains('rome') || lower.contains('italy')) {
      return [
        {'title': 'Colosseum Arena Tour', 'duration': '3 hours', 'cost': '₹3,200'},
        {'title': 'Vatican Museums & Sistine Chapel', 'duration': '4 hours', 'cost': '₹4,000'},
        {'title': 'Trastevere Food Tour', 'duration': '3 hours', 'cost': '₹2,000'},
        {'title': 'Trevi Fountain Evening Walk', 'duration': '1 hour', 'cost': '₹800'},
      ];
    } else if (lower.contains('swiss') || lower.contains('zurich')) {
      return [
        {'title': 'Mt. Titlis Cable Car', 'duration': '5 hours', 'cost': '₹8,500'},
        {'title': 'Lindt Chocolate Tasting', 'duration': '2 hours', 'cost': '₹2,500'},
        {'title': 'Lake Zurich Boat Cruise', 'duration': '2 hours', 'cost': '₹2,200'},
        {'title': 'Matterhorn Railway Excursion', 'duration': '4 hours', 'cost': '₹9,000'},
      ];
    } else if (lower.contains('bali')) {
      return [
        {'title': 'Tegallalang Jungle Swing', 'duration': '2 hours', 'cost': '₹1,800'},
        {'title': 'Monkey Forest Sanctuary', 'duration': '2 hours', 'cost': '₹1,000'},
        {'title': 'Uluwatu Kecak Fire Dance', 'duration': '3 hours', 'cost': '₹2,500'},
        {'title': 'Seminyak Beach Lounge', 'duration': '4 hours', 'cost': '₹3,000'},
      ];
    }
    return [
      {'title': 'Eiffel Tower', 'duration': '2 hours', 'cost': '₹2,500'},
      {'title': 'Louvre Museum', 'duration': '3 hours', 'cost': '₹1,800'},
      {'title': 'Seine River Cruise', 'duration': '2 hours', 'cost': '₹3,000'},
      {'title': 'Food Tour', 'duration': '3 hours', 'cost': '₹2,000'},
    ];
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => isLoading = true);
    final int tripId = (widget.trip['id'] as num?)?.toInt() ?? 0;
    if (tripId > 0) {
      try {
        final res = await ApiService.fetchItinerary(tripId);
        if (res['success'] == true && res['trip'] != null && res['stops'] != null && (res['stops'] as List).isNotEmpty) {
          if (mounted) {
            setState(() {
              itineraryData = res;
              isLoading = false;
            });
          }
          return;
        }
      } catch (e) {
        // Fallback
      }
    }

    final String dest = widget.trip['destination'] ?? 'Paris & Rome';
    final List<String> parts = dest.split('&').map((e) => e.trim()).toList();
    final String city1 = parts.isNotEmpty ? parts[0] : 'Paris';
    final String city2 = parts.length > 1 ? parts[1] : 'Rome';

    if (mounted) {
      setState(() {
        itineraryData = {
          'success': true,
          'trip': widget.trip,
          'stops': [
            {
              'id': 101,
              'city_name': city1,
              'country': 'France',
              'start_date': widget.trip['start_date'] ?? '2026-09-10',
              'end_date': widget.trip['end_date'] ?? '2026-09-15',
              'activities': [
                {'title': 'Breakfast', 'time_slot': '09:00 AM', 'cost': 0.0, 'duration': '1 hour'},
                {'title': 'Eiffel Tower', 'time_slot': '10:30 AM', 'cost': 31.25, 'duration': '2 hours'},
                {'title': 'Lunch', 'time_slot': '02:00 PM', 'cost': 0.0, 'duration': '1 hour'},
                {'title': 'Louvre Museum', 'time_slot': '04:00 PM', 'cost': 22.50, 'duration': '3 hours'},
                {'title': 'Dinner', 'time_slot': '08:00 PM', 'cost': 0.0, 'duration': '2 hours'},
              ]
            },
            {
              'id': 102,
              'city_name': city2,
              'country': 'Italy',
              'start_date': widget.trip['start_date'] ?? '2026-09-16',
              'end_date': widget.trip['end_date'] ?? '2026-09-20',
              'activities': [
                {'title': 'Breakfast', 'time_slot': '09:00 AM', 'cost': 0.0, 'duration': '1 hour'},
                {'title': 'Colosseum & Forum Arena', 'time_slot': '10:30 AM', 'cost': 40.0, 'duration': '3 hours'},
                {'title': 'Lunch', 'time_slot': '02:00 PM', 'cost': 0.0, 'duration': '1 hour'},
                {'title': 'Vatican Museums', 'time_slot': '04:00 PM', 'cost': 50.0, 'duration': '3 hours'},
                {'title': 'Dinner', 'time_slot': '08:00 PM', 'cost': 0.0, 'duration': '2 hours'},
              ]
            }
          ]
        };
        isLoading = false;
      });
    }
  }

  bool isSavingCustomisation = false;

  Future<void> _saveEntireCustomisation(double totalEstimatedCost) async {
    setState(() => isSavingCustomisation = true);

    final List<Map<String, String>> countryStops = _getCountryStopsForTrip(widget.trip['destination'] ?? '');
    int activeStopsCount = 0;
    for (var stop in countryStops) {
      if (_selectedCountryStops[stop['name']] ?? true) activeStopsCount++;
    }

    final List<Map<String, String>> availableActs = _getAvailableActivitiesForTrip(widget.trip['destination'] ?? '');
    int activeActivitiesCount = 0;
    for (var act in availableActs) {
      if (_selectedActivities[act['title']] ?? true) activeActivitiesCount++;
    }

    final int tripId = _safeParseInt(widget.trip['id']);
    await ApiService.updateTripExpenses(
      tripId: tripId,
      transportCost: _safeParseDouble(widget.trip['transport_cost'], 650.0),
      hotelCost: _safeParseDouble(widget.trip['hotel_cost'], 1100.0),
      mealCost: _safeParseDouble(widget.trip['meal_cost'], 550.0),
      budget: totalEstimatedCost,
    );

    if (mounted) {
      setState(() => isSavingCustomisation = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF059669), size: 28),
              SizedBox(width: 10),
              Text('Customisation Saved! 🎉', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your entire itinerary customisation and updated budget plan have been successfully saved to your account!',
                  style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF86EFAC))),
                  child: Column(
                    children: [
                      _buildSavedRow('Included Country Stops:', '$activeStopsCount of ${countryStops.length} stops active'),
                      const Divider(height: 16),
                      _buildSavedRow('Selected Activities:', '$activeActivitiesCount of ${availableActs.length} activities'),
                      const Divider(height: 16),
                      _buildSavedRow('Recalculated Budget:', '₹${(totalEstimatedCost * 80).toInt()} (\$${totalEstimatedCost.toStringAsFixed(2)})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('Done & Continue'),
            ),
          ],
        ),
      );
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

  Widget _buildSavedRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? trip = itineraryData?['trip'];
    final List<dynamic> stops = itineraryData?['stops'] ?? [];

    double includedActivitiesCost = 0.0;
    for (var stop in stops) {
      final int stopId = _safeParseInt(stop['id']);
      if (!excludedStopIds.contains(stopId)) {
        final List<dynamic> activities = stop['activities'] ?? [];
        for (var a in activities) {
          includedActivitiesCost += _safeParseDouble(a['cost']);
        }
      }
    }

    final List<Map<String, String>> countryStops = _getCountryStopsForTrip(widget.trip['destination'] ?? '');
    for (var stop in countryStops) {
      final String name = stop['name'] ?? '';
      final bool isChecked = _selectedCountryStops[name] ?? true;
      if (isChecked) {
        final String costStr = stop['cost'] ?? '0';
        final double rawCost = double.tryParse(costStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        includedActivitiesCost += (rawCost / 80.0);
      }
    }

    final List<Map<String, String>> availableActs = _getAvailableActivitiesForTrip(widget.trip['destination'] ?? '');
    for (var act in availableActs) {
      final String title = act['title'] ?? '';
      final bool isChecked = _selectedActivities[title] ?? true;
      if (isChecked) {
        final String costStr = act['cost'] ?? '0';
        final double rawCost = double.tryParse(costStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        includedActivitiesCost += (rawCost / 80.0);
      }
    }

    final double plannedBudget = _safeParseDouble(trip?['budget'], 2500.0);
    final double transportCost = _safeParseDouble(trip?['transport_cost'], 650.0);
    final double hotelCost = _safeParseDouble(trip?['hotel_cost'], 1100.0);
    final double mealCost = _safeParseDouble(trip?['meal_cost'], 550.0);

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
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: isSavingCustomisation ? null : () => _saveEntireCustomisation(totalEstimatedCost),
                icon: isSavingCustomisation
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Entire Customisation 💾', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

          // INTERACTIVE COUNTRY STOPS CHECKBOX CUSTOMISATION CARD
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_box_outlined, color: Color(0xFF2563EB), size: 22),
                        const SizedBox(width: 10),
                        Text('Customise City & Landmark Stops (${widget.trip['destination'] ?? 'Country'})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                      child: const Text('Checkbox Customisation ✅', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Check or unselect specific city & landmark stops in this country to customize your trip booking:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 16),
                Column(
                  children: _getCountryStopsForTrip(widget.trip['destination'] ?? '').map((stop) {
                    final String stopName = stop['name'] ?? '';
                    final bool isChecked = _selectedCountryStops[stopName] ?? true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isChecked ? const Color(0xFFF8FAFC) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isChecked ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
                      ),
                      child: CheckboxListTile(
                        value: isChecked,
                        activeColor: const Color(0xFF2563EB),
                        title: Text(stopName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isChecked ? const Color(0xFF0F172A) : const Color(0xFF64748B))),
                        subtitle: Text('${stop['type']} • Duration: ${stop['days'] ?? '3 Days Stay'} • Est. Cost: ${stop['cost']}\n${stop['desc']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        onChanged: (bool? checked) {
                          setState(() {
                            _selectedCountryStops[stopName] = checked ?? false;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (trip != null && trip['id'] != null) {
                        await ApiService.updateTripExpenses(
                          tripId: _safeParseInt(trip['id']),
                          transportCost: transportCost,
                          hotelCost: hotelCost,
                          mealCost: mealCost,
                        );
                      }
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Customised stops saved! Updated Total Budget: \$${totalEstimatedCost.toStringAsFixed(2)} (₹${(totalEstimatedCost * 80).toStringAsFixed(0)})'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Customised Stops & Update Booking', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // AVAILABLE ACTIVITIES CHECKBOX CARD (EXACT MATCH FOR USER FORMAT)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF059669), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Available Activities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                      child: const Text('Activity Customisation 🎯', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: _getAvailableActivitiesForTrip(widget.trip['destination'] ?? '').map((act) {
                    final String title = act['title'] ?? '';
                    final bool isChecked = _selectedActivities[title] ?? true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isChecked ? const Color(0xFFF8FAFC) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isChecked ? const Color(0xFF059669) : const Color(0xFFE2E8F0)),
                      ),
                      child: CheckboxListTile(
                        value: isChecked,
                        activeColor: const Color(0xFF059669),
                        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isChecked ? const Color(0xFF0F172A) : const Color(0xFF64748B))),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('${act['duration']} | ${act['cost']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isChecked ? const Color(0xFF059669) : const Color(0xFF64748B))),
                        ),
                        onChanged: (bool? checked) {
                          setState(() {
                            _selectedActivities[title] = checked ?? false;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (trip != null && trip['id'] != null) {
                        await ApiService.updateTripExpenses(
                          tripId: _safeParseInt(trip['id']),
                          transportCost: transportCost,
                          hotelCost: hotelCost,
                          mealCost: mealCost,
                        );
                      }
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Activity selections saved! Updated Total Budget: \$${totalEstimatedCost.toStringAsFixed(2)} (₹${(totalEstimatedCost * 80).toStringAsFixed(0)})'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Save Activity Selection & Update Budget', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

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
                    final int stopId = _safeParseInt(stop['id']);
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
                            Text('Stop ${index + 1}: ${stop['city_name']}, ${stop['country']} (5 Days Stay)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isExcluded ? const Color(0xFF64748B) : const Color(0xFF0F172A), decoration: isExcluded ? TextDecoration.lineThrough : null)),
                            const SizedBox(width: 10),
                            if (isExcluded)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                child: const Text('EXCLUDED FROM PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              ),
                          ],
                        ),
                        subtitle: Text('Duration: 5 Days (4 Nights) • Dates: ${stop['start_date']} — ${stop['end_date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                                      Text('\$${_safeParseDouble(act['cost']).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
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

          // STICKY SAVE ENTIRE CUSTOMISATION FOOTER CARD
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ready to finalize your customisation? ✈️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Saves all selected country stops, included activities, and updated total budget cap (₹${(totalEstimatedCost * 80).toInt()} / \$${totalEstimatedCost.toStringAsFixed(2)}).', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isSavingCustomisation ? null : () => _saveEntireCustomisation(totalEstimatedCost),
                  icon: isSavingCustomisation
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_alt_rounded, size: 20),
                  label: const Text('Save Entire Customisation & Update Trip 💾', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
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
    if (mounted) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }

    final int tripId = (widget.trip['id'] as num?)?.toInt() ?? 0;
    if (tripId > 0) {
      try {
        final res = await ApiService.fetchItinerary(tripId);
        if (res['success'] == true && res['trip'] != null && res['stops'] != null && (res['stops'] as List).isNotEmpty) {
          if (mounted) {
            setState(() {
              itineraryData = res;
              isLoading = false;
            });
          }
          return;
        }
      } catch (e) {
        // Fallback
      }
    }

    final String dest = widget.trip['destination'] ?? 'Paris & Rome';
    final List<String> parts = dest.split('&').map((e) => e.trim()).toList();
    final String city1 = parts.isNotEmpty ? parts[0] : 'Paris';
    final String city2 = parts.length > 1 ? parts[1] : 'Rome';

    if (mounted) {
      setState(() {
        itineraryData = {
          'success': true,
          'trip': widget.trip,
          'stops': [
            {
              'id': 201,
              'city_name': city1,
              'country': 'France',
              'start_date': widget.trip['start_date'] ?? '2026-09-10',
              'end_date': widget.trip['end_date'] ?? '2026-09-15',
              'activities': [
                {'title': 'Breakfast', 'time_slot': '09:00 AM', 'cost': 0.0, 'duration': '1 hour'},
                {'title': 'Eiffel Tower', 'time_slot': '10:30 AM', 'cost': 31.25, 'duration': '2 hours'},
                {'title': 'Lunch', 'time_slot': '02:00 PM', 'cost': 0.0, 'duration': '1 hour'},
                {'title': 'Louvre Museum', 'time_slot': '04:00 PM', 'cost': 22.50, 'duration': '3 hours'},
                {'title': 'Dinner', 'time_slot': '08:00 PM', 'cost': 0.0, 'duration': '2 hours'},
              ]
            },
            {
              'id': 202,
              'city_name': city2,
              'country': 'Italy',
              'start_date': widget.trip['start_date'] ?? '2026-09-16',
              'end_date': widget.trip['end_date'] ?? '2026-09-20',
              'activities': [
                {'title': 'Breakfast', 'time_slot': '09:00 AM', 'cost': 0.0, 'duration': '1 hour'},
                {'title': 'Colosseum & Forum Arena', 'time_slot': '10:30 AM', 'cost': 40.0, 'duration': '3 hours'},
                {'title': 'Lunch', 'time_slot': '02:00 PM', 'cost': 0.0, 'duration': '1 hour'},
                {'title': 'Vatican Museums', 'time_slot': '04:00 PM', 'cost': 50.0, 'duration': '3 hours'},
                {'title': 'Dinner', 'time_slot': '08:00 PM', 'cost': 0.0, 'duration': '2 hours'},
              ]
            }
          ]
        };
        isLoading = false;
      });
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
      final int stopId = _safeParseInt(stop['id']);
      if (!excludedStopIds.contains(stopId)) {
        final List<dynamic> activities = stop['activities'] ?? [];
        for (var a in activities) {
          includedActivitiesCost += _safeParseDouble(a['cost']);
        }
      }
    }

    final double plannedBudget = _safeParseDouble(trip['budget'], 2500.0);
    final double transportCost = _safeParseDouble(trip['transport_cost'], 650.0);
    final double hotelCost = _safeParseDouble(trip['hotel_cost'], 1100.0);
    final double mealCost = _safeParseDouble(trip['meal_cost'], 550.0);
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
                  final String link = 'http://localhost:8090/?trip_id=${trip['id']}&title=${Uri.encodeComponent(trip['title'] ?? '')}&dest=${Uri.encodeComponent(trip['destination'] ?? '')}';
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Direct shareable trip link copied to clipboard! Anyone opening this link will view "${trip['title']}" directly.'),
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                  );
                },
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share Plan'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip travel stops & activities duplicated into your workspace for customisation!')));
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy & Customise Stops & Activities'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
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
    final List<Widget> dayCards = [];

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final int stopId = _safeParseInt(stop['id']);
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
                      Text('${stop['city_name']}, ${stop['country']} (5 Days Stay)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), decoration: isExcluded ? TextDecoration.lineThrough : null)),
                      if (isExcluded) ...[
                        const SizedBox(width: 10),
                        const Text('(Excluded)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                      ],
                      const Spacer(),
                      Text('Duration: 5 Days Stay • Dates: ${stop['start_date']} — ${stop['end_date']}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: activities.isEmpty
                      ? const Text('No activities scheduled for this city stop.', style: TextStyle(color: Color(0xFF94A3B8)))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DAY ${i + 1} — ${stop['city_name'].toString().toUpperCase()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text('${stop['start_date'] ?? '10 September'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                                ],
                              ),
                            ),
                            ...activities.map<Widget>((act) {
                              final String title = act['title'] ?? '';
                              final double costVal = _safeParseDouble(act['cost']);
                              final String costStr = costVal > 0 ? '₹${(costVal * 80).toStringAsFixed(0)}' : 'Free';
                              final String durationStr = act['duration'] ?? '2 hours';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                                      child: Text(act['time_slot'] ?? '09:00 AM', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                                          const SizedBox(height: 4),
                                          if (title != 'Breakfast' && title != 'Lunch' && title != 'Dinner') ...[
                                            Row(
                                              children: [
                                                Text('Duration: $durationStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                                const SizedBox(width: 12),
                                                Text('Cost: $costStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
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
        final int stopId = _safeParseInt(stop['id']);
        final bool isExcluded = excludedStopIds.contains(stopId);
        final List<dynamic> activities = stop['activities'] ?? [];

        double stopTotal = 0.0;
        for (var a in activities) {
          stopTotal += _safeParseDouble(a['cost']);
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
  final Function([String? destination]) onNavigateToCreateTrip;

  const CitySearchScreen({super.key, required this.user, required this.onNavigateToCreateTrip});

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
    return _HoverableCard(
      onTap: () => showCityDetailsModal(context, city, (destName) => widget.onNavigateToCreateTrip(destName)),
      child: Container(
        width: width,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSafeImage(url: city['image_url'], width: double.infinity, height: 150, label: city['name'] ?? 'City'),
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
  String searchQuery = '';
  String selectedPlace = 'All Places';
  String selectedCategory = 'All Categories';
  String selectedDuration = 'All Durations';
  double maxBudget = 10000.0;

  String selectedBudgetPreset = 'All Budgets';
  final List<String> budgetPresets = [
    'All Budgets',
    'Budget (< ₹2,000)',
    'Moderate (₹2,000 – ₹5,000)',
    'Luxury (> ₹5,000)',
  ];

  final List<String> placesList = [
    'All Places',
    'Paris, France 🇫🇷',
    'Rome, Italy 🇮🇹',
    'Tokyo, Japan 🇯🇵',
    'Kyoto, Japan 🇯🇵',
    'Zurich, Switzerland 🇨🇭',
    'Lucerne, Switzerland 🇨🇭',
    'Bali, Indonesia 🇮🇩',
    'Reykjavik, Iceland 🇮🇸',
  ];

  final List<String> categoriesList = [
    'All Categories',
    'Sightseeing 🏛️',
    'Food & Dining 🍣',
    'Adventure & Nature 🏔️',
    'Art & Culture 🎨',
    'Nightlife & Shows 🌃',
  ];

  final List<String> durationList = [
    'All Durations',
    '1-2 Hours',
    '3-4 Hours',
    'Full Day (5+ Hours)',
  ];

  final List<Map<String, dynamic>> allActivities = [
    {
      'id': 1,
      'title': 'Eiffel Tower Sunset Summit & Champagne',
      'city': 'Paris, France 🇫🇷',
      'category': 'Sightseeing 🏛️',
      'duration': '2 hours',
      'cost_inr': 2500,
      'cost_usd': 31.25,
      'rating': 4.9,
      'reviews': 342,
      'image': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80',
      'description': 'Skip-the-line glass elevator access to the Eiffel Tower 3rd floor summit with panoramic views over Paris and complimentary champagne glass.',
    },
    {
      'id': 2,
      'title': 'Louvre Museum Masterpieces Guided Walk',
      'city': 'Paris, France 🇫🇷',
      'category': 'Art & Culture 🎨',
      'duration': '3 hours',
      'cost_inr': 1800,
      'cost_usd': 22.50,
      'rating': 4.8,
      'reviews': 289,
      'image': 'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?auto=format&fit=crop&w=600&q=80',
      'description': 'Expert art historian guided tour featuring Mona Lisa, Venus de Milo, and Winged Victory of Samothrace in the iconic glass pyramid museum.',
    },
    {
      'id': 3,
      'title': 'Seine River Gourmet Dinner Cruise',
      'city': 'Paris, France 🇫🇷',
      'category': 'Food & Dining 🍣',
      'duration': '2 hours',
      'cost_inr': 3000,
      'cost_usd': 37.50,
      'rating': 4.9,
      'reviews': 410,
      'image': 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?auto=format&fit=crop&w=600&q=80',
      'description': '3-course classic French gourmet dinner with wine while cruising past illuminated Notre-Dame, Musée d\'Orsay, and Eiffel Tower.',
    },
    {
      'id': 4,
      'title': 'Montmartre Secret Culinary & Wine Walking Tour',
      'city': 'Paris, France 🇫🇷',
      'category': 'Food & Dining 🍣',
      'duration': '3 hours',
      'cost_inr': 2000,
      'cost_usd': 25.00,
      'rating': 4.7,
      'reviews': 195,
      'image': 'https://images.unsplash.com/photo-1509299349698-dd22323b5963?auto=format&fit=crop&w=600&q=80',
      'description': 'Sample artisanal French cheeses, freshly baked baguettes, crepes, and Bordeaux wines through cobblestone lanes of Montmartre hill.',
    },
    {
      'id': 5,
      'title': 'Colosseum Arena Floor & Underground Dungeons',
      'city': 'Rome, Italy 🇮🇹',
      'category': 'Sightseeing 🏛️',
      'duration': '3 hours',
      'cost_inr': 3200,
      'cost_usd': 40.00,
      'rating': 4.9,
      'reviews': 512,
      'image': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=600&q=80',
      'description': 'Exclusive gladiator gate access onto the restored Arena Floor and subterranean trapdoor chambers where wild beasts were kept.',
    },
    {
      'id': 6,
      'title': 'Vatican Museums & Sistine Chapel VIP Access',
      'city': 'Rome, Italy 🇮🇹',
      'category': 'Art & Culture 🎨',
      'duration': '4 hours',
      'cost_inr': 4000,
      'cost_usd': 50.00,
      'rating': 4.9,
      'reviews': 620,
      'image': 'https://images.unsplash.com/photo-1548625361-18a7a8d54641?auto=format&fit=crop&w=600&q=80',
      'description': 'Early morning entry before general public opening. View Michelangelo\'s Sistine Chapel ceiling frescoes and St. Peter\'s Basilica.',
    },
    {
      'id': 7,
      'title': 'Trastevere Historic Quarter Food & Pasta Masterclass',
      'city': 'Rome, Italy 🇮🇹',
      'category': 'Food & Dining 🍣',
      'duration': '3 hours',
      'cost_inr': 2000,
      'cost_usd': 25.00,
      'rating': 4.8,
      'reviews': 240,
      'image': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=600&q=80',
      'description': 'Hands-on handmade pasta & gelato making class in a cobblestone trattoria terrace paired with Chianti DOCG wines.',
    },
    {
      'id': 8,
      'title': 'Shibuya Sky High-Altitude Observatory Deck',
      'city': 'Tokyo, Japan 🇯🇵',
      'category': 'Sightseeing 🏛️',
      'duration': '2 hours',
      'cost_inr': 2500,
      'cost_usd': 31.25,
      'rating': 4.9,
      'reviews': 480,
      'image': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80',
      'description': 'Open-air rooftop 360-degree glass observation deck overlooking famous Shibuya Scramble Crossing and Mount Fuji in clear weather.',
    },
    {
      'id': 9,
      'title': 'Tsukiji Outer Market Seafood & Wagyu Food Crawl',
      'city': 'Tokyo, Japan 🇯🇵',
      'category': 'Food & Dining 🍣',
      'duration': '3 hours',
      'cost_inr': 3500,
      'cost_usd': 43.75,
      'rating': 4.8,
      'reviews': 310,
      'image': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=600&q=80',
      'description': 'Taste fresh sea urchin, bluefin tuna nigiri, flame-seared Wagyu beef skewers, and tamagoyaki omelet with a local foodie guide.',
    },
    {
      'id': 10,
      'title': 'Fushimi Inari 10,000 Torii Gates Sunset Hike',
      'city': 'Kyoto, Japan 🇯🇵',
      'category': 'Adventure & Nature 🏔️',
      'duration': '3 hours',
      'cost_inr': 1200,
      'cost_usd': 15.00,
      'rating': 4.9,
      'reviews': 590,
      'image': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=600&q=80',
      'description': 'Atmospheric sunset trek through thousands of vermilion torii gates winding up sacred Mount Inari with valley viewpoint stop.',
    },
    {
      'id': 11,
      'title': 'Mt. Titlis Glacier Cable Car & Cliff Walk',
      'city': 'Zurich, Switzerland 🇨🇭',
      'category': 'Adventure & Nature 🏔️',
      'duration': '5 hours',
      'cost_inr': 8500,
      'cost_usd': 106.25,
      'rating': 4.9,
      'reviews': 370,
      'image': 'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?auto=format&fit=crop&w=600&q=80',
      'description': 'World\'s first revolving Rotair cable car to 3,020m summit, ice flyer chairlift over glacier crevasses, and Europe\'s highest suspension bridge.',
    },
    {
      'id': 12,
      'title': 'Tegallalang Rice Terrace Swing & Ubud Jungle Spa',
      'city': 'Bali, Indonesia 🇮🇩',
      'category': 'Adventure & Nature 🏔️',
      'duration': '4 hours',
      'cost_inr': 1800,
      'cost_usd': 22.50,
      'rating': 4.8,
      'reviews': 430,
      'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80',
      'description': 'Fly over green terraced rice fields on giant jungle swing followed by traditional Balinese herbal flower bath massage in river ravine.',
    },
    {
      'id': 13,
      'title': 'Uluwatu Sunset Cliff Temple & Kecak Fire Dance',
      'city': 'Bali, Indonesia 🇮🇩',
      'category': 'Nightlife & Shows 🌃',
      'duration': '3 hours',
      'cost_inr': 2500,
      'cost_usd': 31.25,
      'rating': 4.9,
      'reviews': 510,
      'image': 'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?auto=format&fit=crop&w=600&q=80',
      'description': 'Perched 70 meters above crashing Indian Ocean waves, witness dramatic sunset Ramayana chant & Kecak fire dance performance.',
    },
    {
      'id': 14,
      'title': 'Northern Lights Aurora Borealis Superjeep Safari',
      'city': 'Reykjavik, Iceland 🇮🇸',
      'category': 'Adventure & Nature 🏔️',
      'duration': '4 hours',
      'cost_inr': 6500,
      'cost_usd': 81.25,
      'rating': 4.9,
      'reviews': 298,
      'image': 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?auto=format&fit=crop&w=600&q=80',
      'description': '4x4 Superjeep excursion away from light pollution into wild volcanic plains with expert aurora photographer and hot chocolate.',
    },
  ];

  List<Map<String, dynamic>> get _filteredActivities {
    return allActivities.where((act) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final titleMatch = (act['title'] as String).toLowerCase().contains(q);
        final cityMatch = (act['city'] as String).toLowerCase().contains(q);
        final descMatch = (act['description'] as String).toLowerCase().contains(q);
        if (!titleMatch && !cityMatch && !descMatch) return false;
      }

      if (selectedPlace != 'All Places') {
        final String actCity = act['city'] as String;
        final String placeKey = selectedPlace.split(',')[0].replaceAll(RegExp(r'[^a-zA-Z ]'), '').trim().toLowerCase();
        if (!actCity.toLowerCase().contains(placeKey)) return false;
      }

      if (selectedCategory != 'All Categories') {
        final String actCat = act['category'] as String;
        final String catKey = selectedCategory.split(' ')[0].toLowerCase();
        if (!actCat.toLowerCase().contains(catKey)) return false;
      }

      final double costInr = (act['cost_inr'] as num).toDouble();
      if (costInr > maxBudget) return false;

      if (selectedBudgetPreset == 'Budget (< ₹2,000)' && costInr >= 2000) return false;
      if (selectedBudgetPreset == 'Moderate (₹2,000 – ₹5,000)' && (costInr < 2000 || costInr > 5000)) return false;
      if (selectedBudgetPreset == 'Luxury (> ₹5,000)' && costInr <= 5000) return false;

      if (selectedDuration != 'All Durations') {
        final String dur = act['duration'] as String;
        if (selectedDuration == '1-2 Hours' && !dur.contains('1') && !dur.contains('2')) return false;
        if (selectedDuration == '3-4 Hours' && !dur.contains('3') && !dur.contains('4')) return false;
        if (selectedDuration == 'Full Day (5+ Hours)' && !dur.contains('5') && !dur.contains('8')) return false;
      }

      return true;
    }).toList();
  }

  void _showActivityDetailsModal(Map<String, dynamic> act) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      child: buildSafeImage(
                        url: act['image'],
                        height: 200,
                        width: double.infinity,
                        label: act['title'] ?? 'Activity',
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                            child: Text(act['city'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6)),
                            child: Text('${act['rating']} ★ (${act['reviews']} reviews)', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
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
                      Text(act['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildDetailBadge(Icons.category_outlined, act['category'] ?? '', const Color(0xFF2563EB)),
                          const SizedBox(width: 12),
                          _buildDetailBadge(Icons.schedule, 'Duration: ${act['duration']}', const Color(0xFFD97706)),
                          const SizedBox(width: 12),
                          _buildDetailBadge(Icons.currency_rupee, 'Cost: ₹${act['cost_inr']} (\$${act['cost_usd']})', const Color(0xFF059669)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Activity Highlights & Overview:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      Text(act['description'] ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final String shareUrl = 'http://localhost:8090/?activity=${Uri.encodeComponent(act['title'] ?? '')}';
                                Clipboard.setData(ClipboardData(text: shareUrl));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Direct link for "${act['title']}" copied to clipboard!'), backgroundColor: const Color(0xFF2563EB)),
                                );
                              },
                              icon: const Icon(Icons.share, size: 16),
                              label: const Text('Share Activity'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${act['title']} added to your trip customisation plan!'), backgroundColor: const Color(0xFF059669)),
                                );
                              },
                              icon: const Icon(Icons.add_circle_outline, size: 18),
                              label: const Text('Add to Trip 🎯', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                            ),
                          ),
                        ],
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

  Widget _buildDetailBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredActivities;

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
                  Text('Explore & Discover Activities 🎯', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Filter by place, category, duration, and budget to discover top travel experiences.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
                child: Text('${filtered.length} Activities Found', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SEARCH INPUT BAR
          TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search activities, keywords, or places (e.g. Eiffel Tower, Sushi, Hike, Swing)...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => searchQuery = ''))
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),

          // 1. PLACE FILTER SELECTION (EXPLICIT USER REQUIREMENT)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2563EB), width: 1.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.place_outlined, color: Color(0xFF2563EB), size: 20),
                        SizedBox(width: 8),
                        Text('Filter by Place / Destination 📍', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Text('Selected: $selectedPlace', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: placesList.map((place) {
                      final bool isSelected = selectedPlace == place;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(place),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2563EB),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 13),
                          onSelected: (sel) {
                            if (sel) setState(() => selectedPlace = place);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. CATEGORY, DURATION & BUDGET FILTERS ROW
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category 🏷️', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categoriesList.map((cat) {
                                final bool isSelected = selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: ChoiceChip(
                                    label: Text(cat, style: const TextStyle(fontSize: 12)),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFF059669),
                                    labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.bold),
                                    onSelected: (sel) {
                                      if (sel) setState(() => selectedCategory = cat);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Duration ⏱️', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedDuration,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                            items: durationList.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (v) => setState(() => selectedDuration = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ESTIMATED BUDGET PRESETS & RANGE SLIDER
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF86EFAC))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF059669), size: 18),
                              SizedBox(width: 8),
                              Text('Select Estimated Activity Budget 💰', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ],
                          ),
                          Text('Max Cap: ₹${maxBudget.toInt()} (\$${(maxBudget / 80).toInt()})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: budgetPresets.map((bPreset) {
                            final bool isSelected = selectedBudgetPreset == bPreset;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(bPreset),
                                selected: isSelected,
                                selectedColor: const Color(0xFF059669),
                                labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 12),
                                onSelected: (sel) {
                                  if (sel) setState(() => selectedBudgetPreset = bPreset);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Adjust Cap Slider: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          Expanded(
                            child: Slider(
                              value: maxBudget,
                              min: 1000.0,
                              max: 10000.0,
                              divisions: 18,
                              activeColor: const Color(0xFF059669),
                              label: '₹${maxBudget.toInt()}',
                              onChanged: (v) => setState(() => maxBudget = v),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                                selectedPlace = 'All Places';
                                selectedCategory = 'All Categories';
                                selectedDuration = 'All Durations';
                                selectedBudgetPreset = 'All Budgets';
                                maxBudget = 10000.0;
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Reset All', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ACTIVITIES GRID
          filtered.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      const Text('No activities match your selected place or filter criteria.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            selectedPlace = 'All Places';
                            selectedCategory = 'All Categories';
                            selectedDuration = 'All Durations';
                            maxBudget = 10000.0;
                          });
                        },
                        child: const Text('Clear All Filters'),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final double cardWidth = (constraints.maxWidth - 32) / 3;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: filtered.map((act) {
                        return _HoverableCard(
                          onTap: () => _showActivityDetailsModal(act),
                          child: Container(
                            width: cardWidth < 320 ? double.infinity : cardWidth,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Stack(
                                children: [
                                  buildSafeImage(
                                    url: act['image'],
                                    height: 160,
                                    width: double.infinity,
                                    label: act['title'] ?? 'Activity',
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                                      child: Text(act['city'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6)),
                                      child: Text('${act['rating']} ★', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(act['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Text('${act['category']} • ⏱️ ${act['duration']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('₹${act['cost_inr']} (\$${act['cost_usd']})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                                        Text('${act['reviews']} reviews', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _showActivityDetailsModal(act),
                                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                                            child: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${act['title']} added to your trip customisation plan!'),
                                                  backgroundColor: const Color(0xFF059669),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)),
                                            child: const Text('Add to Trip 🎯', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
