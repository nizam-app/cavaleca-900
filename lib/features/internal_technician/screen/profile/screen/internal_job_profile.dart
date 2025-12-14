import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/core/widget/global_language_dialog.dart';
import 'package:workpleis/core/widget/log_out_utton.dart';
import 'package:workpleis/features/auth/screens/role/screen/role_selection_screen.dart';
import 'package:workpleis/features/customer/screen/profile/logic/logout_logic.dart';
import 'package:workpleis/features/internal_technician/screen/profile/data/internal_profile_data.dart';
import 'package:workpleis/features/internal_technician/screen/profile/model/internal_profile_modle.dart';
import 'package:workpleis/features/shared/location_update_service.dart';
import 'package:workpleis/features/shared/screen/edit_profile_screen.dart';

/// ------------------ COLORS ------------------
const kBG = Color(0xFFF4F4F4);
const kCard = Colors.white;
const kTextMain = Color(0xFF1F1F1F);
const kTextMuted = Color(0xFF9E9E9E);
const kDarkHeader = Color(0xFF1E2432);
const kBorderLight = Color(0xFFEAEAEA);

class InternalJobProfile extends ConsumerStatefulWidget {
  const InternalJobProfile({super.key});
  static const String routeName = '/internal-jobProfile';

  @override
  ConsumerState<InternalJobProfile> createState() => _InternalJobProfileState();
}

class _InternalJobProfileState extends ConsumerState<InternalJobProfile> {
  bool _isLocationUpdating = false;

  Future<void> _updateLocationStatus(bool isOnline) async {
    setState(() => _isLocationUpdating = true);

    try {
      await LocationUpdateService.updateLocationStatus(
        status: isOnline ? 'ONLINE' : 'OFFLINE',
      );

      // Invalidate the profile provider to refresh the data
      ref.invalidate(internalProfileProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('location_status_updated'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'failed_to_update_location_status'.tr()}: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLocationUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(internalProfileProvider);

    return Scaffold(
      backgroundColor: kBG,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${'failed_to_load_profile'.tr()}\n$err')),
        data: (profile) {
          final tech = profile.technicianProfile;
          final isAvailable = profile.locationStatus?.toUpperCase() == 'ONLINE';

          return SingleChildScrollView(
            child: Column(
              children: [
                _headerSection(),
                SizedBox(height: 16.h),
                _profileCard(context, profile, tech),
                SizedBox(height: 16.h),
                _AvailabilityCard(
                  isAvailable: isAvailable,
                  isLoading: _isLocationUpdating,
                  onChanged: (val) => _updateLocationStatus(val),
                ),
                SizedBox(height: 16.h),
                if (tech != null) _employmentDetails(tech),
                SizedBox(height: 16.h),
                if (tech != null) _specializations(tech),
                SizedBox(height: 16.h),
                _settingsItems(tech, context),

                SizedBox(height: 40.h),
                Signoutbutton(onTap: () => _confirmAndLogout(context)),

                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('confirm'.tr()),
          content: Text('are_you_sure_you_want_to_sign_out'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'yes'.tr(),
                style: const TextStyle(color: Color(0xFFC20001)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await CustomerLogOut.logout(); // 👈 same logic as CustomerProfileScreen
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('logout_successful'.tr())));
      context.go(
        RoleSelectionScreen.routeName,
      ); // stack clear kore role selection e
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${'logout_failed'.tr()}: $e')));
    }
  }

  // ----------------------------------------------------
  // Header Section
  // ----------------------------------------------------
  Widget _headerSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: kTextMain,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22.r),
          bottomRight: Radius.circular(22.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "profile".tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "manage_account_info".tr(),
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Availability Status Card
  // ----------------------------------------------------
  Widget _AvailabilityCard({
    required bool isAvailable,
    required bool isLoading,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: _cardDecoration(),
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
                  'availability_status'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: kTextMain,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'accept_new_jobs'.tr(),
                  style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                ),
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: isAvailable,
              onChanged: onChanged,
              activeColor: Colors.white,
              inactiveThumbColor: Colors.white,
              activeTrackColor: const Color(0xFFC20001),
              inactiveTrackColor: const Color(0xFFE5E7EB),
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Profile Card
  // ----------------------------------------------------
  Widget _profileCard(BuildContext context, InternalProfile profile, TechnicianProfile? tech) {
    final initials = _getInitials(profile.name);
    final roleLabel = tech?.position ?? "internal_technician".tr();
    final employeeId = 'TECH-${profile.id}';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              _circleAvatar(initials),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: kTextMain,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      roleLabel,
                      style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                    ),
                    Text(
                      "${'employee_id'.tr()}: $employeeId",
                      style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _simpleButton(context, "edit_profile".tr()),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].isNotEmpty ? parts[0][0] : '') +
        (parts[1].isNotEmpty ? parts[1][0] : '');
  }

  Widget _circleAvatar(String txt) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Center(
        child: Text(
          txt,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
    );
  }

  Widget _simpleButton(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        // Profile will auto-refresh when we come back
        // because provider is invalidated in edit screen
        context.push(EditProfileScreen.routeName);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: kBorderLight,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: kBorderLight),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Employment Details Card
  // ----------------------------------------------------
  Widget _employmentDetails(TechnicianProfile tech) {
    final joinDateStr = tech.joinDate != null
        ? "${tech.joinDate!.day.toString().padLeft(2, '0')}-"
              "${tech.joinDate!.month.toString().padLeft(2, '0')}-"
              "${tech.joinDate!.year}"
        : '-';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "employment_details".tr(),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kTextMain,
            ),
          ),
          SizedBox(height: 14.h),
          _rowItem("department".tr(), tech.department ?? "n_a".tr()),
          SizedBox(height: 10.h),
          _rowItem("join_date".tr(), joinDateStr),
          SizedBox(height: 10.h),
          _rowItem("position".tr(), tech.position ?? "n_a".tr()),
        ],
      ),
    );
  }

