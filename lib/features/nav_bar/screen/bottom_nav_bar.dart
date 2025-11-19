import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workpleis/core/constants/color_control/all_color.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});
  static const String routeName = '/BottomNavBar';
  final List<Widget> _pages = const [

  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef
    // Watch the selectedIndexProvider
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          // Update the selected index using the provider's notifier
          ref
              .read(selectedIndexProvider.notifier)
              .state = index;
        },
        backgroundColor: AllColor.white,
        selectedItemColor: AllColor.orange,
        // Changed to orange
        unselectedItemColor: AllColor.grey,
        type: BottomNavigationBarType.fixed,
        // Keep this if you want fixed labels
        // showSelectedLabels: true, // Optional: ensure selected label is shown
        // showUnselectedLabels: true, // Optional: ensure unselected labels are shown
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled), // Changed Icon
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            // Kept similar, adjust if needed
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            // Changed Icon (example for Categories)
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined), // Changed Icon
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Changed Icon
            label: "Account",
          ),
        ],
      ),
    );
  }
}
