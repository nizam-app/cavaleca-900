// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:market_jango/core/theme/light_dark_theme.dart'; // exports themeModeProvider, appLightThemeProvider, appDarkThemeProvider
// import 'package:market_jango/routes/app_routes.dart';
//
// class App extends ConsumerStatefulWidget {
//   const App({super.key});
//
//   @override
//   ConsumerState<App> createState() => _AppState();
// }
//
// class _AppState extends ConsumerState<App> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, _) {
//         return MaterialApp.router(
//           debugShowCheckedModeBanner: false,
//           routerConfig: router,
//           theme: themeMood(ref), // same call name as before
//         );
//       },
//     );
//   }
// }


// main_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/routes/app_routes.dart';

import 'core/constants/color_control/all_color.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.appRouter,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AllColor.black,
        scaffoldBackgroundColor: Colors.white.withOpacity(0.9),
        colorScheme: ColorScheme.light(
          primary: AllColor.white,
          onPrimary: AllColor.white,
          secondary: AllColor.white70,
          onSecondary: AllColor.white,
          surface: AllColor.white,
          onSurface: AllColor.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AllColor.white70,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          hintStyle: TextStyle(
            color: AllColor.white70,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          suffixIconColor: Colors.grey,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AllColor.black, width: 0.5.sp),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AllColor.grey, width: 0.5.sp),
          ),

          errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: AllColor.red200, width: 0.5.sp),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: AllColor.red200, width: 0.5.sp),
      ),
      errorStyle: TextStyle(fontSize: 12.sp, color: Colors.red),
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w500, color: AllColor.black),
          titleMedium: TextStyle(fontSize: 12.sp, color: AllColor.grey, fontWeight: FontWeight.w400),
          titleSmall: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600, color: AllColor.grey200),
          headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AllColor.black),
          headlineMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AllColor.black),
        ),
      ), // fixed theme
    );
  }
}