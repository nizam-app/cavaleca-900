import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workpleis/features/erning/screen/technician_earningsScreen.dart';
import 'package:workpleis/features/internal_technician/screen/internal_technician_home.dart';
import 'package:workpleis/features/internal_technician/screen/job/screen/internal_jobs.dart';
import 'package:workpleis/features/internal_technician/screen/profile/screen/internal_job_profile.dart';
import 'package:workpleis/features/notification/customer_notifications_screen.dart';
import 'package:workpleis/features/notification/data/notificaion_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:workpleis/core/services/job_notification_service.dart';
import 'package:workpleis/core/services/realtime_service.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/core/widget/screen_refresh_provider.dart';

import '../logic/botton_nav_index_logic.dart';

class InternalBottomNavBar extends ConsumerStatefulWidget {
  const InternalBottomNavBar({super.key});
  static const routeName = '/internalBottomNavBar';

  @override
  ConsumerState<InternalBottomNavBar> createState() => _InternalBottomNavBarState();
}

class _InternalBottomNavBarState extends ConsumerState<InternalBottomNavBar> {
  static bool _realtimeHandlersRegistered = false;

  @override
  void initState() {
    super.initState();
    // Initialize job notification service and realtime socket after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = this.context;
      if (!context.mounted) return;
      await JobNotificationService().initialize(context);
      JobNotificationService().startPolling();
      // After accept/reject from new-job popup, refresh jobs so Home/Jobs tabs update
      JobNotificationService.onJobsListChanged = () {
        if (context.mounted) {
          ref.read(jobsRefreshTriggerProvider.notifier).state =
              ref.read(jobsRefreshTriggerProvider) + 1;
        }
      };

      // Realtime: connect Socket.IO and register handlers (jobs + notifications)
      final token = await AuthLocalStorage.getToken();
      if (token == null) return;
      final realtime = RealtimeService();
      if (!realtime.isConnected) realtime.connect(token);

      if (!_realtimeHandlersRegistered) {
        _realtimeHandlersRegistered = true;
        // technician:jobs_updated → trigger jobs refresh + immediate new-job check
        realtime.on('technician:jobs_updated', (_) {
          if (!context.mounted) return;
          ref.read(jobsRefreshTriggerProvider.notifier).state =
              ref.read(jobsRefreshTriggerProvider) + 1;
          JobNotificationService().triggerCheckForNewJobs();
        });

        // notification:new → refresh notifications list and badge
        realtime.on('notification:new', (_) {
          if (!context.mounted) return;
          ref.read(notificationsProvider.notifier).refresh();
        });
      }
    });
  }

  @override
  void dispose() {
    JobNotificationService().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final unreadCount = ref.watch(unreadNotificationsProvider).value ?? 0;
    const activeColor = Color(0xFFCF2626); // red
    const inactiveColor = Color(0xFFB0B0B0); // grey

    // Watch for tab changes and trigger refresh
    ref.listen<int>(bottomNavIndexProvider, (previous, next) {
      if (previous != null && previous != next) {
        // Tab changed - trigger refresh for the new screen
        triggerScreenRefresh(ref, next);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: IndexedStack(
        index: currentIndex,
        children: [
          InternalDashboardV2Screen(),
          InternalJobs(),
          CustomerNotificationsScreen(isGuest: false),
          Earningsscreen(),
          InternalJobProfile(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
            // Trigger refresh when tab is tapped
            triggerScreenRefresh(ref, index);
          },
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work_outline),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: _NotificationIcon(
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                isActive: currentIndex == 2,
                badgeCount: unreadCount,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              label: 'alerts'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined),
              activeIcon: Icon(Icons.attach_money_outlined),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.badgeCount,
    required this.activeColor,
    required this.inactiveColor,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final int badgeCount;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? activeColor : inactiveColor;

    Widget iconWidget = Icon(
      isActive ? activeIcon : icon,
      color: color,
    );

    if (badgeCount > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFCF2626),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                badgeCount > 9 ? '9+' : badgeCount.toString(),
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

    return iconWidget;
  }
}
