import 'package:go_router/go_router.dart';
import 'package:workpleis/core/widget/global_snack_bar.dart';
import 'package:workpleis/features/auth/screens/customer/screen/customer_auth_screen.dart';
import 'package:workpleis/features/auth/screens/freelancer/screen/freelancer_auth_screen.dart';
import 'package:workpleis/features/auth/screens/role/screen/role_selection_screen.dart';
import 'package:workpleis/features/auth/screens/technician/screen/internal_auth_screen.dart';
import 'package:workpleis/features/customer/model/customer_dashboard_args.dart';
import 'package:workpleis/features/customer/screen/Customer_guest_home_screen.dart';
import 'package:workpleis/features/customer/screen/customer_bookings_screen.dart';
import 'package:workpleis/features/customer/screen/customer_dashboard_screen.dart';
import 'package:workpleis/features/customer/screen/customer_edit_profile.dart';
import 'package:workpleis/features/customer/screen/map.dart';
import 'package:workpleis/features/customer/screen/profile/screen/customer_profile_screen.dart';
import 'package:workpleis/features/erning/screen/freelancer_earnings_screen.dart';
import 'package:workpleis/features/erning/screen/payout_request_screen.dart';
import 'package:workpleis/features/erning/screen/technician_earningsScreen.dart';
import 'package:workpleis/features/freelancer_pages/screen/freelancer_home_screen.dart';
import 'package:workpleis/features/freelancer_pages/screen/freelarcer_job_screen.dart';
import 'package:workpleis/features/freelancer_pages/screen/profile/screen/freelancer_profile_screen.dart';
import 'package:workpleis/features/internal_technician/screen/job/screen/internal_jobs.dart';
import 'package:workpleis/features/internal_technician/screen/profile/screen/internal_job_profile.dart';
import 'package:workpleis/features/nav_bar/screen/bottom_nav_bar.dart';
import 'package:workpleis/features/nav_bar/screen/freelancer_bottom_nav_bar.dart';
import 'package:workpleis/features/splashScreen/screen/splashScreen.dart';

import '../features/freelancer_pages/screen/freelancer_edit_profile.dart';
import '../features/internal_technician/screen/internal_technician_home.dart';
import '../features/nav_bar/screen/internal_bottom_nav_bar.dart';
import '../features/shared/screen/edit_profile_screen.dart';
import 'error_screen.dart';

