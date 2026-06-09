import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/profile/profile_screen.dart';
import 'package:frontend/features/booking/presentation/user/pages/home_screen.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/driver_register_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/booking/presentation/driver/pages/driver_bookings_screen.dart';
import '../../features/booking/presentation/driver/pages/driver_home_screen.dart';
import '../../features/booking/presentation/user/pages/booking_details_screen.dart';
import '../../features/booking/presentation/user/pages/destination_search_screen.dart';
import '../../features/booking/presentation/user/pages/driver_searching_screen.dart';
import '../../features/booking/presentation/user/pages/location_search_screen.dart';
import '../../features/dashboard/presentation/page/dashboard_screen.dart';
import '../../features/driver_dashboard/presentation/page/driver_dashboard_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/role_selection/presentation/role_selection_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'route_names.dart';
import 'package:flutter/material.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RouteNames.roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) {
        final chosenRole = state.extra as String? ?? 'user';
        return RegisterPage(role: chosenRole);
      },
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) {
        final role = state.extra as String? ?? 'user';

        return LoginPage(
          role: role,
        );
      },
    ),
);