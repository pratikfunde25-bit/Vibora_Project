import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
        title: const Text('Help Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How can we help?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 32),
            _buildSearch(),
            const SizedBox(height: 40),
            _buildCategoryRow(['Payments', 'Events', 'Account']),
            const SizedBox(height: 16),
            _buildCategoryRow(['Registration', 'Tickets', 'Security']),
            const SizedBox(height: 48),
            const Text('Popular FAQs', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            _buildFaqItem('How do I request a refund?', 'You can request a refund through the ticket details screen if the event organizer has enabled it.'),
            _buildFaqItem('How to create an event?', 'Go to the Create Event tab from the home navigation and fill in the required details.'),
            _buildFaqItem('Is my payment secure?', 'Yes, all payments are handled securely via Razorpay with industry-standard encryption.'),
            const SizedBox(height: 40),
            _buildContactButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for articles...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
          border: InputBorder.none,
          icon: const Icon(Icons.search_rounded, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(List<String> categories) {
    return Row(
      children: categories.map((cat) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Icon(_getIcon(cat), color: AppColors.primary, size: 24),
              const SizedBox(height: 12),
              Text(cat, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  IconData _getIcon(String cat) {
    switch (cat) {
      case 'Payments': return Icons.payment_rounded;
      case 'Events': return Icons.event_rounded;
      case 'Account': return Icons.person_rounded;
      case 'Registration': return Icons.app_registration_rounded;
      case 'Tickets': return Icons.confirmation_number_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      childrenPadding: const EdgeInsets.all(16),
      collapsedIconColor: Colors.grey,
      iconColor: AppColors.primary,
      children: [
        Text(answer, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.5)),
      ],
    );
  }

  Widget _buildContactButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Still need help?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Our team is available 24/7 to assist you.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
