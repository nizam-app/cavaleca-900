import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/internal_technician/screen/job/model/internal_job_model.dart';

import 'package:easy_localization/easy_localization.dart';
import 'compliteJob.dart';

/// ------------------------------------------------------
///  Colors
/// ------------------------------------------------------
const Color kDialogBg = Color(0xFFF4F4F4);
const Color kCardBg = Colors.white;
const Color kTextMain = Color(0xFF222222);
const Color kTextMuted = Color(0xFF9E9E9E);
const Color kTextSubtle = Color(0xFFB0B0B0);
const Color kPrimaryGreen = Color(0xFF00B357);
const Color kPrimaryRed = Color(0xFFE53935);
const Color kAccentBlue = Color(0xFF1E88E5);
const Color kBorderLight = Color(0xFFE5E5E5);

class Jobdetails extends StatelessWidget {
  final InternalJob job;
  final Function(InternalJob)? onJobCompleted;

  const Jobdetails({super.key, required this.job, this.onJobCompleted});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      child: Container(
        width: 320.w,
        decoration: BoxDecoration(
          color: kDialogBg,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 18.h),
                  _buildStatusChips(),
                  SizedBox(height: 18.h),
                  _buildJobInfoCard(),
                  SizedBox(height: 12.h),
                  _buildCustomerCard(),
                  SizedBox(height: 12.h),
                  _buildLocationCard(),
                  SizedBox(height: 12.h),
                  _buildScheduleCard(),
                  SizedBox(height: 12.h),
                  _buildBonusCard(),
                  SizedBox(height: 20.h),
                  _buildCompleteButton(context),
                  SizedBox(height: 10.h),
                  _buildCloseButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------  HEADER  -----------------------
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 24.w), // to balance close icon on right
            Expanded(
              child: Text(
                'job_details'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: kTextMain,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.close,
                size: 20.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'job_in_progress_title'.tr(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: kTextMuted,
          ),
        ),
      ],
    );
  }

  /// -------------------  STATUS CHIPS  -----------------
  Widget _buildStatusChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatusChip(
          label: 'in_progress'.tr(),
          bgColor: const Color(0xFFE7F0FF),
          textColor: kAccentBlue,
        ),
        if (job.priority != null) ...[
          SizedBox(width: 8.w),
          _StatusChip(
            label: job.priority == JobPriority.high
                ? 'high_priority'.tr()
                : job.priority == JobPriority.medium
                    ? 'medium_priority'.tr()
                    : 'low_priority'.tr(),
            bgColor: job.priority == JobPriority.high
                ? const Color(0xFFFFE6E6)
                : job.priority == JobPriority.medium
                    ? const Color(0xFFFFF0D5)
                    : const Color(0xFFE5F5E5),
            textColor: job.priority == JobPriority.high
                ? kPrimaryRed
                : job.priority == JobPriority.medium
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
          ),
        ],
      ],
    );
  }

  /// -------------------  JOB CARD  ---------------------
  Widget _buildJobInfoCard() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: kTextMain,
            ),
          ),
          if (job.category != null) ...[
            SizedBox(height: 4.h),
            Text(
              job.category!,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: kPrimaryRed,
              ),
            ),
          ],
          if (job.description != null && job.description!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              job.description!,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: kTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// -------------------  CUSTOMER CARD  ----------------
  Widget _buildCustomerCard() {
    return _CardContainer(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'customer'.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: kTextSubtle,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  job.customer,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: kTextMain,
                  ),
                ),
                if (job.customerPhone != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    job.customerPhone!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: kTextMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (job.customerPhone != null)
            SizedBox(width: 12.w),
          if (job.customerPhone != null)
            Container(
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                color: kPrimaryRed,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Icon(Icons.phone, size: 20.sp, color: Colors.white),
            ),
        ],
      ),
    );
  }

  /// -------------------  LOCATION CARD  ----------------
  Widget _buildLocationCard() {
    final address = job.address ?? job.location;
    return _CardContainer(
      child: Row(
        children: [
          _CircleIcon(
            icon: Icons.location_on_rounded,
            bgColor: const Color(0xFFFFEAEA),
            iconColor: kPrimaryRed,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'location'.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: kTextSubtle,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: kTextMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------  SCHEDULE CARD  ----------------
  Widget _buildScheduleCard() {
    final dateTime = '${job.date}${job.time != null ? ' at ${job.time}' : ''}';
    return _CardContainer(
      child: Row(
        children: [
          _CircleIcon(
            icon: Icons.calendar_month_rounded,
            bgColor: const Color(0xFFE8F1FF),
            iconColor: kAccentBlue,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'scheduled'.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: kTextSubtle,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  dateTime,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: kTextMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------  COMMISSION CARD  -------------------
  Widget _buildBonusCard() {
    // Use yourBonus from API if available, otherwise calculate from bonusRate
    final bonusAmount = job.yourBonus ?? 
        (job.bonusRate != null 
            ? (double.tryParse(job.payment.replaceAll('\$', '').replaceAll(',', '')) ?? 0) * job.bonusRate! / 100
            : 0);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFE7FAF0), Color(0xFFF4FFF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                size: 20.sp,
                color: kPrimaryGreen,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  job.bonusRate != null 
                      ? "Performance Commission (${job.bonusRate!.toStringAsFixed(0)}%)"
                      : 'performance_bonus'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '\$${bonusAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: kPrimaryGreen,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'from ${job.payment} job',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: kTextSubtle,
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------  BUTTONS  ----------------------
  Widget _buildCompleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => Complitejob(
              woId: job.id,
              job: job,
              onJobCompleted: onJobCompleted,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 20.sp,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            Text(
              'complete_job'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: kCardBg,
          side: BorderSide(color: kBorderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'close'.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: kTextMain,
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Small reusable widgets
/// ------------------------------------------------------
class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _StatusChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _CircleIcon({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.w,
      width: 36.w,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Icon(icon, size: 20.sp, color: iconColor),
    );
  }
}
