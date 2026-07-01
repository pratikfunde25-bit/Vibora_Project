import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Clear All', style: TextStyle(color: AppColors.primary))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotification(
            context,
            'Registration Successful!',
            'You are now registered for Global Tech Summit 2024. Your ticket is ready.',
            '2 mins ago',
            Icons.check_circle_rounded,
            AppColors.success,
          ),
          _buildNotification(
            context,
            'New Message',
            'Someone posted in the Hackathon Community Discussion.',
            '1 hour ago',
            Icons.chat_bubble_rounded,
            AppColors.primary,
          ),
          _buildNotification(
            context,
            'Event Reminder',
            'AI Workshop starts in 30 minutes at Main Hall.',
            '2 hours ago',
            Icons.alarm_rounded,
            Colors.orange,
          ),
          _buildNotification(
            context,
            'Profile Updated',
            'Your bio was successfully updated.',
            'Yesterday',
            Icons.person_rounded,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildNotification(BuildContext context, String title, String msg, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
                    const SizedBox(width: 8),
                    Text(time, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(msg, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
