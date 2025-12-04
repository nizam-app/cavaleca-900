// lib/features/customer/screen/customer_app_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/auth/screens/customer/screen/customer_auth_screen.dart';
import 'package:workpleis/features/auth/screens/role/screen/role_selection_screen.dart';
import 'package:workpleis/features/customer/logic/custom_logic.dart';
import 'package:workpleis/features/customer/screen/customer_bookings_screen.dart';
import 'package:workpleis/features/customer/screen/customer_dashboard_screen.dart';
import 'package:workpleis/features/notification/customer_notifications_screen.dart';
import 'package:workpleis/features/profile/screen/customer_profile_screen.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kNavInactive = Color(0xFF9CA3AF);

/// ------------------------------------------------------
///  User data model
/// ------------------------------------------------------
class CustomerUserData {
  final bool isGuest;
  final String? name;
  final String? phone;

  const CustomerUserData({required this.isGuest, this.name, this.phone});

  CustomerUserData copyWith({bool? isGuest, String? name, String? phone}) {
    return CustomerUserData(
      isGuest: isGuest ?? this.isGuest,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}

class CustomerAppScreen extends ConsumerWidget {
  const CustomerAppScreen({super.key});

  static const String routeName = '/customerApp';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerAppControllerProvider);
    final controller = ref.read(customerAppControllerProvider.notifier);

    // 1) Auth হয় নাই → auth screen
    if (!state.isAuthenticated) {
      return CustomerAuthScreen(
        onBack: () => context.go(RoleSelectionScreen.routeName),
      );
    }

    final bool isGuest = state.userData.isGuest;

    // 2) Auth হয়ে গেলে bottom-nav shell
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(child: _buildPage(context, state, controller)),
      bottomNavigationBar: _CustomerBottomNavBar(
        activeIndex: state.activeIndex,
        isGuest: isGuest,
        unreadNotifications: 3, // TODO: backend
        onTap: controller.selectTab,
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    CustomerAppState state,
    CustomerAppController controller,
  ) {
    final bool isGuest = state.userData.isGuest;

    if (isGuest) {
      // Guest -> 3 tab: 0=Home, 1=Bookings, 2=Profile
      switch (state.activeIndex) {
        case 0:
          return CustomerDashboardScreen(
            isGuest: true,
            userName: state.userData.name,
            onViewAllPressed: controller.goToBookings,
          );
        case 1:
          return CustomerBookingsScreen(
            isGuest: true,
            onSignUp: controller.resetForSignUpFromGuest,
          );
        case 2:
        default:
          return CustomerProfileScreen(
            isGuest: true,
            userName: state.userData.name,
            userPhone: state.userData.phone,
            onLogout: () async {
              await controller.logout();
              // logout করলে role selection এ পাঠাই
              // ignore: use_build_context_synchronously
              context.go(RoleSelectionScreen.routeName);
            },
            onNavigateToNotifications: () {
              // guest er jonno notifications nai
            },
            onSignUp: controller.resetForSignUpFromGuest,
          );
      }
    } else {
      // Logged-in -> 4 tab: 0=Home, 1=Bookings, 2=Alerts, 3=Profile
      switch (state.activeIndex) {
        case 0:
          return CustomerDashboardScreen(
            isGuest: false,
            userName: state.userData.name,
            onViewAllPressed: controller.goToBookings,
          );
        case 1:
          return CustomerBookingsScreen(
            isGuest: false,
            onSignUp: controller.resetForSignUpFromGuest,
          );
        case 2:
          return CustomerNotificationsScreen(
            isGuest: false,
            onSignUp: controller.resetForSignUpFromGuest,
          );
        case 3:
        default:
          return CustomerProfileScreen(
            isGuest: false,
            userName: state.userData.name,
            userPhone: state.userData.phone,
            onLogout: () async {
              await controller.logout();
              // ignore: use_build_context_synchronously
              context.go(RoleSelectionScreen.routeName);
            },
            onNavigateToNotifications: () {
              controller.selectTab(2);
            },
            onSignUp: controller.resetForSignUpFromGuest,
          );
      }
    }
  }
}

/// ---------------- Bottom Nav : guest vs logged-in ----------------

class _CustomerBottomNavBar extends StatelessWidget {
  const _CustomerBottomNavBar({
    required this.activeIndex,
    required this.isGuest,
    required this.unreadNotifications,
    required this.onTap,
  });

  final int activeIndex;
  final bool isGuest;
  final int unreadNotifications;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                label: 'Home',
                icon: Icons.home_outlined,
                isActive: activeIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                label: 'Bookings',
                icon: Icons.assignment_outlined,
                isActive: activeIndex == 1,
                onTap: () => onTap(1),
              ),

              if (!isGuest)
                _NavItem(
                  label: 'Alerts',
                  icon: Icons.notifications_none_rounded,
                  isActive: activeIndex == 2,
                  onTap: () => onTap(2),
                  badgeCount: unreadNotifications,
                ),

              _NavItem(
                label: 'Profile',
                icon: Icons.person_outline,
                isActive: activeIndex == (isGuest ? 2 : 3),
                onTap: () => onTap(isGuest ? 2 : 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? kPrimaryRed : kNavInactive;

    Widget iconWidget = Icon(icon, size: 24, color: color);

    if (badgeCount != null && badgeCount! > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 24, color: color),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: kPrimaryRed,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                badgeCount! > 9 ? '9+' : badgeCount!.toString(),
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
