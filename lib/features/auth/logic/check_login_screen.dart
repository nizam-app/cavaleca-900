import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workpleis/features/auth/logic/screen_check_enum.dart';

final screenCheckProvider = StateProvider<ScreenName>(
  (ref) => ScreenName.register,
);
