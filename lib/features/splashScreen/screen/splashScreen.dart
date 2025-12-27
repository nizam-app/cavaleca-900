import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/core/utils/app_permission_service.dart';
import 'package:workpleis/core/services/fcm_service.dart';
import 'package:workpleis/features/auth/screens/role/screen/role_selection_screen.dart';
import 'package:workpleis/features/nav_bar/screen/bottom_nav_bar.dart';
import 'package:workpleis/features/nav_bar/screen/freelancer_bottom_nav_bar.dart';
import 'package:workpleis/features/nav_bar/screen/internal_bottom_nav_bar.dart';
import 'package:workpleis/features/shared/background_location_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/splashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _log = Logger();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app - request permissions and then check auth
  Future<void> _initializeApp() async {
    // Request all permissions when app starts
    await AppPermissionService.requestAllPermissions();
    
    // Initialize FCM and register token (only if user is logged in)
    final token = await AuthLocalStorage.getToken();
    if (token != null) {
      await FCMService.initialize();
    }
    
    // Then proceed with auth check and navigation
    _checkAuthAndRedirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(3.r),
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/Logo.png',
                height: 120.h,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10.h),
              const CircularProgressIndicator(color: Colors.orange),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkAuthAndRedirect() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = await AuthLocalStorage.getToken();
    final user = await AuthLocalStorage.getUserJson();

    if (!mounted) return;

    if (token == null || user == null) {
      context.go(RoleSelectionScreen.routeName);
      return;
    }

    final roleRaw = (user['role']).toString().toUpperCase();
    _log.i('Splash role: $roleRaw');

    if (roleRaw == 'CUSTOMER') {
      context.go(CustomerAppScreen.routeName);
      return;
    }

    // For technicians (internal/freelancer), request location in background without popup
    if (roleRaw == 'TECH_INTERNAL' || roleRaw == 'TECH_FREELANCER') {
      // Request location permission and update location silently in background
      BackgroundLocationService.requestAndUpdateLocationInBackground();

      if (roleRaw == 'TECH_INTERNAL') {
        context.go(InternalBottomNavBar.routeName);
      } else {
        context.go(FreelancerBottomNavBar.routeName);
      }
      return;
    }

    context.go(RoleSelectionScreen.routeName);
  }
}
