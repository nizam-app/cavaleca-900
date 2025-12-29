import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

const Color kPrimaryRed = Color(0xFFE32021);
const Color kPrimaryRedDark = Color(0xFFB01016);
const Color kAccentYellow = Color(0xFFFFC833);

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});
  static const String routeName = '/guest-home';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ---------- RED HEADER ----------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
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
              // top row: text + avatar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                       'hello_guest'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'booking_as_guest'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
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
                      color: Colors.white.withOpacity(0.16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.45),
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

              const SizedBox(height: 18),

              // ---------- BOOK NEW SERVICE BUTTON ----------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kAccentYellow,
                  borderRadius: BorderRadius.circular(22), // pill feel
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'book_new_service_plus'.tr(),
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

        const SizedBox(height: 22),

        // ---------- BODY ----------
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + arrows
                Row(
                  children: [
                    Text(
                      'service_categories'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: const Color(0xFF44474F),
                      ),
                    ),
                    const Spacer(),
                    _ArrowCircle(icon: Icons.chevron_left, onTap: () {}),
                    const SizedBox(width: 8),
                    _ArrowCircle(icon: Icons.chevron_right, onTap: () {}),
                  ],
                ),

                const SizedBox(height: 12),

                // horizontal category list
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

                const SizedBox(height: 22),

                // guest info banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4DD),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFFE0A9)),
                  ),
                  child: Text(
                    "guest_browsing_notice".tr(),
                    textAlign: TextAlign.center,
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

/// small circular arrow button
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
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.grey[700]),
      ),
    );
  }
}

/// model
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
    subtitle: 'Regular maintenance and repairs',
    servicesCount: '9 services',
    icon: Icons.build_outlined,
  ),
  ServiceCategory(
    title: 'HVAC Services',
    subtitle: 'Heating, cooling, and ventilation',
    servicesCount: '8 services',
    icon: Icons.ac_unit_outlined,
  ),
  ServiceCategory(
    title: 'Cleaning',
    subtitle: 'Professional home and office cleaning',
    servicesCount: '8 services',
    icon: Icons.cleaning_services_outlined,
  ),
];

/// card widget
class _CategoryCard extends StatelessWidget {
  final ServiceCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 155, // slightly narrow to match figma
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const SizedBox(height: 10),
          Text(
            category.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
