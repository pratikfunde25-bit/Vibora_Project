import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:event_connect/core/theme/app_colors.dart';
import 'package:event_connect/shared/widgets/app_widgets.dart';
import 'package:event_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:event_connect/features/events/domain/entities/event_entity.dart';
import 'package:event_connect/features/events/presentation/controllers/event_controller.dart';
import 'package:event_connect/features/events/data/repositories/events_repository_impl.dart';
import 'package:event_connect/core/services/payment_service.dart';
import 'package:event_connect/features/chat/presentation/controllers/chat_controller.dart';
import 'package:event_connect/core/constants/app_constants.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));
    final user = ref.watch(authControllerProvider).valueOrNull;

    return eventAsync.when(
      data: (e) {
        final catColor = AppColors.categoryColors[e.category.name] ?? AppColors.primary;
        final isSaved = user?.savedEvents.contains(e.id) ?? false;
        final isRegistered = user?.registeredEvents.contains(e.id) ?? false;
        
        final catName = e.category.name.toLowerCase();
        final images = AppConstants.categoryImages[catName] ?? AppConstants.categoryImages['other']!;
        final fallbackUrl = images[e.id.hashCode % images.length];

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildBanner(e, catColor),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.8)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                    onPressed: () async {
                      final chatId = await ref.read(chatControllerProvider.notifier).getOrCreateCommunityChat(e.id, e.title);
                      context.push('/chat/$chatId', extra: {'name': '${e.title} Community'});
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      if (user?.id == null) return;
                      ref.read(eventControllerProvider.notifier).toggleSaveEvent(e.id, user!.id);
                    },
                    icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, color: isSaved ? const Color(0xFF4CAF50) : Colors.white),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(50)),
                        child: Text(e.category.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 16),
                      Text(e.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 24),
                      _DetailRow(icon: Icons.calendar_today_rounded, title: DateFormat('EEEE, d MMMM y').format(e.startDate), subtitle: '${DateFormat('jm').format(e.startDate)} - ${DateFormat('jm').format(e.endDate)}'),
                      const SizedBox(height: 20),
                      _DetailRow(icon: Icons.location_on_rounded, title: e.venue, subtitle: 'Tap to see on map'),
                      const SizedBox(height: 32),
                      Text('About Event', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Text(e.description, style: const TextStyle(height: 1.6, color: Colors.grey, fontSize: 15)),
                      const SizedBox(height: 32),
                      
                      // Community Hub Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  child: const Icon(Icons.groups_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Community Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                                      Text('Join ${e.registeredCount} others in discussion', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final chatId = await ref.read(chatControllerProvider.notifier).getOrCreateCommunityChat(e.id, e.title);
                                    context.push('/chat/$chatId', extra: {'name': '${e.title} Community'});
                                  },
                                  child: const Text('Join', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Price', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(e.isFree ? 'FREE' : '₹${e.price.toStringAsFixed(0)}', style: TextStyle(color: catColor, fontWeight: FontWeight.w900, fontSize: 20)),
                  ],
                ),
                const SizedBox(width: 24),
                if (isRegistered) ...[
                  AppPrimaryButton(
                    label: '',
                    icon: Icons.chat_bubble_rounded,
                    onPressed: () async {
                      final chatId = await ref.read(chatControllerProvider.notifier).getOrCreateCommunityChat(e.id, e.title);
                      context.push('/chat/$chatId', extra: {'name': '${e.title} Community'});
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: AppPrimaryButton(
                    label: isRegistered 
                        ? 'View Ticket' 
                        : (e.isFree ? 'Register Now' : 'Pay ₹${e.price.toStringAsFixed(0)} & Register'),
                    onPressed: () {
                      if (isRegistered) {
                        context.push('/tickets');
                      } else {
                        _handleRegistration(context, ref, e);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  void _handleRegistration(BuildContext context, WidgetRef ref, EventEntity e) {
    if (e.isFree) {
      _showFreeRegistrationDialog(context, ref, e);
    } else {
      // PRO LEVEL: Start Razorpay Flow
      ref.read(paymentServiceProvider).startPayment(
        context: context,
        event: e,
      );
    }
  }

  void _showFreeRegistrationDialog(BuildContext context, WidgetRef ref, EventEntity e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Registration'),
        content: Text('Do you want to register for ${e.title}? This event is FREE.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              final repo = ref.read(eventsRepositoryProvider);
              await repo.registerForEvent(e.id, user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful!')));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _DetailRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

final eventByIdProvider = FutureProvider.family<EventEntity, String>((ref, id) async {
  final repo = ref.read(eventsRepositoryProvider);
  final result = await repo.getEventById(id);
  return result.fold((l) => throw l, (r) => r);
});

Widget _buildBanner(EventEntity e, Color catColor) {
  final catName = e.category.name.toLowerCase();
  final images = AppConstants.categoryImages[catName] ?? AppConstants.categoryImages['other']!;
  final fallbackUrl = images[e.id.hashCode % images.length];
  final url = e.bannerUrl;
  if (url != null && url.startsWith('local://')) {
    final path = url.replaceFirst('local://', '');
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => CachedNetworkImage(imageUrl: fallbackUrl, fit: BoxFit.cover),
    );
  }
  return CachedNetworkImage(
    imageUrl: (url != null && url.isNotEmpty) ? url : fallbackUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Container(color: catColor.withOpacity(0.1), child: const Center(child: CircularProgressIndicator())),
    errorWidget: (context, url, error) => CachedNetworkImage(imageUrl: fallbackUrl, fit: BoxFit.cover),
  );
}
