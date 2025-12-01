import 'package:go_router/go_router.dart';
import 'package:workpleis/core/widget/global_snack_bar.dart';
import 'package:workpleis/features/auth/screens/customer_seleced_login_screen.dart';
import 'package:workpleis/features/auth/screens/otp_verify_screen.dart';
import 'package:workpleis/features/auth/screens/role_selection_screen.dart';

import '../features/auth/screens/customer_create_account_screen.dart';
import '../features/auth/screens/phone_login_screen.dart';
import 'error_screen.dart';

class AppRouter {
  static final String initial = CustomerLoginSceled.routeName;
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
        path: CustomerPortalTopSection.routeName,
        name: CustomerPortalTopSection.routeName,
        builder: (context, state) => const CustomerPortalTopSection(),
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
    ],
  );
}
