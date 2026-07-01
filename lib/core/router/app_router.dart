import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/phone_otp_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/home/presentation/screens/discover_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/tickets/presentation/screens/tickets_screen.dart';
import '../../features/tickets/presentation/screens/ticket_detail_screen.dart';
import '../../features/tickets/presentation/screens/qr_scanner_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/interests_screen.dart';
import '../../features/profile/presentation/screens/saved_events_screen.dart';
import '../../features/profile/presentation/screens/privacy_screen.dart';
import '../../features/profile/presentation/screens/help_center_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

// ─── Route Names ──────────────────────────────────────────
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const phoneOtp = '/phone-otp';
  static const home = '/home';
  static const discover = '/home/discover';
  static const events = '/home/events';
  static const createEvent = '/home/create-event';
  static const chatList = '/home/chat';
  static const profile = '/home/profile';
  static const eventDetail = '/event/:eventId';
  static const ticketDetail = '/ticket/:ticketId';
  static const tickets = '/tickets';
  static const qrScanner = '/qr-scanner';
  static const chatRoom = '/chat/:chatId';
  static const editProfile = '/edit-profile';
  static const interests = '/interests';
  static const savedEvents = '/saved-events';
  static const privacy = '/privacy';
  static const helpCenter = '/help-center';
  static const notifications = '/notifications';
}

// ─── Router Provider ─────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: listenable,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      
      // PRO LEVEL: Sticky Session Logic
      final bool isLoggedIn = authState.maybeMap(
        data: (d) => d.value != null,
        error: (_) => authState.hasValue ? authState.value != null : false,
        loading: (_) => authState.hasValue ? authState.value != null : false,
        orElse: () => false,
      );

      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.phoneOtp ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      // ── Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      // ── Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) => _fadePage(const OnboardingScreen(), state),
      ),
      // ── Auth
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, state) => _slidePage(const LoginScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (_, state) => _slidePage(const RegisterScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneOtp,
        builder: (_, state) {
          final phone = state.extra as String? ?? '';
          return PhoneOtpScreen(phoneNumber: phone);
        },
      ),
      // ── Main Shell
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            redirect: (_, __) => AppRoutes.discover,
          ),
          GoRoute(
            path: AppRoutes.discover,
            pageBuilder: (_, state) =>
                _noTransitionPage(const DiscoverScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.events,
            pageBuilder: (_, state) =>
                _noTransitionPage(const EventsScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.createEvent,
            pageBuilder: (_, state) =>
                _noTransitionPage(const CreateEventScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.chatList,
            pageBuilder: (_, state) =>
                _noTransitionPage(const ChatListScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, state) =>
                _noTransitionPage(const ProfileScreen(), state),
          ),
        ],
      ),
      // ── Event Detail
      GoRoute(
        path: AppRoutes.eventDetail,
        pageBuilder: (_, state) {
          final eventId = state.pathParameters['eventId']!;
          return _slidePage(EventDetailScreen(eventId: eventId), state);
        },
      ),
      // ── Tickets
      GoRoute(
        path: AppRoutes.tickets,
        pageBuilder: (_, state) => _slidePage(const TicketsScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.ticketDetail,
        pageBuilder: (_, state) {
          final ticketId = state.pathParameters['ticketId']!;
          return _slidePage(TicketDetailScreen(ticketId: ticketId), state);
        },
      ),
      GoRoute(
        path: AppRoutes.qrScanner,
        builder: (_, __) => const QrScannerScreen(),
      ),
      // ── Chat Room
      GoRoute(
        path: AppRoutes.chatRoom,
        pageBuilder: (_, state) {
          final chatId = state.pathParameters['chatId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return _slidePage(
            ChatRoomScreen(
              chatId: chatId,
              recipientName: extra?['name'] ?? '',
              recipientAvatar: extra?['avatar'] ?? '',
            ),
            state,
          );
        },
      ),
      // ── Profile Actions
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (_, state) => _slidePage(const EditProfileScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.interests,
        pageBuilder: (_, state) => _slidePage(const InterestsScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.savedEvents,
        pageBuilder: (_, state) => _slidePage(const SavedEventsScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        pageBuilder: (_, state) => _slidePage(const PrivacyScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        pageBuilder: (_, state) => _slidePage(const HelpCenterScreen(), state),
      ),
      // ── Notifications
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (_, state) =>
            _slidePage(const NotificationsScreen(), state),
      ),
    ],
  );
});

// ─── Page Transition Helpers ─────────────────────────────
CustomTransitionPage _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage _slidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

NoTransitionPage _noTransitionPage(Widget child, GoRouterState state) {
  return NoTransitionPage(key: state.pageKey, child: child);
}

// ─── Router Refresh Notifier ─────────────────────────────
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}
