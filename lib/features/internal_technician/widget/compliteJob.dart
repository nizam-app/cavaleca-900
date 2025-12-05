import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/internal_technician/screen/job/logic/internal_job_logic.dart';

/// ------------------------------------------------------
///  Colors (same style as Job Details popup)
/// ------------------------------------------------------
const Color kDialogBg = Color(0xFFF4F4F4);
const Color kCardBg = Colors.white;
const Color kTextMain = Color(0xFF222222);
const Color kTextMuted = Color(0xFF9E9E9E);
const Color kTextSubtle = Color(0xFFB0B0B0);
const Color kPrimaryGreen = Color(0xFF00B357);
const Color kBorderLight = Color(0xFFE5E5E5);

class Complitejob extends StatelessWidget {
  final int woId;
  final double jobPayment;
  final double bonusRate;

  const Complitejob({
    super.key,
    required this.woId,
    this.jobPayment = 150,
    this.bonusRate = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    final bonus = jobPayment * bonusRate;

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
                  _buildWorkPhotosCard(
                    onTap: () async {
                      try {
                        await TechnicianJobsApi.completeWorkOrder(
                          woId: woId,
                          completionNotes:
                              '', // আপাতত ফাঁকা, চাইলে TextField থেকে নেবে
                          materialsUsedJson:
                              '[]', // পরে materials list থেকে বানাবে
                        );

                        Navigator.of(context).pop(); // close Complete dialog
                        Navigator.of(context).pop(); // close Jobdetails dialog

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job completed successfully'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to complete job: $e')),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 14.h),
                  _buildNotesField(),
                  SizedBox(height: 14.h),
                  _buildBonusCard(jobPayment, bonusRate, bonus),
                  SizedBox(height: 20.h),
                  _buildBottomButtons(context),
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
            SizedBox(width: 24.w),
            Expanded(
              child: Text(
                'Complete Job',
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
          'Upload photos and add notes about the\ncompleted work',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: kTextMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// -------------------  WORK PHOTOS  ------------------
  Widget _buildWorkPhotosCard({required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work Photos *',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: kTextMain,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: kBorderLight, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 40.w,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 22.sp,
                    color: kTextMuted,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Tap to upload photos',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: kTextMain,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'At least 1 photo required',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: kTextSubtle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// -------------------  NOTES FIELD  ------------------
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work Notes (Optional)',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: kTextMain,
          ),
        ),
        SizedBox(height: 8.h),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(20.r),
            //border: Border.all(color: kTextMuted, width: 0.5.w),
          ),

          child: TextField(
            maxLines: 4,
            style: TextStyle(
              fontSize: 12.sp,
              // color: kTextMain,
            ),
            decoration: InputDecoration(
              hintText: 'Add any notes about the work completed',
              hintStyle: TextStyle(fontSize: 12.sp, color: kTextMuted),
              // border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  /// -------------------  BONUS CARD  -------------------
  Widget _buildBonusCard(
    double jobPayment,
    double bonusRate,
    double bonusValue,
  ) {
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
                  'Bonus Calculation',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Job Payment:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kPrimaryGreen,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '\$${jobPayment.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bonus Rate:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kPrimaryGreen,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '${(bonusRate * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: const Color(0xFFD6F2E2), height: 1.h, thickness: 1),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Your Bonus:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryGreen,
                  ),
                ),
              ),
              Text(
                '\$${bonusValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Paid every Monday with your weekly bonuses',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: kPrimaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------  BOTTOM BUTTONS  ---------------
  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Container(
              height: 46.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: complete job logic here
            },
            child: Container(
              height: 46.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kPrimaryGreen,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Complete Job',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
}
