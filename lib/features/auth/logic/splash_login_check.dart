import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../nav_bar/screen/bottom_nav_bar.dart';

void loginCheck(BuildContext context) async{
  SharedPreferences _pref = await SharedPreferences.getInstance();
  String? email = await _pref.getString("email");
  String? token = await _pref.getString("token");

  Future.delayed(const Duration(seconds: 3), () {
    if (email != null && token != null ) { context.go(BottomNavBar.routeName); }
    else{
      context.go(LoginScreen.routeName);
    }
    // GoRouter navigation
  });

}
