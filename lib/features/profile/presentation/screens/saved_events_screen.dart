import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../events/data/repositories/events_repository_impl.dart';
import '../../../events/presentation/widgets/event_card.dart';

class SavedEventsScreen extends ConsumerWidget {
  const SavedEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final savedEventIds = user.savedEvents;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Events')),
      body: savedEventIds.isEmpty
          ? const AppEmptyState(
              title: 'No saved events',
              subtitle: 'Events you bookmark will appear here.',
              icon: Icons.bookmark_outline_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: savedEventIds.length,
              itemBuilder: (context, index) {
                // We need to fetch each event by ID
                final eventAsync = ref.watch(eventByIdProvider(savedEventIds[index]));
                
                return eventAsync.when(
                  data: (event) => EventListCard(event: event, index: index),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: ShimmerBox(width: double.infinity, height: 100),
                  ),
                  error: (e, __) => const SizedBox.shrink(),
                );
              },
            ),
    );
  }
}

final eventByIdProvider = FutureProvider.family<dynamic, String>((ref, id) async {
  final repo = ref.read(eventsRepositoryProvider);
  final result = await repo.getEventById(id);
  return result.fold((l) => throw l, (r) => r);
});
