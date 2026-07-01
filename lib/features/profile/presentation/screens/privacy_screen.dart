import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Privacy & Security', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Data Protection',
              'Your data is encrypted using industry-standard AES-256 encryption. We never share your personal information with third parties without your explicit consent.',
              Icons.enhanced_encryption_rounded,
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Account Security',
              'We recommend enabling Two-Factor Authentication (2FA) to keep your account secure. Our systems monitor for suspicious login attempts 24/7.',
              Icons.shield_rounded,
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Privacy Controls',
              'You have full control over who can see your profile and event activity. You can manage these permissions in the visibility settings below.',
              Icons.visibility_rounded,
            ),
            const SizedBox(height: 40),
            _buildToggle('Two-Factor Authentication', true),
            _buildToggle('Email Notifications', true),
            _buildToggle('Profile Visibility', false),
            _buildToggle('Share Data with Organizers', true),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(description, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            Switch(
              value: value,
              onChanged: (v) {},
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
