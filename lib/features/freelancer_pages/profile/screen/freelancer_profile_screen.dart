// lib/features/freelancer/screens/freelancer_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/core/widget/signOutButton.dart';
import 'package:workpleis/features/auth/screens/role/screen/role_selection_screen.dart';
import 'package:workpleis/features/freelancer_pages/profile/data/freelancer_profile_data.dart';

/// ---------------------------------------------------------------------------
/// Colors
/// ---------------------------------------------------------------------------
const Color kProfileBg = Color(0xFFF4F4F6);
const Color kProfileCard = Colors.white;
const Color kProfileHeaderStart = Color(0xFFFFB111);
const Color kProfileHeaderEnd = Color(0xFFE69F0F);
const Color kProfileTextMain = Color(0xFF111827);
const Color kProfileTextMuted = Color(0xFF6B7280);
const Color kProfileBorderLight = Color(0xFFE5E7EB);
const Color kAccentRed = Color(0xFFC20001);

/// ---------------------------------------------------------------------------
/// UI data model (repo এটা fill করবে)
/// ---------------------------------------------------------------------------
class FreelancerProfileData {
  final String initials;
  final String fullName;
  final String title;
  final String memberSince;
  final List<String> skills;
  final int verifiedCerts;
  final bool bankLinked;

  const FreelancerProfileData({
    required this.initials,
    required this.fullName,
    required this.title,
    required this.memberSince,
    required this.skills,
    required this.verifiedCerts,
    required this.bankLinked,
  });
}

/// ---------------------------------------------------------------------------
/// Language enum + helper
/// ---------------------------------------------------------------------------
enum AppLanguage { en, fr, ar }

extension AppLanguageLabel on AppLanguage {
  String get display {
    switch (this) {
      case AppLanguage.en:
        return 'English';
      case AppLanguage.fr:
        return 'Français';
      case AppLanguage.ar:
        return 'العربية';
    }
  }

  String get secondary {
    switch (this) {
      case AppLanguage.en:
        return 'English';
      case AppLanguage.fr:
        return 'French';
      case AppLanguage.ar:
        return 'Arabic';
    }
  }
}

/// ---------------------------------------------------------------------------
/// Riverpod provider – API theke profile ene UI model banাবে
/// ---------------------------------------------------------------------------
final freelancerProfileProvider = FutureProvider<FreelancerProfileData>((
  ref,
) async {
  final repo = FreelancerProfileRepository();
  return repo.fetchProfileData();
});

/// ---------------------------------------------------------------------------
/// Screen
/// ---------------------------------------------------------------------------
class FreelancerProfileScreen extends ConsumerStatefulWidget {
  const FreelancerProfileScreen({super.key});

  static const String routeName = 'freelancer-profile';
  static const String routePath = '/freelancer/profile';

