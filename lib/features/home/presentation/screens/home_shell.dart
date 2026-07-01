import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';

class HomeShell extends ConsumerStatefulWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _selectedIndex = 0;

  static const _tabs = [
    AppRoutes.discover,
    AppRoutes.events,
    AppRoutes.createEvent,
    AppRoutes.chatList,
    AppRoutes.profile,
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
    context.go(_tabs[index]);
  }

  // Keep tab index in sync with router location
  int _getIndexFromLocation(String location) {
    if (location.startsWith(AppRoutes.discover)) return 0;
    if (location.startsWith(AppRoutes.events)) return 1;
    if (location.startsWith(AppRoutes.createEvent)) return 2;
    if (location.startsWith(AppRoutes.chatList)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _getIndexFromLocation(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _BottomNav(
        selectedIndex: idx,
        onTap: _onTap,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  static const _items = [
    (icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Discover'),
    (icon: Icons.event_outlined, activeIcon: Icons.event_rounded, label: 'Events'),
    (icon: Icons.add_circle_outline_rounded, activeIcon: Icons.add_circle_rounded, label: 'Create'),
    (icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Network'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isSelected = i == selectedIndex;
              final isCenter = i == 2;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: isCenter
                      ? Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        )
                      : AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? item.activeIcon : item.icon,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                                size: 24,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.label,
                                style: AppTypography.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
