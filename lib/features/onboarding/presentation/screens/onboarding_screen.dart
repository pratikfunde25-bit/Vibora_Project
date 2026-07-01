import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_widgets.dart';

class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}

const _pages = [
  _OnboardingPage(
    title: 'Discover Amazing Events',
    subtitle:
        'Explore hackathons, workshops, conferences and cultural events near you — all in one place.',
    icon: Icons.explore_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  _OnboardingPage(
    title: 'Register & Get Tickets',
    subtitle:
        'Seamless registration with QR-based digital tickets. Pay securely and get instant confirmation.',
    icon: Icons.confirmation_number_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFFFF6B6B), Color(0xFFFFBE0B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  _OnboardingPage(
    title: 'Network & Connect',
    subtitle:
        'Meet like-minded people, chat with attendees, and build your professional network around events.',
    icon: Icons.people_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF4ECDC4), Color(0xFF6C63FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingSeen, true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Pages ──────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _PageContent(page: _pages[i]),
          ),

          // ── Skip button ─────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: TextButton(
              onPressed: _finish,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ── Bottom Controls ─────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 32,
            right: 32,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white38,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                    spacing: 6,
                  ),
                ),
                const SizedBox(height: 32),
                if (_currentPage < _pages.length - 1)
                  AppPrimaryButton(
                    label: 'Next',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    ),
                  )
                else
                  AppPrimaryButton(
                    label: 'Get Started',
                    icon: Icons.bolt_rounded,
                    onPressed: _finish,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 100, color: Colors.white),
              )
                  .animate()
                  .scale(begin: const Offset(0.7, 0.7), duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),
              const Spacer(),
              Text(
                page.title,
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              Text(
                page.subtitle,
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
