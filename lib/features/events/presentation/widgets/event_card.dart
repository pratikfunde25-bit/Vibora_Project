import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/event_entity.dart';
import '../controllers/event_controller.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_widgets.dart';

// ─────────────────────────────────────────────────────────
//  FEATURED EVENT CARD
// ─────────────────────────────────────────────────────────
class FeaturedEventCard extends ConsumerWidget {
  final EventEntity event;
  final int index;

  const FeaturedEventCard({super.key, required this.event, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catColor = AppColors.categoryColors[event.category.name] ?? AppColors.primary;
    final user = ref.watch(authControllerProvider).valueOrNull;
    final isSaved = user?.savedEvents.contains(event.id) ?? false;

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: catColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _EventBanner(eventId: event.id, imageUrl: event.bannerUrl, catColor: catColor, category: event.category),
              Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.85)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
              
              Positioned(
                top: 16, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: event.isFree ? const Color(0xFF4CAF50) : Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                  ),
                  child: Text(
                    event.isFree ? 'FREE' : '₹${event.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
              ),
              
              Positioned(
                top: 16, right: 16,
                child: GestureDetector(
                  onTap: () {
                    if (user?.id == null) return;
                    ref.read(eventControllerProvider.notifier).toggleSaveEvent(event.id, user!.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSaved ? const Color(0xFF4CAF50) : Colors.black45,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 20, left: 20, right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(50)),
                      child: Text(event.category.name.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 8),
                    Text(event.title, style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(child: Text(event.venue, style: AppTypography.bodySmall.copyWith(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 80).ms).fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }
}

// ─────────────────────────────────────────────────────────
//  COMPACT EVENT CARD
// ─────────────────────────────────────────────────────────
class EventListCard extends ConsumerWidget {
  final EventEntity event;
  final int index;

  const EventListCard({super.key, required this.event, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final isSaved = user?.savedEvents.contains(event.id) ?? false;
    final catColor = AppColors.categoryColors[event.category.name] ?? AppColors.primary;

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 90, height: 90,
                child: _EventBanner(eventId: event.id, imageUrl: event.bannerUrl, catColor: catColor, category: event.category),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(event.category.name, style: AppTypography.labelSmall.copyWith(color: catColor, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (user?.id == null) return;
                          ref.read(eventControllerProvider.notifier).toggleSaveEvent(event.id, user!.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSaved ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSaved ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isSaved ? const Color(0xFF4CAF50) : Colors.grey.shade600,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(event.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(DateFormat('d MMM').format(event.startDate), style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
                      const SizedBox(width: 12),
                      Text(event.isFree ? 'FREE' : '₹${event.price.toStringAsFixed(0)}', style: AppTypography.labelSmall.copyWith(color: event.isFree ? const Color(0xFF4CAF50) : AppColors.primary, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0);
  }
}

// ─────────────────────────────────────────────────────────
//  IMAGE HANDLER WITH PROFESSIONAL FALLBACKS
// ─────────────────────────────────────────────────────────
class _EventBanner extends StatelessWidget {
  final String eventId;
  final String? imageUrl;
  final Color catColor;
  final EventCategory category;

  const _EventBanner({required this.eventId, this.imageUrl, required this.catColor, required this.category});

  @override
  Widget build(BuildContext context) {
    final catName = category.name.toLowerCase();
    final images = AppConstants.categoryImages[catName] ?? AppConstants.categoryImages['other']!;
    final fallbackUrl = images[eventId.hashCode % images.length];
    
    // Handle Local Storage Workaround
    if (imageUrl != null && imageUrl!.startsWith('local://')) {
      final path = imageUrl!.replaceFirst('local://', '');
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => CachedNetworkImage(imageUrl: fallbackUrl, fit: BoxFit.cover),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: (imageUrl != null && imageUrl!.isNotEmpty) ? imageUrl! : fallbackUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: catColor.withOpacity(0.1), child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
      errorWidget: (context, url, error) => CachedNetworkImage(imageUrl: fallbackUrl, fit: BoxFit.cover),
    );
  }
}