  @override
  ConsumerState<FreelancerProfileScreen> createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState
    extends ConsumerState<FreelancerProfileScreen> {
  bool _isAvailable = true;
  AppLanguage _language = AppLanguage.en;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(freelancerProfileProvider);

    return Scaffold(
      backgroundColor: kProfileBg,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Failed to load profile: $err',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (profile) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _Header(),
                  SizedBox(height: 16.h),
                  _ProfileInfoCard(data: profile),
                  SizedBox(height: 14.h),
                  _AvailabilityCard(
                    isAvailable: _isAvailable,
                    onChanged: (val) {
                      setState(() => _isAvailable = val);
                      // এখানে চাইলে availability update API মারতে পারো
                    },
                  ),
                  SizedBox(height: 14.h),
                  _SkillsCard(skills: profile.skills),
                  SizedBox(height: 14.h),
                  _SettingsSection(
                    profile: profile,
                    language: _language,
                    onSelectLanguage: () => _showLanguageSheet(context),
                  ),
                  SizedBox(height: 24.h),
                  Signoutbutton(
                    onTap: () {
                      // TODO: auth logout logic (token clear, API/logout ইত্যাদি)
                      context.push(RoleSelectionScreen.routeName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signed out')),
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showLanguageSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: kProfileTextMain,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Choose your preferred app language',
                style: TextStyle(fontSize: 12.sp, color: kProfileTextMuted),
              ),
              SizedBox(height: 16.h),
              _LanguageTile(language: AppLanguage.en, current: _language),
              SizedBox(height: 8.h),
              _LanguageTile(language: AppLanguage.fr, current: _language),
              SizedBox(height: 8.h),
              _LanguageTile(language: AppLanguage.ar, current: _language),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _language) {
      setState(() => _language = selected);
      // এখানে localization update করবে (EasyLocalization / Riverpod)
    }
  }
}

/// ---------------------------------------------------------------------------
/// Header (yellow gradient)
/// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 18.h,
        bottom: 32.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kProfileHeaderStart, kProfileHeaderEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26.r),
          bottomRight: Radius.circular(26.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Manage your account information',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Profile main card – avatar, name, title, member since, Edit button
/// ---------------------------------------------------------------------------
class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.data});

  final FreelancerProfileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: kProfileCard,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kProfileHeaderStart, kProfileHeaderEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    data.initials,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.fullName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: kProfileTextMain,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: kProfileTextMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Member since ${data.memberSince}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kProfileTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: () {
              // Edit profile screen navigate করো
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6D8),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFB57400),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Availability status card (switch)
/// ---------------------------------------------------------------------------
class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.isAvailable, required this.onChanged});

  final bool isAvailable;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: kProfileCard,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE7FEF2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: Color(0xFF16A34A),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Availability Status',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: kProfileTextMain,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Accept new jobs',
                  style: TextStyle(fontSize: 12.sp, color: kProfileTextMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            onChanged: onChanged,
            activeColor: Colors.white,
            inactiveThumbColor: Colors.white,
            activeTrackColor: kAccentRed,
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Skills & Specializations card (API theke skills আসবে)
/// ---------------------------------------------------------------------------
class _SkillsCard extends StatelessWidget {
  const _SkillsCard({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: kProfileCard,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills & Specializations',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: kProfileTextMain,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: skills.map((s) {
              switch (s.toLowerCase()) {
                case 'electrical':
                  return const _SkillChip(
                    label: 'Electrical',
                    start: Color(0xFFFEF3C7),
                    end: Color(0xFFFDE68A),
                    textColor: Color(0xFFB45309),
                  );
                case 'plumbing':
                  return const _SkillChip(
                    label: 'Plumbing',
                    start: Color(0xFFD1FAE5),
                    end: Color(0xFFA7F3D0),
                    textColor: Color(0xFF047857),
                  );
                default:
                  return _SkillChip(
                    label: s,
                    start: const Color(0xFFE5E7EB),
                    end: const Color(0xFFD1D5DB),
                    textColor: const Color(0xFF374151),
                  );
              }
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.label,
    required this.start,
    required this.end,
    required this.textColor,
  });

  final String label;
  final Color start;
  final Color end;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start, end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Settings menu (certifications, payment settings, language, support)
/// ---------------------------------------------------------------------------
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.profile,
    required this.language,
    required this.onSelectLanguage,
  });

  final FreelancerProfileData profile;
  final AppLanguage language;
  final VoidCallback onSelectLanguage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsTile(
          iconBg: const Color(0xFFFFF7D6),
          icon: Icons.workspace_premium,
          iconColor: const Color(0xFFE5A100),
          title: 'My Certifications',
          subtitle: '${profile.verifiedCerts} verified',
          onTap: () {
            // certifications screen
          },
        ),
        SizedBox(height: 8.h),
        _SettingsTile(
          iconBg: const Color(0xFFE7FEF2),
          icon: Icons.attach_money_rounded,
          iconColor: const Color(0xFF16A34A),
          title: 'Payment Settings',
          subtitle: profile.bankLinked ? 'Bank linked' : 'Add payout method',
          onTap: () {
            // payment settings
          },
        ),
        SizedBox(height: 8.h),
        _SettingsTile(
          iconBg: const Color(0xFFE0F2FE),
          icon: Icons.language_outlined,
          iconColor: const Color(0xFF2563EB),
          title: 'Language',
          subtitle: language.display,
          onTap: onSelectLanguage,
        ),
        SizedBox(height: 8.h),
        _SettingsTile(
          iconBg: const Color(0xFFFFF4E5),
          icon: Icons.help_outline_rounded,
          iconColor: const Color(0xFFF97316),
          title: 'Support',
          subtitle: 'Get help & contact us',
          onTap: () {
            // support route
          },
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: kProfileCard,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: kProfileTextMain,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kProfileTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Language option row used in bottom sheet
/// ---------------------------------------------------------------------------
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.language, required this.current});

  final AppLanguage language;
  final AppLanguage current;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = language == current;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop<AppLanguage>(language),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF4D7) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? kProfileHeaderStart : kProfileBorderLight,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.language_outlined,
              color: isSelected ? kProfileHeaderStart : kProfileTextMuted,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.display,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: kProfileTextMain,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    language.secondary,
                    style: TextStyle(fontSize: 11.sp, color: kProfileTextMuted),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: kProfileHeaderStart,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