  Widget _rowItem(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(fontSize: 13.sp, color: kTextMuted),
        ),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              right,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                color: kTextMain,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // Specializations (skills + specialization)
  // ----------------------------------------------------
  Widget _specializations(TechnicianProfile tech) {
    final List<String> items = [
      if (tech.specialization != null && tech.specialization!.isNotEmpty)
        ...tech.specialization!.split(',').map((e) => e.trim()),
      ...tech.skills,
    ].toSet().toList(); // remove duplicates

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "specializations".tr(),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kTextMain,
            ),
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            Text(
              'no_specializations_added'.tr(),
              style: TextStyle(fontSize: 12.sp, color: kTextMuted),
            )
          else
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: items
                  .map(
                    (s) => _chip(s, Colors.blue.shade50, Colors.blue.shade900),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Settings List (uses certifications count etc.)
  // ----------------------------------------------------
  Widget _settingsItems(TechnicianProfile? tech, BuildContext context) {
    final certificationsCount = tech?.certifications.length ?? 0;

    // current locale theke language code + name
    final currentCode = context.locale.languageCode;
    final currentLanguage = _languageNativeName(currentCode);

    return Column(
      children: [
        _listItem(
          Icons.calendar_month,
          "time_off_requests".tr(),
          "pending_two".tr(), // static for now
          const Color(0xFFE8F0FF),
          const Color(0xFF2563EB),
        ),
        _listItem(
          Icons.workspace_premium,
          "certifications".tr(),
          "$certificationsCount ${'active'.tr()}",
          const Color(0xFFFFF4D9),
          Colors.orange,
        ),
        _listItem(
          Icons.work_history_rounded,
          "work_history".tr(),
          "view".tr(),
          const Color(0xFFF3E8FF),
          Colors.purple,
        ),
        // 🔥 Language row: opens LanguageDialog
        _listItem(
          Icons.language,
          "language".tr(),
          currentLanguage, // English / Français
          const Color(0xFFE8FFF4),
          Colors.green,
          onTap: () => _openLanguageDialog(context),
        ),
        _listItem(
          Icons.support_agent,
          "support".tr(),
          "",
          const Color(0xFFFFF0E0),
          Colors.deepOrange,
        ),
      ],
    );
  }

  Future<void> _openLanguageDialog(BuildContext context) async {
    final currentCode = context.locale.languageCode;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return LanguageDialog(currentCode: currentCode);
      },
    );

    if (selected != null && selected != currentCode) {
      await context.setLocale(Locale(selected)); // EasyLocalization change

      final newName = _languageNativeName(selected);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${'language_updated_to'.tr()} $newName')));
    }
  }

  String _languageNativeName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      // case 'ar':
      //   return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }

  Widget _listItem(
    IconData icon,
    String title,
    String subtitle,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap, // ⬅️ NEW
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
        padding: EdgeInsets.all(14.w),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 22.sp, color: iconColor),
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
                      color: kTextMain,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: kTextMuted),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Card Decoration
  // ----------------------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(18.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
