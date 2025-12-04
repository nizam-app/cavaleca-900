import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../auth/screens/role/screen/role_selection_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/splashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 seconds por RoleSelectionScreen e navigate
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.push(RoleSelectionScreen.routeName);
    });
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
                fit: BoxFit.contain,
              ),
              SizedBox(height: 10.h),
              const CircularProgressIndicator(color: Colors.orange,),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
