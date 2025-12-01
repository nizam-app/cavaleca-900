import 'package:go_router/go_router.dart';
import 'package:workpleis/core/widget/global_snack_bar.dart';
import 'package:workpleis/features/auth/screens/customer_seleced_login_screen.dart';
import 'package:workpleis/features/auth/screens/otp_verify_screen.dart';
import 'package:workpleis/features/auth/screens/role_selection_screen.dart';
import 'package:workpleis/features/auth/screens/set_password_screen.dart';
import 'package:workpleis/features/customer/screen/Customer_guest_home_screen.dart';
import 'package:workpleis/features/internal_technician/screen/internal_jobs.dart';
import 'package:workpleis/features/nav_bar/screen/bottom_nav_bar.dart';
import '../features/auth/screens/customer_create_account_screen.dart';
import '../features/auth/screens/phone_login_screen.dart';
import '../features/customer/screen/guest_profile_screen.dart';
import '../features/internal_technician/screen/internal_technician_home.dart';
import '../features/nav_bar/screen/internal_bottom_nav_bar.dart';
import 'error_screen.dart';

class AppRouter {
  static final String initial = RoleSelelctionScreen.routeName;
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
      GoRoute(
        path: RoleSelelctionScreen.routeName,
        name: RoleSelelctionScreen.routeName,
        builder: (context, state) => const RoleSelelctionScreen(),
      ),
      GoRoute(
        path: CustomerLoginSceled.routeName,
        name: CustomerLoginSceled.routeName,
        builder: (context, state) => const CustomerLoginSceled(),
      ),
      GoRoute(
        path: PhoneLoginScreen.routeName,
        name: PhoneLoginScreen.routeName,
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: OtpVerifyScreen.routeName,
        name: OtpVerifyScreen.routeName,
        builder: (context, state) => const OtpVerifyScreen(),
      ),
      GoRoute(
        path: CustomerCreateAccountScreen.routeName,
        name: CustomerCreateAccountScreen.routeName,
        builder: (context, state) => const CustomerCreateAccountScreen(),
      ),
      GoRoute(
        path: GuestHomeScreen.routeName,
        name: GuestHomeScreen.routeName,
        builder: (context, state) => const GuestHomeScreen(),
      ),
      GoRoute(
        path: SetPasswordScreen.routeName,
        name: SetPasswordScreen.routeName,
        builder: (context, state) => const SetPasswordScreen(),
      ),
      GoRoute(
        path: CustomerMainShell.routeName,
        name: CustomerMainShell.routeName,
        builder: (context, state) => const CustomerMainShell(),
      ),
      GoRoute(
        path: GuestProfileScreen.routeName,
        name: GuestProfileScreen.routeName,
        builder: (context, state) => const GuestProfileScreen(),
      ),
      //Internal Technician flow;
      GoRoute(
        path: InternalDashboardV2Screen.routeName,
        name: InternalDashboardV2Screen.routeName,
        builder: (context, state) => const InternalDashboardV2Screen(),
      ),

      GoRoute(
        path: InternalBottomNavBar.routeName,
        name: InternalBottomNavBar.routeName,
        builder: (context, state)=> const InternalBottomNavBar()
      ),

      GoRoute(
          path: InternalJobs.routeName,
          name: InternalJobs.routeName,
          builder: (context, state)=> const InternalJobs ()
      ),


    ],
  );
}
