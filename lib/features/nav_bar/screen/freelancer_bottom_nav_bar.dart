import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workpleis/features/freelancer_pages/screen/freelancer_earnings_screen.dart';
import 'package:workpleis/features/freelancer_pages/screen/freelancer_home_screen.dart';
import 'package:workpleis/features/freelancer_pages/screen/profile/screen/freelancer_profile_screen.dart';

import '../../freelancer_pages/screen/freelarcer_job_screen.dart';
import '../logic/botton_nav_index_logic.dart';
import 'package:easy_localization/easy_localization.dart';

class FreelancerBottomNavBar extends ConsumerWidget {
  const FreelancerBottomNavBar({super.key});
  static const routeName = '/freelancerBottomNavBar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    const activeColor = Color(0xFFCF2626); // red
    const inactiveColor = Color(0xFFB0B0B0); // grey

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: IndexedStack(
        index: currentIndex,
        children: [
          FreelancerHomeScreen(),
          FreelarcerJobScreen(),
          FreelancerEarningsScreen(),
          FreelancerProfileScreen(),
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
          onTap: (index) =>
              ref.read(bottomNavIndexProvider.notifier).state = index,
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
          items:  [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work_outline),
              label: 'jobs'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined),
              activeIcon: Icon(Icons.attach_money_outlined),
              label: 'earnings'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
