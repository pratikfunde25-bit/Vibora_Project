import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../events/data/repositories/events_repository_impl.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../../events/presentation/widgets/event_card.dart';

// ─── Selected Category Provider ───────────────────────────
final _selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final _searchQueryProvider = StateProvider<String>((ref) => '');

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final featured = ref.watch(featuredEventsProvider);
    final events = ref.watch(eventsProvider(selectedCategory == 'All' ? null : selectedCategory));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good ${_greeting()}!',
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
                Text(
                  user?.name.split(' ').first ?? 'Explorer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => context.push(AppRoutes.notifications),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      top: -2, right: -2,
                      child: Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.profile),
                  child: AppAvatar(
                    imageUrl: user?.avatarUrl,
                    name: user?.name ?? 'U',
                    size: 36,
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar ────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.events),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text(
                            'Search events, places...',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                // ── Categories ────────────────────────────
                const SizedBox(height: 20),
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.eventCategories.length,
                    itemBuilder: (_, i) {
                      final cat = AppConstants.eventCategories[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CategoryChip(
                          label: cat,
                          isSelected: selectedCategory == cat,
                          onTap: () => ref.read(_selectedCategoryProvider.notifier).state = cat,
                          color: i == 0
                              ? AppColors.primary
                              : (AppColors.categoryColors[cat] ?? AppColors.primary),
                        ),
                      );
                    },
                  ),
                ),

                // ── Featured ──────────────────────────────
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: '✨ Featured Events',
                    actionLabel: 'See all',
                    onAction: () => context.go(AppRoutes.events),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 220,
                  child: featured.when(
                    data: (list) => list.isEmpty
                        ? _buildFeaturedShimmer()
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: list.length,
                            itemBuilder: (_, i) =>
                                FeaturedEventCard(event: list[i], index: i),
                          ),
                    loading: () => _buildFeaturedShimmer(),
                    error: (_, __) => const Center(child: Text('Failed to load')),
                  ),
                ),

                // ── All Events ────────────────────────────
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: '🎯 Upcoming Events',
                    actionLabel: 'View all',
                    onAction: () => context.go(AppRoutes.events),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          // ── Events List ───────────────────────────────────
          events.when(
            data: (list) => list.isEmpty
                ? const SliverToBoxAdapter(
                    child: AppEmptyState(
                      title: 'No events found',
                      subtitle: 'Try a different category or check back later.',
                      icon: Icons.event_busy_rounded,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) => EventListCard(event: list[i], index: i),
                    ),
                  ),
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: 5,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ShimmerBox(width: double.infinity, height: 110, borderRadius: 20),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 20),
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(right: 16),
        child: ShimmerBox(width: 300, height: 220, borderRadius: 24),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
