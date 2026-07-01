import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../events/data/repositories/events_repository_impl.dart';
import '../../../events/presentation/widgets/event_card.dart';

final _eventsSearchQuery = StateProvider<String>((ref) => '');
final _eventsCategoryFilter = StateProvider<String>((ref) => 'All');

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});
  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(_eventsCategoryFilter);
    final events = ref.watch(eventsProvider(category == 'All' ? null : category));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: 'Search events...',
              leading: const Icon(Icons.search_rounded),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (v) => ref.read(_eventsSearchQuery.notifier).state = v,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 52,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.eventCategories.length,
              itemBuilder: (_, i) {
                final cat = AppConstants.eventCategories[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: cat,
                    isSelected: category == cat,
                    onTap: () =>
                        ref.read(_eventsCategoryFilter.notifier).state = cat,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: events.when(
              data: (list) {
                if (list.isEmpty) {
                  return const AppEmptyState(
                    title: 'No Events Found',
                    subtitle: 'Try adjusting your filters or search.',
                    icon: Icons.event_busy_rounded,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (_, i) => EventListCard(event: list[i], index: i),
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ShimmerBox(width: double.infinity, height: 108, borderRadius: 20),
                ),
              ),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }
}
