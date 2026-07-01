import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:event_connect/core/theme/app_colors.dart';
import 'package:event_connect/shared/widgets/app_widgets.dart';
import 'package:event_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:event_connect/features/events/data/repositories/events_repository_impl.dart';
import 'package:event_connect/features/events/domain/entities/event_entity.dart';

// ─── Professional Category Image Fallbacks ────────────────
const Map<EventCategory, String> _categoryImages = {
  EventCategory.hackathon: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=1000&auto=format&fit=crop',
  EventCategory.workshop: 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=1000&auto=format&fit=crop',
  EventCategory.conference: 'https://images.unsplash.com/photo-1540575861501-7ad060e39fe5?q=80&w=1000&auto=format&fit=crop',
  EventCategory.cultural: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1000&auto=format&fit=crop',
  EventCategory.sports: 'https://images.unsplash.com/photo-1461896756985-2346a8b16f9b?q=80&w=1000&auto=format&fit=crop',
  EventCategory.techTalk: 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?q=80&w=1000&auto=format&fit=crop',
  EventCategory.corporate: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1000&auto=format&fit=crop',
  EventCategory.networking: 'https://images.unsplash.com/photo-1528605248644-14dd04022da1?q=80&w=1000&auto=format&fit=crop',
  EventCategory.webinar: 'https://images.unsplash.com/photo-1588196749597-9ff075ee6b5b?q=80&w=1000&auto=format&fit=crop',
  EventCategory.other: 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1000&auto=format&fit=crop',
};

class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Tickets'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Upcoming'), Tab(text: 'History')],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
          ),
        ),
        body: userAsync.when(
          data: (user) {
            if (user == null) return const Center(child: Text('Please login to see tickets'));
            
            return TabBarView(
              children: [
                _TicketList(eventIds: user.registeredEvents, isUpcoming: true),
                _TicketList(eventIds: user.registeredEvents, isUpcoming: false),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _TicketList extends ConsumerWidget {
  final List<String> eventIds;
  final bool isUpcoming;
  const _TicketList({required this.eventIds, required this.isUpcoming});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (eventIds.isEmpty) {
      return AppEmptyState(
        title: isUpcoming ? 'No Tickets Yet' : 'No Past Events',
        subtitle: isUpcoming ? 'Find events to join and your tickets will appear here.' : 'Events you attend will be archived here.',
        icon: isUpcoming ? Icons.confirmation_number_rounded : Icons.history_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: eventIds.length,
      itemBuilder: (context, index) {
        final eventId = eventIds[index];
        final eventAsync = ref.watch(eventByIdProvider(eventId));

        return eventAsync.when(
          data: (event) {
            final now = DateTime.now();
            // Refined: If event is today or in future, it's upcoming
            final isEventUpcoming = event.startDate.isAfter(now.subtract(const Duration(hours: 24)));
            
            if (isUpcoming != isEventUpcoming) return const SizedBox.shrink();
            
            return _TicketCard(event: event, userId: ref.read(currentUserProvider)?.id ?? '');
          },
          loading: () => const Padding(padding: EdgeInsets.only(bottom: 16), child: ShimmerBox(width: double.infinity, height: 120)),
          error: (e, __) => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final EventEntity event;
  final String userId;
  const _TicketCard({required this.event, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.category.name.toUpperCase(), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('${event.startDate.day} ${_month(event.startDate)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(event.venue, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              height: 80,
              color: Colors.grey.withOpacity(0.2),
            ),
            GestureDetector(
              onTap: () => context.push('/ticket/${event.id}_$userId'),
              child: Container(
                width: 100,
                color: AppColors.primary.withOpacity(0.03),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: QrImageView(
                      data: 'ticket_${event.id}_$userId',
                      version: QrVersions.auto,
                      size: 70,
                      backgroundColor: Colors.transparent,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Colors.white),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return m[dt.month - 1];
  }
}

final eventByIdProvider = FutureProvider.family<EventEntity, String>((ref, id) async {
  final repo = ref.read(eventsRepositoryProvider);
  final result = await repo.getEventById(id);
  return result.fold((l) => throw l, (r) => r);
});
