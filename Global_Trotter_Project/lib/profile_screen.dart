import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(Map<String, dynamic> updatedUser) onProfileUpdated;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onProfileUpdated,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _photoUrlController;
  late String _selectedLanguage;

  bool isSaving = false;
  bool isLoadingSaved = true;
  List<dynamic> savedDestinations = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name'] ?? '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _photoUrlController = TextEditingController(
      text: widget.user['profile_photo_url'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    );
    _selectedLanguage = widget.user['language_preference'] ?? 'English';
    _loadSavedDestinations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedDestinations() async {
    setState(() => isLoadingSaved = true);
    final res = await ApiService.fetchSavedDestinations(widget.user['id']);
    if (res['success'] == true) {
      setState(() => savedDestinations = res['saved_destinations']);
    }
    setState(() => isLoadingSaved = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    final res = await ApiService.updateProfile(
      userId: widget.user['id'],
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      profilePhotoUrl: _photoUrlController.text.trim(),
      languagePreference: _selectedLanguage,
    );

    if (res['success'] == true) {
      widget.onProfileUpdated(res['user']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile settings updated successfully!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to update profile.')),
        );
      }
    }
    if (mounted) setState(() => isSaving = false);
  }

  Future<void> _confirmDeleteAccount() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text('Delete Account?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action is permanent and will delete all your travel itineraries, city stops, and saved data.',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final res = await ApiService.deleteAccount(widget.user['id']);
      if (res['success'] == true) {
        widget.onLogout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Profile & Settings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Manage your account credentials, preferences, saved destinations, and privacy controls.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT SIDE: PROFILE FORM & AVATAR
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(_photoUrlController.text),
                              backgroundColor: const Color(0xFF2563EB),
                              onForegroundImageError: (exception, stackTrace) {},
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.user['name'] ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                Text(widget.user['email'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (widget.user['is_admin'] == 1) ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    (widget.user['is_admin'] == 1) ? '👑 Administrator' : '✈️ Traveler Account',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: (widget.user['is_admin'] == 1) ? const Color(0xFF2563EB) : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Divider(color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 20),

                        const Text('Personal Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 16),

                        const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('Enter name', Icons.person_outline),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),

                        const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('Enter email', Icons.email_outlined),
                          validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                        ),
                        const SizedBox(height: 16),

                        const Text('Profile Photo URL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _photoUrlController,
                          onChanged: (v) => setState(() {}),
                          decoration: _inputDecoration('https://...', Icons.image_outlined),
                        ),
                        const SizedBox(height: 16),

                        const Text('Language Preference', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedLanguage,
                              items: ['English', 'Spanish', 'French', 'German', 'Japanese'].map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedLanguage = v);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : _saveProfile,
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // RIGHT SIDE: SAVED DESTINATIONS & PRIVACY CONTROLS
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // SAVED DESTINATIONS CARD
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Saved Destinations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                child: Text('${savedDestinations.length} saved', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          isLoadingSaved
                              ? const Center(child: CircularProgressIndicator())
                              : savedDestinations.isEmpty
                                  ? const Text('No saved destinations yet.', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)))
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: savedDestinations.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final dest = savedDestinations[index];
                                        return Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: Image.network(dest['image_url'] ?? '', width: 45, height: 45, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 45, height: 45, color: const Color(0xFFE2E8F0))),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(dest['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                    Text(dest['country'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                  ],
                                                ),
                                              ),
                                              const Icon(Icons.bookmark, color: Color(0xFF2563EB), size: 18),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PRIVACY & ACCOUNT DELETION CARD
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Privacy & Data Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () {
                              final String dataJson = jsonEncode(widget.user);
                              Clipboard.setData(ClipboardData(text: dataJson));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account JSON data copied to clipboard!')));
                            },
                            icon: const Icon(Icons.download_outlined, size: 16),
                            label: const Text('Download Personal Data'),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 14),
                          const Text('Danger Zone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                          const SizedBox(height: 6),
                          const Text('Deleting your account removes all saved trips and data permanently.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _confirmDeleteAccount,
                            icon: const Icon(Icons.delete_forever, size: 16),
                            label: const Text('Delete Account'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), foregroundColor: const Color(0xFFDC2626), elevation: 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    );
  }
}
