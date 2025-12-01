import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/auth/screens/customer_seleced_login_screen.dart';
import 'package:workpleis/features/auth/widgets/Customer_portal_top_section.dart';

class RoleSelelctionScreen extends StatelessWidget {
  const RoleSelelctionScreen({super.key});
  static final String routeName = '/role-selection';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RoleSelectionCard(),

          const SizedBox(height: 24),

          // TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ROLE CARDS + MAKE THEM SCROLLABLE IF NEEDED
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  RoleCard(
                    title: 'Customer',
                    subtitle: 'Book and manage service\nrequests',
                    color: Color(0xFFCF2626),
                    icon: Icons.person_outline,
                    onTap: () {
                      context.push(CustomerLoginSceled.routeName);
                    },
                  ),
                  RoleCard(
                    title: 'Freelancer Technician',
                    subtitle: 'Accept jobs and earn\ncommissions',
                    color: Color(0xFFF4A623),
                    icon: Icons.build_outlined,
                  ),
                  RoleCard(
                    title: 'Internal Technician',
                    subtitle: 'Manage assigned jobs and\nschedule',
                    color: Color(0xFF273142),
                    icon: Icons.manage_accounts_outlined,
                  ),
                ],
              ),
            ),
          ),

          // FOOTER
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 10, color: Color(0xFFB0B0B0)),
                ),
                SizedBox(height: 4),
                Text(
                  '© 2025 IBACOS Services',
                  style: TextStyle(fontSize: 10, color: Color(0xFFB0B0B0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFB0B0B0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
