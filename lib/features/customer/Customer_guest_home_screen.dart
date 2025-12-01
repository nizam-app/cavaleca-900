import 'package:flutter/material.dart';

const Color kPrimaryRed = Color(0xFFE32021);
const Color kPrimaryRedDark = Color(0xFFB01016);
const Color kAccentYellow = Color(0xFFFFC833);

/// Root scaffold with bottom navigation

/// -------------------- HOME SCREEN --------------------

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ---------- Red header ----------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryRed, kPrimaryRedDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Guest',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Booking as guest',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              // Book New Service button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kAccentYellow,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Book New Service',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ---------- Body ----------
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + arrows
                Row(
                  children: [
                    Text(
                      'Service Categories',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _ArrowCircle(icon: Icons.chevron_left, onTap: () {}),
                    const SizedBox(width: 8),
                    _ArrowCircle(icon: Icons.chevron_right, onTap: () {}),
                  ],
                ),
                const SizedBox(height: 14),

                // Horizontal categories
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _serviceCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final cat = _serviceCategories[index];
                      return _CategoryCard(category: cat);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Guest info banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4DD),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFFE0A9)),
                  ),
                  child: Text(
                    "You're browsing as a guest. Create an account to view booking history and track your requests.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8C5C11),
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Small circular arrow button
class _ArrowCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.grey[700]),
      ),
    );
  }
}

/// Category model
class ServiceCategory {
  final String title;
  final String subtitle;
  final String servicesCount;
  final IconData icon;

  const ServiceCategory({
    required this.title,
    required this.subtitle,
    required this.servicesCount,
    required this.icon,
  });
}

const _serviceCategories = <ServiceCategory>[
  ServiceCategory(
    title: 'General',
    subtitle: 'Regular maintenance and\nrepairs',
    servicesCount: '9 services',
    icon: Icons.build_outlined,
  ),
  ServiceCategory(
    title: 'HVAC Services',
    subtitle: 'Heating, cooling, and\nventilation',
    servicesCount: '8 services',
    icon: Icons.ac_unit_outlined,
  ),
  ServiceCategory(
    title: 'Cleaning',
    subtitle: 'Professional home and\noffice cleaning',
    servicesCount: '8 services',
    icon: Icons.cleaning_services_outlined,
  ),
];

/// Card widget (white card with red icon)
class _CategoryCard extends StatelessWidget {
  final ServiceCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // red icon pill
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: kPrimaryRed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(category.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            category.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
          const Spacer(),
          Text(
            category.servicesCount,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kPrimaryRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------- OTHER TABS (simple placeholders) --------------------

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Bookings screen', style: TextStyle(fontSize: 18)),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile screen', style: TextStyle(fontSize: 18)),
    );
  }
}
