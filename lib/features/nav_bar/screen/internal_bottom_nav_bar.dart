import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workpleis/features/erning/screen/technician_earningsScreen.dart';
import 'package:workpleis/features/internal_technician/screen/internal_technician_home.dart';
import 'package:workpleis/features/internal_technician/screen/job/screen/internal_jobs.dart';
import 'package:workpleis/features/internal_technician/screen/profile/screen/internal_job_profile.dart';

import '../logic/botton_nav_index_logic.dart';

class InternalBottomNavBar extends ConsumerWidget {
  const InternalBottomNavBar({super.key});
  static const routeName = '/internalBottomNavBar';

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
          InternalDashboardV2Screen(),
          InternalJobs(),
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
          items: const [
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
