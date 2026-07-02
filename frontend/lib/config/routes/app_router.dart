import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/profile/profile_screen.dart';
import 'package:frontend/features/booking/presentation/user/pages/home_screen.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/driver_register_page.dart';
import '../../features/auth/presentation/pages/profile/account_details_screen.dart';
import '../../features/auth/presentation/pages/profile/edit__profile_screen.dart';
import '../../features/auth/presentation/pages/profile/privacy_policy_screen.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/booking/domain/entities/booking_entity.dart';
import '../../features/booking/presentation/driver/pages/driver_bookings_screen.dart';
import '../../features/booking/presentation/driver/pages/driver_home_screen.dart';
import '../../features/booking/presentation/user/pages/booking_details_screen.dart';
import '../../features/booking/presentation/user/pages/booking_history_detail_screen.dart';
import '../../features/booking/presentation/user/pages/booking_history_screen.dart';
import '../../features/booking/presentation/user/pages/destination_search_screen.dart';
import '../../features/booking/presentation/user/pages/driver_found_screen.dart';
import '../../features/booking/presentation/user/pages/driver_searching_screen.dart';
import '../../features/booking/presentation/driver/pages/driver_trip_screen.dart';
import '../../features/booking/presentation/driver/pages/driver_proof_of_delivery_screen.dart';
import '../../features/booking/presentation/user/pages/delivery_completed_screen.dart';
import '../../features/booking/presentation/user/pages/user_proof_of_delivery_screen.dart';
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
    GoRoute(
      path: RouteNames.driverRegister,
      builder: (context, state) => const DriverRegisterPage(),
    ),
    GoRoute(
      path: RouteNames.locationSearch,
      name: RouteNames.locationSearch,
      builder: (context, state) => LocationSearchScreen(
        initialLocation: state.extra as String?,
      ),
    ),
    GoRoute(
      path: RouteNames.driverSearching,
      name: RouteNames.driverSearching,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return DriverSearchingScreen(
          bookingData: data,
        );
      },
    ),
    GoRoute(
      path: RouteNames.bookingDetails,
      name: RouteNames.bookingDetails,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return BookingDetailsPage(
          pickupCoordinates: List<double>.from(data['pickupCoordinates']),
          dropoffCoordinates: List<double>.from(data['dropoffCoordinates']),

          pickupAddress: data['pickupAddress'],
          dropoffAddress: data['dropoffAddress'],

          goodsTypes: List<String>.from(data['goodsTypes']),
          selectedVehicle: data['selectedVehicle'],
        );
      },
    ),
    GoRoute(
      path: RouteNames.driverFound,
      name: RouteNames.driverFound,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return DriverFoundScreen(bookingData: data);
      },
    ),
    GoRoute(
      path: RouteNames.driverTrip,
      builder: (context, state) {
        return DriverTripScreen(
          bookingData:
          state.extra as Map<String, dynamic>,
        );
      },
    ),
    GoRoute(
      path: RouteNames.driverProofOfDelivery,
      builder: (context, state) {
        return DriverProofOfDeliveryScreen(
          bookingData:
          state.extra as Map<String, dynamic>,
        );
      },
    ),
    GoRoute(
      path: RouteNames.deliveryCompleted,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return DeliveryCompletedScreen(bookingData: data);
      },
    ),
    GoRoute(
      path: RouteNames.userProofOfDelivery,
      builder: (context, state) {
        return UserProofOfDeliveryScreen(
          bookingData: state.extra as Map<String, dynamic>,
        );
      },
    ),
    GoRoute(
      path: RouteNames.bookingHistoryDetail,
      builder: (context, state) {
        final booking = state.extra as BookingEntity;

        return BookingHistoryDetailScreen(
          booking: booking,
        );
      },
    ),
    // GoRoute(
    //   path: RouteNames.editProfile,
    //   builder: (context, state) => const EditProfileScreen(),
    // ),
    // GoRoute(
    //   path: RouteNames.accountDetails,
    //   builder: (context, state) => const AccountDetailsScreen(),
    // ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => DashboardScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.userHome,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'destination-search',
                  name: RouteNames.destinationSearch,
                  builder: (context, state) => const DestinationSearchScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.userBookings,
              builder: (context, state) =>
              const BookingHistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.userProfile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit-profile',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'account-details',
                  builder: (context, state) => const AccountDetailsScreen(),
                ),
                GoRoute(
                  path: 'privacy-policy',
                  builder: (context, state) => const PrivacyPolicyScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // Driver side
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          DriverDashboardScreen(
            navigationShell: navigationShell,
          ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.driverHome,
              builder: (context, state) =>
              const DriverHomeScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.driverBookings,
              builder: (context, state) =>
              const DriverBookingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);