import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ------------------------------------------------------
///  Colors
/// ------------------------------------------------------
const kFDOverlayBg = Color(0x59000000); // black 35%
const kFDSheetBg = Color(0xFFF4F4F6);

const kFDDarkTop1 = Color(0xFF020617);
const kFDDarkTop2 = Color(0xFF0F172A);

const kFDInnerDark = Color(0xFF111827);
const kFDProgressBg = Color(0xFF4B5563);
const kFDProgressFill = Color(0xFF22C55E);

const kFDTextMain = Color(0xFF111827);
const kFDTextSubtle = Color(0xFF6B7280);
const kFDTextMuter = Color(0xFF9CA3AF);

const kFDCardBg = Colors.white;
const kFDChipPendingBg = Colors.white;
const kFDChipPendingText = Color(0xFF111827);
const kFDChipHighBg = Color(0xFFDC2626);
const kFDChipHighText = Colors.white;

const kFDCallBg = Color(0xFFFFE4E6);
const kFDCallIcon = Color(0xFFDC2626);

const kFDDeclineBorder = Color(0xFFE5E7EB);
const kFDDeclineText = Color(0xFF6B7280);

const kFDAcceptBg = Color(0xFFFFB111);
const kFDAcceptText = Color(0xFF111827);

/// ------------------------------------------------------
///  Simple Job model (আপনি চাইলে নিজের model use করে map করবেন)
/// ------------------------------------------------------
class FreelancerJob {
  final int id;
  final String title;
  final String customerName;
  final String? customerPhone;
  final String category;
  final String description;
  final String location; // short
  final String address;  // full
  final String dateLabel; // e.g. "Nov 5, 2025"
  final String timeLabel; // e.g. "3:00 PM"
  final String payment;   // "$85"
  final String commission; // "$65"
  final bool highPriority;

  FreelancerJob({
    required this.id,
    required this.title,
    required this.customerName,
    this.customerPhone,
    required this.category,
    required this.description,
    required this.location,
    required this.address,
    required this.dateLabel,
    required this.timeLabel,
    required this.payment,
    required this.commission,
    this.highPriority = true,
  });
}

/// ------------------------------------------------------
///  SHOW HELPER
/// ------------------------------------------------------
/// Call this from your screen:
///
///   showFreelancerDetailsPopup(
///     context: context,
///     job: yourJob,
///     responseTimeLimitSeconds: 120,
///     onAccept: () { … },
///     onDecline: () { … },
///   );
///
Future<void> showFreelancerDetailsPopup({
  required BuildContext context,
  required FreelancerJob job,
  int responseTimeLimitSeconds = 120,
  required VoidCallback onAccept,
  required VoidCallback onDecline,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: kFDOverlayBg,
    builder: (_) => FreelancerDetailsPopup(
      job: job,
      responseTimeLimitSeconds: responseTimeLimitSeconds,
      onAccept: onAccept,
      onDecline: onDecline,
    ),
  );
}

/// ------------------------------------------------------
///  MAIN POPUP WIDGET
/// ------------------------------------------------------
class FreelancerDetailsPopup extends StatefulWidget {
  const FreelancerDetailsPopup({
    super.key,
    required this.job,
    required this.responseTimeLimitSeconds,
    required this.onAccept,
    required this.onDecline,
  });

  final FreelancerJob job;
  final int responseTimeLimitSeconds;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<FreelancerDetailsPopup> createState() => _FreelancerDetailsPopupState();
}

