import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// -----------------------------------------
///  User + App State
/// -----------------------------------------
@immutable
class CustomerUserData {
  final bool isGuest;
  final String? name;
  final String? phone;

  const CustomerUserData({required this.isGuest, this.name, this.phone});

  const CustomerUserData.guest()
    : isGuest = true,
      name = 'Guest User',
      phone = null;

  CustomerUserData copyWith({bool? isGuest, String? name, String? phone}) {
    return CustomerUserData(
      isGuest: isGuest ?? this.isGuest,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}

@immutable
class CustomerAppState {
  final bool isAuthenticated;
  final CustomerUserData userData;
  final int activeIndex; // 0 = home, 1 = bookings, 2 = profile

  const CustomerAppState({
    required this.isAuthenticated,
    required this.userData,
    required this.activeIndex,
  });

  const CustomerAppState.initial()
    : isAuthenticated = false,
      userData = const CustomerUserData(isGuest: false),
      activeIndex = 0;

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

/// -----------------------------------------
///  Controller
/// -----------------------------------------
class CustomerAppController extends StateNotifier<CustomerAppState> {
  CustomerAppController() : super(const CustomerAppState.initial());

  /// Auth / guest complete hole call
  void authComplete({required bool isGuest, String? name, String? phone}) {
    final user = CustomerUserData(isGuest: isGuest, name: name, phone: phone);

    state = state.copyWith(
      isAuthenticated: true,
      userData: user,
      activeIndex: 0,
    );

    // TODO: ekhane SharedPreferences e save korte paro
  }

  /// Logout
  void logout() {
    state = const CustomerAppState.initial();
    // TODO: SharedPreferences clear
  }

  /// Bottom nav change
  void selectTab(int index) {
    state = state.copyWith(activeIndex: index);
  }

  /// Dashboard theke "View All" -> bookings
  void goToBookings() {
    selectTab(1);
  }

  /// Guest -> Sign up e jete chaile
  void resetForSignUpFromGuest() {
    state = const CustomerAppState.initial();
  }
}

/// Provider
final customerAppControllerProvider =
    StateNotifierProvider<CustomerAppController, CustomerAppState>((ref) {
      return CustomerAppController();
    });
