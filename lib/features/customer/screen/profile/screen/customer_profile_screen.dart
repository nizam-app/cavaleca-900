import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:workpleis/core/widget/global_language_dialog.dart';
import 'package:workpleis/features/customer/screen/profile/logic/logout_logic.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({
    super.key,
    this.isGuest = false,
    this.userName,
    this.userPhone,
    this.onLogout,
    this.onNavigateToNotifications,
    this.onSignUp,
  });
  static const String routeName = '/customer_profile';

  final bool isGuest;
  final String? userName;
  final String? userPhone;

  final VoidCallback? onLogout;
  final VoidCallback? onNavigateToNotifications;
  final VoidCallback? onSignUp;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late String _languageCode;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageCode = context.locale.languageCode; // ← EasyLocalization theke
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String get _displayName => (widget.userName?.trim().isNotEmpty ?? false)
      ? widget.userName!.trim()
      : (widget.isGuest ? 'Guest User' : 'John Doe');

  String get _displayInitials {
    final name = _displayName;
    if (name.isEmpty) return 'GU';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get _currentLanguageNative {
    switch (_languageCode) {
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }

  Future<void> _openLanguageDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return LanguageDialog(currentCode: _languageCode);
      },
    );

    if (selected != null && selected != _languageCode) {
      // 1) EasyLocalization er locale change
      await context.setLocale(Locale(selected));

      // 2) local state update
      setState(() => _languageCode = selected);

      // 3) toast
      _showToast('Language updated to $_currentLanguageNative');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = widget.isGuest;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isGuest: isGuest),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildUserCard(isGuest: isGuest),
                    const SizedBox(height: 16),
                    if (!isGuest) _buildStatsRow(),
                    if (isGuest) ...[
                      const SizedBox(height: 16),
                      _buildGuestUpgradeCard(),
                    ],
                    const SizedBox(height: 16),
                    _buildMenuSection(isGuest: isGuest),
                    const SizedBox(height: 24),
                    _buildSupportSection(),
                    const SizedBox(height: 16),
                    _buildLogoutButton(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader({required bool isGuest}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 20, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC20001), Color(0xFF9A0001)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Center(child: Column(children: [])),
          const SizedBox(height: 4),
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isGuest ? 'Guest Account' : 'Manage your account information',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // User Card
  // ---------------------------------------------------------------------------

  Widget _buildUserCard({required bool isGuest}) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isGuest
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFFC20001), Color(0xFF9A0001)],
                          ),
                    color: isGuest ? const Color(0xFF9CA3AF) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _displayInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Name + phone / subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!isGuest && (widget.userPhone?.isNotEmpty ?? false))
                        Text(
                          widget.userPhone!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      if (isGuest)
                        const Text(
                          'Limited access',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isGuest) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    _showToast('Edit profile tapped');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE5E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Color(0xFFC20001),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------------

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: [
                  Text(
                    '24',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total Bookings',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: [
                  Text(
                    '\$2.4k',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total Spent',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Guest upgrade card
  // ---------------------------------------------------------------------------

  Widget _buildGuestUpgradeCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFB111), Color(0xFFE69F0F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        child: Column(
          children: [
            const Icon(Icons.person_outline, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            const Text(
              'Create an Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sign up to save your bookings and manage your history easily.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed:
                    widget.onSignUp ??
                    () => _showToast('Sign Up tapped (guest)'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Sign Up Now',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Menu section (Notifications + Language)
  // ---------------------------------------------------------------------------

  Widget _buildMenuSection({required bool isGuest}) {
    final items = <_MenuItem>[
      _MenuItem(
        icon: Icons.notifications_outlined,
        iconBgColor: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFFA855F7),
        title: 'Notifications',
        subtitle: '3 new',
        onTap:
            widget.onNavigateToNotifications ??
            () => _showToast('Open notifications'),
        showForGuest: false,
      ),
      _MenuItem(
        icon: Icons.language,
        iconBgColor: const Color(0xFFF0FDF4),
        iconColor: const Color(0xFF22C55E),
        title: 'Language',
        subtitle: _currentLanguageNative,
        onTap: _openLanguageDialog,
        showForGuest: true,
      ),
    ];

    final visibleItems = items
        .where((e) => !isGuest || e.showForGuest)
        .toList();

    return Column(
      children: [
        for (final item in visibleItems) ...[
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: item.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (item.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Support
  // ---------------------------------------------------------------------------

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Support',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Call us
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              _showToast('Calling +1 (800) 123-4567...');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.call_outlined,
                      color: Color(0xFF22C55E),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Call Us',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '+1 (800) 123-4567',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Email support
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              _showToast('Opening email support@ibacos.com...');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.mail_outline,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Support',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'support@ibacos.com',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Business hours card
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB111), Color(0xFFE69F0F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(22)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Business Hours',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                _BusinessHourRow(
                  day: 'Monday - Friday',
                  time: '8:00 AM - 8:00 PM',
                ),
                _BusinessHourRow(day: 'Saturday', time: '9:00 AM - 6:00 PM'),
                _BusinessHourRow(day: 'Sunday', time: '10:00 AM - 4:00 PM'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Widget _buildLogoutButton() {
    final isGuest = widget.isGuest;

    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _confirmAndLogout, // 👈 popup + api
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.logout, color: Color(0xFFC20001), size: 20),
        label: Text(
          isGuest ? 'Exit Guest Mode' : 'Sign Out',
          style: const TextStyle(
            color: Color(0xFFC20001),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndLogout() async {
    final isGuest = widget.isGuest;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirm'),
          content: Text(
            isGuest
                ? 'Do you want to exit guest mode?'
                : 'Are you sure you want to sign out?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Yes',
                style: TextStyle(color: Color(0xFFC20001)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      if (!isGuest) {
        // real user logout
        await CustomerLogOut.logout();
        _showToast('Logout successful');
      } else {
        _showToast('Exited guest mode');
      }

      // local state / navigation parent ke handle korte dao
      if (widget.onLogout != null) {
        widget.onLogout!();
      } else {
        // fallback: go back to role selection / auth screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showToast('Logout failed: $e');
    }
  }
}

// ============================================================================
// Helper models & widgets
// ============================================================================

class _MenuItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showForGuest;

  _MenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showForGuest = true,
  });
}

class _BusinessHourRow extends StatelessWidget {
  const _BusinessHourRow({required this.day, required this.time});

  final String day;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1F2933)),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1F2933)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Language dialog
// ============================================================================
