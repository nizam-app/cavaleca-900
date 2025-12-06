import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/customer/screen/service/model/create_sr_model.dart';

const _kDialogShadow = BoxShadow(
  color: Color(0x22000000),
  blurRadius:
      18, // No direct equivalent, keeping as is or using .r if it makes sense. Let's keep.
  offset: Offset(0, 6), // Keeping as is.
);

class ServiceTypeOption {
  final int id;
  final String title;
  final String subtitle;
  final FsmService service; // NEW

  ServiceTypeOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.service,
  });
}

/// Example call:
/// await showServiceTypeDialog(
///   context,
///   title: 'General Maintenance',
///   stepText: 'Step 2 of 3 - Select service type',
///   options: [
///     ServiceTypeOption(
///       title: 'Repairs & Fixes',
///       subtitle: '4 services available',
///     ),
///     ServiceTypeOption(
///       title: 'Installation',
///       subtitle: '3 services available',
///     ),
///     ServiceTypeOption(
///       title: 'Inspection',
///       subtitle: '2 services available',
///     ),
///   ],
///   onSelect: (opt) {
///     // TODO: handle selection
///   },
/// );
Future<void> showServiceTypeDialog(
  BuildContext context, {
  required String title,
  required String stepText,
  required List<ServiceTypeOption> options,
  ValueChanged<ServiceTypeOption>? onSelect,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Select service type',
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (_, __, ___) {
      return _ServiceTypeDialog(
        title: title,
        stepText: stepText,
        options: options,
        onSelect: onSelect,
      );
    },
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ServiceTypeDialog extends StatelessWidget {
  const _ServiceTypeDialog({
    required this.title,
    required this.stepText,
    required this.options,
    this.onSelect,
  });

  final String title;
  final String stepText;
  final List<ServiceTypeOption> options;
  final ValueChanged<ServiceTypeOption>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Container(
              width: 420.w,
              constraints: BoxConstraints(maxHeight: 480.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: const [_kDialogShadow],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    Divider(height: 1.h, color: const Color(0xFFF3F4F6)),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: options.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final opt = options[index];
                          return _ServiceTypeTile(
                            title: opt.title,
                            subtitle: opt.subtitle,
                            onTap: () {
                              Navigator.of(context).pop();
                              onSelect?.call(opt);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 14.h,
        bottom: 12.h,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          // back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18, // Using .r or .sp for icons is often good
              color: Color(0xFF4B5563),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  stepText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _ServiceTypeTile extends StatelessWidget {
  const _ServiceTypeTile({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12, // Keep
                offset: Offset(0, 4), // Keep
              ),
            ],
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18.r,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
