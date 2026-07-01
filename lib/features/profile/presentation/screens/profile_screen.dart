import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push(AppRoutes.editProfile)),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 6)),
                          child: AppAvatar(name: user.name, imageUrl: user.avatarUrl, size: 100),
                        ),
                        const SizedBox(height: 16),
                        Text(user.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(user.email, style: const TextStyle(color: Colors.grey)),
                        if (user.bio != null && user.bio!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(user.bio!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Stats Row
                  Row(
                    children: [
                      _StatItem(label: 'Saved', count: user.savedEvents.length, icon: Icons.bookmark_rounded, color: AppColors.primary, onTap: () => context.push(AppRoutes.savedEvents)),
                      const SizedBox(width: 16),
                      _StatItem(label: 'Tickets', count: user.registeredEvents.length, icon: Icons.confirmation_number_rounded, color: AppColors.success, onTap: () => context.push(AppRoutes.tickets)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  
                  // Menu Items
                  _ProfileMenuItem(icon: Icons.person_outline_rounded, label: 'Edit Profile', onTap: () => context.push(AppRoutes.editProfile)),
                  _ProfileMenuItem(icon: Icons.confirmation_number_outlined, label: 'My Tickets', onTap: () => context.push(AppRoutes.tickets)),
                  _ProfileMenuItem(icon: Icons.notifications_none_rounded, label: 'Notifications', onTap: () => context.push(AppRoutes.notifications)),
                  _ProfileMenuItem(icon: Icons.security_rounded, label: 'Privacy & Security', onTap: () => context.push(AppRoutes.privacy)),
                  _ProfileMenuItem(icon: Icons.help_outline_rounded, label: 'Help Center', onTap: () => context.push(AppRoutes.helpCenter)),
                  
                  const SizedBox(height: 32),
                  AppOutlinedButton(
                    label: 'Logout',
                    icon: Icons.logout_rounded,
                    onPressed: () => _showLogoutDialog(context, ref),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            ref.read(authControllerProvider.notifier).signOut();
            context.go(AppRoutes.login);
          }, child: const Text('Logout', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _StatItem({required this.label, required this.count, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withOpacity(0.1))),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(count.toString(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileMenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      onTap: onTap,
    );
  }
}
