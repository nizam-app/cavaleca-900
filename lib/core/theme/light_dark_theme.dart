// // light_dark_theme.dart  (or your existing theme file)
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:market_jango/core/constants/color_control/all_color.dart';
// import 'package:market_jango/core/constants/color_control/theme_color_controller.dart';
// import 'package:market_jango/core/theme/text_theme.dart';
// import 'input_decoration_theme.dart';
//
// /// mirrors your old `isDarkMode = true`
// final isDarkProvider = StateProvider<bool>((_) => true);
//
// /// Build ThemeData from current isDark flag (keeps your original mapping:
// /// true -> Brightness.light, false -> Brightness.dark)
// final themeDataProvider = Provider<ThemeData>((ref) {
//   final isDark = ref.watch(isDarkProvider);
//   final brightness = isDark ? Brightness.light : Brightness.dark;
//
//   return ThemeData(
//     brightness: brightness,
//     colorScheme: ColorScheme.light(
//       brightness: brightness,
//       primary: AllColor.orange500,
//       onPrimary: isDark ? AllColor.white : ThemeColorController.black,
//       secondary: ThemeColorController.green,
//       onSecondary: isDark ? AllColor.white : ThemeColorController.black,
//       surface: ThemeColorController.grey,
//       onSurface: isDark ? ThemeColorController.black : AllColor.white,
//     ),
//     inputDecorationTheme: inputDecorationTheme,
//     useMaterial3: true,
//     textTheme: textTheme,
//   );
// });
//
// /// Keep your old API name but now it needs `ref`
// ThemeData themeMood(WidgetRef ref) => ref.watch(themeDataProvider);
//
// /// Toggle helper (drop-in for your old controller’s `toggleTheme`)
// void toggleTheme(WidgetRef ref) =>
//     ref.read(isDarkProvider.notifier).update((v) => !v);