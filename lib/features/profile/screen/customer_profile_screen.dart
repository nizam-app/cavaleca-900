
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
  String _languageCode = 'en'; // en, fr, ar

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String get _displayName => (widget.userName?.trim().isNotEmpty ?? false)
      ? widget.userName!.trim()
      : (widget.isGuest ? 'guest_user'.tr() : 'John Doe');

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

  void _openLanguageDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return _LanguageDialog(currentCode: _languageCode);
      },
    );

    if (selected != null && selected != _languageCode) {
      setState(() => _languageCode = selected);
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
          Text(
            'profile'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isGuest
                ? 'guest_account'.tr()
                : 'manage_account_info'.tr(),
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
                        Text(
                          'limited_access'.tr(),
                          style: const TextStyle(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: [
                  const Text(
                    '24',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'total_bookings'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: [
                  const Text(
                    '\$2.4k',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'total_spent'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
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
            Text(
              'create_account'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'create_account_to_view_history'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                child: Text(
                  'sign_up_now'.tr(),
                  style: const TextStyle(
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
        title: 'notifications'.tr(),
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
        title: 'language'.tr(),
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
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'support'.tr(),
            style: const TextStyle(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'call_us'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'email_support'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
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
                _BusinessHoursTitle(),
                SizedBox(height: 10),
                _BusinessHourRow(
                  dayKey: 'monday_friday',
                  timeKey: 'monday_friday_time',
                ),
                _BusinessHourRow(
                  dayKey: 'saturday',
                  timeKey: 'saturday_time',
                ),
                _BusinessHourRow(
                  dayKey: 'sunday',
                  timeKey: 'sunday_time',
                ),
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
        onPressed: widget.onLogout ??
                () => _showToast(
              isGuest ? 'Exit guest mode' : 'sign_out'.tr(),
            ),
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
          isGuest ? 'Exit Guest Mode' : 'sign_out'.tr(),
          style: const TextStyle(
            color: Color(0xFFC20001),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
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

class _BusinessHoursTitle extends StatelessWidget {
  const _BusinessHoursTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'business_hours'.tr(),
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF111827),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _BusinessHourRow extends StatelessWidget {
  const _BusinessHourRow({
    required this.dayKey,
    required this.timeKey,
  });

  final String dayKey;
  final String timeKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dayKey.tr(),
            style: const TextStyle(fontSize: 13, color: Color(0xFF1F2933)),
          ),
          Text(
            timeKey.tr(),
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

class _LanguageDialog extends StatelessWidget {
  const _LanguageDialog({required this.currentCode});

  final String currentCode;

  @override
  Widget build(BuildContext context) {
    final languages = [
      ('en', 'English', 'English'),
      ('fr', 'French', 'Français'),
      ('ar', 'Arabic', 'العربية'),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title:  Text('select_language'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose your preferred language for the app interface',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          for (final item in languages) ...[
            _LanguageTile(
              code: item.$1,
              nativeName: item.$3,
              name: item.$2,
              isSelected: currentCode == item.$1,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.code,
    required this.nativeName,
    required this.name,
    required this.isSelected,
  });

  final String code;
  final String nativeName;
  final String name;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).pop(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC20001)
                : const Color(0xFFE5E7EB),
            width: 2,
          ),
          color: isSelected ? const Color(0xFFFFE5E5) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFFC20001), size: 20),
          ],
        ),
      ),
    );
  }
}