class _FreelancerDetailsPopupState extends State<FreelancerDetailsPopup> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.responseTimeLimitSeconds;
    _startTimer();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        t.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get _progress {
    if (widget.responseTimeLimitSeconds == 0) return 0;
    return _remainingSeconds / widget.responseTimeLimitSeconds;
  }

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    final mm = m.toString().padLeft(1, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Material(
      color: kFDOverlayBg,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: 0.92.sh,
          ),
          decoration: BoxDecoration(
            color: kFDSheetBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              SizedBox(height: 8.h),
              _buildTopDarkCard(job),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  child: Column(
                    children: [
                      _buildCustomerCard(job),
                      SizedBox(height: 14.h),
                      _buildJobDetailsCard(job),
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- TOP DARK SECTION ----------------
  Widget _buildTopDarkCard(FreelancerJob job) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding:
      EdgeInsets.only(top: 14.h, bottom: 14.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kFDDarkTop1, kFDDarkTop2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22.r),
          topRight: Radius.circular(22.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: SR id + close
          Row(
            children: [
              Expanded(
                child: Text(
                  'Service Request #SR-${job.id.toString().padLeft(4, '0')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11.sp,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Title
          Text(
            job.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),

          // Status chips
          Row(
            children: [
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: kFDChipPendingBg,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  'PENDING',
                  style: TextStyle(
                    color: kFDChipPendingText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              if (job.highPriority)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: kFDChipHighBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'HIGH PRIORITY',
                    style: TextStyle(
                      color: kFDChipHighText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),

          // Inner response-time card
          Container(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
            decoration: BoxDecoration(
              color: kFDInnerDark,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Response Time',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        _formattedTime,
                        style: TextStyle(
                          color: kFDProgressFill,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: Container(
                    height: 7.h,
                    color: kFDProgressBg,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progress.clamp(0.0, 1.0),
                        child: Container(color: kFDProgressFill),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please review and respond to this work order',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- CUSTOMER CARD ----------------
  Widget _buildCustomerCard(FreelancerJob job) {
    final initials = job.customerName.isNotEmpty
        ? job.customerName
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        : '?';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: kFDCardBg,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFF7E6),
            ),
            child: Center(
              child: Text(
                initials.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.customerName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: kFDTextMain,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      Icons.star,
                      size: 14.sp,
                      color: const Color(0xFFFBBF24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (job.customerPhone != null && job.customerPhone!.isNotEmpty)
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kFDCallBg,
              ),
              child: Icon(
                Icons.phone_rounded,
                size: 20.sp,
                color: kFDCallIcon,
              ),
            ),
        ],
      ),
    );
  }

  /// ---------------- JOB DETAILS CARD ----------------
  Widget _buildJobDetailsCard(FreelancerJob job) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: kFDCardBg,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.build_outlined,
                size: 18.sp,
                color: kFDTextSubtle,
              ),
              SizedBox(width: 6.w),
              Text(
                'Job Details',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: kFDTextMain,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          _DetailRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: job.category,
          ),
          SizedBox(height: 8.h),

          _DetailRow(
            icon: Icons.info_outline,
            label: 'Description',
            value: job.description,
            multiline: true,
          ),
          SizedBox(height: 8.h),

          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: '${job.address}',
            multiline: true,
          ),
          SizedBox(height: 8.h),

          _DetailRow(
            icon: Icons.access_time,
            label: 'Schedule',
            value: '${job.dateLabel} at ${job.timeLabel}',
          ),
          SizedBox(height: 8.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.attach_money,
                size: 16.sp,
                color: kFDTextSubtle,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kFDTextSubtle,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          job.payment,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: kFDTextMain,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Commission: ${job.commission}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF9FAFB),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              onPressed: () {
                // TODO: open in maps
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      size: 18.sp,
                      color: kFDTextSubtle,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Open in Maps',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: kFDTextMain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- BOTTOM BUTTONS ----------------
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      color: kFDSheetBg,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: kFDDeclineBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              onPressed: () {
                widget.onDecline();
                Navigator.of(context).pop(); // বন্ধ করে দাও
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Text(
                  'Decline',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: kFDDeclineText,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kFDAcceptBg,
                foregroundColor: kFDAcceptText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              onPressed: () {
                widget.onAccept();
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Text(
                  'Accept Job',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
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

/// ------------------------------------------------------
///  Detail row widget
/// ------------------------------------------------------
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: kFDTextSubtle,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: kFDTextSubtle,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: kFDTextMain,
                  height: multiline ? 1.4 : 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
