// lib/features/customer/logic/custom_logic.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/nav_bar/screen/bottom_nav_bar.dart';

final _log = Logger();

class CustomerAppState {
  final bool isAuthenticated;
  final CustomerUserData userData;
  final int activeIndex;

  const CustomerAppState({
    required this.isAuthenticated,
    required this.userData,
    required this.activeIndex,
  });

  factory CustomerAppState.initial() => CustomerAppState(
    isAuthenticated: false,
    userData: const CustomerUserData(isGuest: true),
    activeIndex: 0,
  );

  CustomerAppState copyWith({
    bool? isAuthenticated,
    CustomerUserData? userData,
    int? activeIndex,
  }) {
    return CustomerAppState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userData: userData ?? this.userData,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

/// -------------------- Controller --------------------

class CustomerAppController extends StateNotifier<CustomerAppState> {
  CustomerAppController() : super(CustomerAppState.initial()) {
    _initFromLocal();
  }
  void authComplete({required bool isGuest, String? name, String? phone}) {
    state = state.copyWith(
      isAuthenticated: true,
      userData: CustomerUserData(isGuest: isGuest, name: name, phone: phone),
      activeIndex: 0,
    );
  }

  /// Splash/first load এ লোকাল থেকে user hydrate করার কাজ
  Future<void> _initFromLocal() async {
    final token = await AuthLocalStorage.getToken();
    final user = await AuthLocalStorage.getUserJson();

    if (token != null && user != null) {
      final roleRaw = (user['role']).toString().toUpperCase();
      _log.i('CustomerAppController _initFromLocal role: $roleRaw');

      // শুধু CUSTOMER রোল হলে এখানে hydrate করবে
      if (roleRaw == 'CUSTOMER') {
        state = state.copyWith(
          isAuthenticated: true,
          userData: CustomerUserData(
            isGuest: false,
            name: user['name']?.toString(),
            phone: user['phone']?.toString(),
          ),
        );
      }
    }
  }

  /// Bottom nav change
  void selectTab(int index) {
    state = state.copyWith(activeIndex: index);
  }

  /// Home screen থেকে "View all" → Bookings ট্যাবে
  void goToBookings() {
    state = state.copyWith(activeIndex: 1);
  }

  /// Guest থেকে Sign Up flow শুরু করতে চাইলে
  void resetForSignUpFromGuest() {
    state = CustomerAppState.initial();
  }

  /// Login সফল হলে call করো
  Future<void> onLoginSuccess({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await AuthLocalStorage.saveLoginData(token: token, userJson: user);

    state = state.copyWith(
      isAuthenticated: true,
      userData: CustomerUserData(
        isGuest: false,
        name: user['name']?.toString(),
        phone: user['phone']?.toString(),
      ),
      activeIndex: 0,
    );
  }

  /// Logout
  Future<void> logout() async {
    await AuthLocalStorage.clearLoginData;
    state = CustomerAppState.initial();
  }
}

/// -------------------- Provider --------------------

final customerAppControllerProvider =
    StateNotifierProvider<CustomerAppController, CustomerAppState>((ref) {
      return CustomerAppController();
    });
