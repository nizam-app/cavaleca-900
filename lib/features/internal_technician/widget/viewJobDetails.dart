import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'gPSCheckInPopup.dart';
import '../screen/job/model/internal_job_model.dart';
import '../screen/job/logic/internal_job_logic.dart';

/// ------------------- COLORS --------------------
const kDialogBg = Color(0xFFF4F4F4);
const kCardBg = Colors.white;
const kTextMain = Color(0xFF222222);
const kTextMuted = Color(0xFF9E9E9E);
const kTextSubtle = Color(0xFFB0B0B0);
const kPrimaryGreen = Color(0xFF00B357);
const kPrimaryBlue = Color(0xFF2563EB);
const kBorderLight = Color(0xFFE5E5E5);

class Viewjobdetails extends StatelessWidget {
  final InternalJob job;
  final Function(InternalJob)? onJobUpdate;
  final double bonusRate;

  const Viewjobdetails({
    super.key,
    required this.job,
    this.onJobUpdate,
    this.bonusRate = 5.0,
  });

  double _calculateBonus(String payment) {
    final sanitized = payment.replaceAll('\$', '').replaceAll(',', '');
    final amount = double.tryParse(sanitized) ?? 0;
    return (amount * bonusRate) / 100;
  }

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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 18.h),
                  _buildStatusChips(),
                  SizedBox(height: 18.h),
                  _buildJobCard(),
                  SizedBox(height: 12.h),
                  _buildCustomerCard(),
                  SizedBox(height: 12.h),
                  _buildLocationCard(),
                  SizedBox(height: 12.h),
                  _buildScheduleCard(),
                  SizedBox(height: 14.h),
                  _buildBonusCard(),
                  SizedBox(height: 20.h),
                  _buildStartButton(context),
                  SizedBox(height: 10.h),
                  _buildCloseButton(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 24.w),
            Expanded(
              child: Text(
                "job_details".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: kTextMain,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, size: 20.sp, color: Colors.grey),
            )
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          "ready_to_start".tr(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: kTextMuted,
          ),
        )
      ],
    );
  }

  // ---------------- STATUS CHIPS ----------------
  Widget _buildStatusChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip(
          "accepted_ready".tr(),
          const Color(0xFFFFF7CC),
          Colors.amber.shade800,
        ),
        if (job.priority != null) ...[
          SizedBox(width: 6.w),
          _chip(
            job.priority == JobPriority.high
                ? "high_priority".tr()
                : job.priority == JobPriority.medium
                    ? "medium_priority".tr()
                    : "low_priority".tr(),
            job.priority == JobPriority.high
                ? const Color(0xFFFFE5E5)
                : job.priority == JobPriority.medium
                    ? const Color(0xFFFFF0D5)
                    : const Color(0xFFE5F5E5),
            job.priority == JobPriority.high
                ? Colors.red.shade700
                : job.priority == JobPriority.medium
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
          ),
        ],
      ],
    );
  }

  Widget _chip(String text, Color bg, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  // ---------------- JOB DESCRIPTION CARD ----------------
  Widget _buildJobCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: kTextMain),
          ),
          if (job.category != null) ...[
            SizedBox(height: 4.h),
            Text(
              job.category!,
              style: TextStyle(fontSize: 12.sp, color: Colors.red.shade500, fontWeight: FontWeight.w500),
            ),
          ],
          if (job.description != null && job.description!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              job.description!,
              style: TextStyle(fontSize: 12.sp, height: 1.4, color: kTextMuted),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- CUSTOMER CARD ----------------
  Widget _buildCustomerCard() {
    return _card(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "customer".tr(),
                  style: TextStyle(fontSize: 11.sp, color: kTextSubtle, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 6.h),
                Text(
                  job.customer,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: kTextMain),
                ),
                if (job.customerPhone != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    job.customerPhone!,
                    style: TextStyle(fontSize: 12.sp, color: kTextMuted, fontWeight: FontWeight.w400),
                  ),
                ],
              ],
            ),
          ),
          if (job.customerPhone != null)
            Container(
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Icon(Icons.phone, color: Colors.white, size: 20.sp),
            ),
        ],
      ),
    );
  }

  // ---------------- LOCATION CARD ----------------
  Widget _buildLocationCard() {
    final address = job.address ?? job.location;
    return _card(
      Row(
        children: [
          _circleIcon(Icons.location_on_rounded, Colors.red.shade100, Colors.red),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "location".tr(),
                  style: TextStyle(fontSize: 11.sp, color: kTextSubtle, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4.h),
                Text(
                  address,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: kTextMain),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SCHEDULE CARD ----------------
  Widget _buildScheduleCard() {
    final dateTime = '${job.date}${job.time != null ? ' at ${job.time}' : ''}';
    return _card(
      Row(
        children: [
          _circleIcon(Icons.calendar_month_rounded, Colors.blue.shade50, Colors.blue.shade600),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "scheduled".tr(),
                  style: TextStyle(fontSize: 11.sp, color: kTextSubtle, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4.h),
                Text(
                  dateTime,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: kTextMain),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- BONUS CARD ----------------
  Widget _buildBonusCard() {
    final bonus = _calculateBonus(job.payment);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFE7FAF0), Color(0xFFF4FFF9)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money_rounded, size: 20.sp, color: kPrimaryGreen),
              SizedBox(width: 4.w),
              Text(
                "performance_bonus".tr(),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: kPrimaryGreen),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "\$${bonus.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: kPrimaryGreen),
          ),
          SizedBox(height: 4.h),
          Text(
            "from ${job.payment} job",
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: kPrimaryGreen),
          ),
        ],
      ),
    );
  }

  // ---------------- PRIMARY ACTION BUTTON ----------------
  Widget _buildStartButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Close current dialog
        Navigator.pop(context);
        
        // Show GPS popup -> Map screen -> Start job
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => Gpscheckinpopup(
            jobAddress: job.address ?? job.location,
            onLocationVerified: (lat, lng) async {
              // Location verified from map, now start the job
              try {
                final updated = await TechnicianJobsApi.startWorkOrder(
                  woId: job.id,
                  lat: lat,
                  lng: lng,
                );
                
                // Preserve payment and bonus if API response has $0.00
                final paymentToUse = updated.payment == '\$0.00' ? job.payment : updated.payment;
                final bonusToUse = updated.bonus == '\$0.00' ? job.bonus : updated.bonus;
                
                final finalUpdated = updated.copyWith(
                  payment: paymentToUse,
                  bonus: bonusToUse,
                );
                
                // Notify parent about job update
                if (onJobUpdate != null) {
                  onJobUpdate!(finalUpdated);
                }
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('job_started_successfully'.tr()),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${'failed_to_start_job'.tr()}: $e')),
                  );
                }
              }
            },
          ),
        );
      },
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: kPrimaryBlue,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              "start_job".tr(),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CLOSE BUTTON ----------------
  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: (){
        context.pop();
      },
      child: Container(
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: kBorderLight),
        ),
        child: Text(
          "close".tr(),
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: kTextMain),
        ),
      ),
    );
  }

  // ---------------- REUSABLE ----------------
  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _circleIcon(IconData icon, Color bg, Color color) {
    return Container(
      height: 36.w,
      width: 36.w,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }
}