class AppRouter {
  static final String initial = SplashScreen.routeName;
  static final GoRouter appRouter = GoRouter(
    initialLocation: initial,
    errorBuilder: (context, state) {
      final String badPath = state.uri.toString() ?? state.uri.toString() ?? '';
      return CustomGoErrorPage(
        location: badPath,
        error: state.error,
        onRetry: () => context.go(initial),
        onReport: () {
          GlobalSnackBar.show(
            context,
            title: "We're sorry",
            message: "'Thanks, we'll look into this.'",
          );
        },
      );
    },

    routes: <RouteBase>[
      // GoRoute(
      //   path: CustomerLoginSceled.routeName,
      //   name: CustomerLoginSceled.routeName,
      //   builder: (context, state) => const CustomerLoginSceled(),
      // ),
      // GoRoute(
      //   path: PhoneLoginScreen.routeName,
      //   name: PhoneLoginScreen.routeName,
      //   builder: (context, state) => const PhoneLoginScreen(),
      // ),
      // GoRoute(
      //   path: OtpVerifyScreen.routeName,
      //   name: OtpVerifyScreen.routeName,
      //   builder: (context, state) => const OtpVerifyScreen(),
      // ),
      // GoRoute(
      //   path: CustomerCreateAccountScreen.routeName,
      //   name: CustomerCreateAccountScreen.routeName,
      //   builder: (context, state) => const CustomerCreateAccountScreen(),
      // ),
      GoRoute(
        path: SplashScreen.routeName,
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: GuestHomeScreen.routeName,
        name: GuestHomeScreen.routeName,
        builder: (context, state) => const GuestHomeScreen(),
      ),
      GoRoute(
        path: CustomerAuthScreen.routeName,
        name: CustomerAuthScreen.routeName,
        builder: (context, state) => const CustomerAuthScreen(),
      ),
      // GoRoute(
      //   path: CustomerMainShell.routeName,
      //   name: CustomerMainShell.routeName,
      //   builder: (context, state) => const CustomerMainShell(),
      // ),
      // GoRoute(
      //   path: GuestProfileScreen.routeName,
      //   name: GuestProfileScreen.routeName,
      //   builder: (context, state) => const GuestProfileScreen(),
      // ),
      //Internal Technician flow;
      GoRoute(
        path: InternalDashboardV2Screen.routeName,
        name: InternalDashboardV2Screen.routeName,
        builder: (context, state) => const InternalDashboardV2Screen(),
      ),

      GoRoute(
        path: InternalBottomNavBar.routeName,
        name: InternalBottomNavBar.routeName,
        builder: (context, state) => const InternalBottomNavBar(),
      ),

      GoRoute(
        path: InternalJobs.routeName,
        name: InternalJobs.routeName,
        builder: (context, state) => const InternalJobs(),
      ),

      GoRoute(
        path: InternalJobProfile.routeName,
        name: InternalJobProfile.routeName,
        builder: (context, state) => const InternalJobProfile(),
      ),

      GoRoute(
        path: Earningsscreen.routeName,
        name: Earningsscreen.routeName,
        builder: (context, state) => const Earningsscreen(),
      ),

      GoRoute(
        path: FreelancerBottomNavBar.routeName,
        name: FreelancerBottomNavBar.routeName,
        builder: (context, state) => const FreelancerBottomNavBar(),
      ),

      GoRoute(
        path: FreelancerHomeScreen.routeName,
        name: FreelancerHomeScreen.routeName,
        builder: (context, state) => const FreelancerHomeScreen(),
      ),

      GoRoute(
        path: FreelarcerJobScreen.routeName,
        name: FreelarcerJobScreen.routeName,
        builder: (context, state) => const FreelarcerJobScreen(),
      ),

      GoRoute(
        path: FreelancerEarningsScreen.routeName,
        name: FreelancerEarningsScreen.routeName,
        builder: (context, state) => const FreelancerEarningsScreen(),
      ),

      GoRoute(
        path: FreelancerProfileScreen.routeName,
        name: FreelancerProfileScreen.routeName,
        builder: (context, state) => const FreelancerProfileScreen(),
      ),

      GoRoute(
        path: RoleSelectionScreen.routeName,
        builder: (context, state) => RoleSelectionScreen(
          onRoleSelect: (role) {
            if (role == UserRole.customer) {
              // ✅ IMPORTANT: এখন সরাসরি Auth screen না, shell e জাও
              context.go(CustomerAppScreen.routeName);
            } else if (role == UserRole.freelancer) {
              context.go(FreelancerAuthScreen.routeName);
            } else {
              context.go(InternalAuthScreen.routeName);
            }
          },
        ),
      ),
      GoRoute(
        path: FreelancerAuthScreen.routeName,
        builder: (context, state) {
          return FreelancerAuthScreen(
            onAuthComplete: (user) {
              // login/signup successful -> kothay jabe?
              // ekhane ekta freelancer home / bottom nav thakle oikhane pathao
              // example:
              // context.go(FreelancerMainShell.routeName);
            },
            onBack: () {
              // niche white button -> back to role selection
              context.go(RoleSelectionScreen.routeName);
            },
          );
        },
      ),
      GoRoute(
        path: InternalAuthScreen.routeName,
        name: InternalAuthScreen.routeName,
        builder: (context, state) => const InternalAuthScreen(),
      ),
      GoRoute(
        path: CustomerDashboardScreen.routeName, // '/customer-dashboard'
        name: CustomerDashboardScreen.routeName,
        builder: (context, state) {
          // jodi extra diye info pathao:
          final args = state.extra is CustomerDashboardArgs
              ? state.extra as CustomerDashboardArgs
              : null;

          return CustomerDashboardScreen(
            isGuest: args?.isGuest ?? false,
            userName: args?.userName,
            onViewAllPressed: () {
              // ekhane booking list route e jao
              // e.g.
              // context.go(CustomerBookingListScreen.routeName);
            },
          );
        },
      ),

      GoRoute(
        path: CustomerProfileScreen.routeName,
        name: CustomerProfileScreen.routeName,
        builder: (context, state) {
          // extra diye data pathate chaile:
          final extra = state.extra as Map<String, dynamic>?;

          return CustomerProfileScreen(
            isGuest: extra?['isGuest'] ?? false,
            userName: extra?['name'] as String?,
            userPhone: extra?['phone'] as String?,
            // 👉 navigation gula ekhane context.goNamed diye handle korchi
            onLogout: () => context.goNamed('roleSelection'),
            onNavigateToNotifications: () => context.goNamed('notifications'),
            onSignUp: () => context.goNamed('customerAuth'),
          );
        },
      ),
      GoRoute(
        path: CustomerBookingsScreen.routeName,
        name: CustomerBookingsScreen.routeName,
        builder: (context, state) {
          // extra diye guest kina pass korte paro
          final bool isGuest = (state.extra is bool)
              ? state.extra as bool
              : false;

          return CustomerBookingsScreen(
            isGuest: isGuest,
            onSignUp: () {
              // guest theke "Create Account" click korle
              // customer auth screen e niye jabe
              context.go(CustomerAuthScreen.routeName);
            },
          );
        },
      ),

      GoRoute(
        path: FreelancerEditProfile.routeName,
        name: FreelancerEditProfile.routeName,
        builder: (context, state) => const FreelancerEditProfile(),
      ),

      GoRoute(
        path: CustomerEditProfile.routeName,
        name: CustomerEditProfile.routeName,
        builder: (context, state) => const CustomerEditProfile(),
      ),

      GoRoute(
        path: EditProfileScreen.routeName,
        name: EditProfileScreen.routeName,
        builder: (context, state) => const EditProfileScreen(),
      ),

      GoRoute(
        path: CustomerAppScreen.routeName, // '/customerApp'
        name: CustomerAppScreen.routeName,
        builder: (context, state) => const CustomerAppScreen(),
      ),
      GoRoute(
        path: MapAddressPickerScreen.routeName, // '/customerApp'
        name: MapAddressPickerScreen.routeName,
        builder: (context, state) => const MapAddressPickerScreen(),
      ),
      GoRoute(
        path: PayoutRequestScreen.routeName, // '/customerApp'
        name: PayoutRequestScreen.routeName,
        builder: (context, state) => const PayoutRequestScreen(),
      ),

      // GoRoute(
      //   path: '/internal-login',
      //   builder: (context, state) => const FreelancerAuthScreen(),
      // ),
    ],
  );
}
