import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/langs', // JSON files location
      fallbackLocale: const Locale('en'),
      child: ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(392, 851),
          minTextAdapt: true,
          splitScreenMode: true,
          useInheritedMediaQuery: true,
          child: App(),
        ),
      ),
    ),
  );
}
