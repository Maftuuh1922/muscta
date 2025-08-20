import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/user/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String? displayName;
  final String? username;
  final String? bio;
  final String? website;

  const EditProfileScreen({
    super.key,
    this.displayName,
    this.username,
    this.bio,
    this.website,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameC;
  late final TextEditingController _usernameC;
  late final TextEditingController _bioC;
  late final TextEditingController _websiteC;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.displayName ?? '');
    _usernameC = TextEditingController(text: widget.username ?? '');
    _bioC = TextEditingController(text: widget.bio ?? '');
    _websiteC = TextEditingController(text: widget.website ?? '');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _usernameC.dispose();
    _bioC.dispose();
    _websiteC.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => const InputDecoration(
        // keep consistent with app theme
        filled: true,
        fillColor: AppColors.cardBackground,
        hintStyle: TextStyle(color: AppColors.mutedText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ).copyWith(hintText: hint);

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final rawUsername = _usernameC.text.trim();
    final normalized = rawUsername.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    if (normalized.isEmpty) {
      setState(() {
        _saving = false;
        _error = 'Username tidak boleh kosong';
      });
      return;
    }

    try {
      await UserService().updateProfile(
        displayName: _nameC.text.trim().isEmpty ? null : _nameC.text.trim(),
        username: normalized,
        bio: _bioC.text.trim(),
        website: _websiteC.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withOpacity(0.4), width: 0.7),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(height: 12),
            ],
            const Text('Name', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameC,
              style: const TextStyle(color: Colors.white),
              decoration: _dec('Your display name'),
            ),
            const SizedBox(height: 12),
            const Text('Username', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _usernameC,
              style: const TextStyle(color: Colors.white),
              decoration: _dec('username (a-z, 0-9, _)'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hanya huruf kecil, angka, dan underscore. Akan dinormalisasi otomatis.',
              style: TextStyle(color: AppColors.mutedText, fontSize: 11),
            ),
            const SizedBox(height: 12),
            const Text('Bio', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _bioC,
              minLines: 3,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: _dec('Tell something about you'),
            ),
            const SizedBox(height: 12),
            const Text('Website', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _websiteC,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.url,
              decoration: _dec('https://example.com'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
