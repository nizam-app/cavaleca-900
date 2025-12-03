import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../screen/internal_jobs.dart';

class JobDetailOverlay extends StatefulWidget {
  const JobDetailOverlay({
    super.key,
    required this.job,
    required this.responseTimeLimitSeconds,
    required this.onClose,
    required this.onAccept,
    required this.onDecline,
  });

  final Job job;
  final int responseTimeLimitSeconds;
  final VoidCallback onClose;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<JobDetailOverlay> createState() => _JobDetailOverlayState();
}

class _JobDetailOverlayState extends State<JobDetailOverlay> {
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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        timer.cancel();
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
      color: Colors.black.withOpacity(0.35),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: 0.9.sh,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 24.r,
                offset: Offset(0, -8.h),
              ),
            ],
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

              // ---------------- TOP DARK CARD (exactly like screenshot) ----------------
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.only(top:  14.h , bottom: 14.h, left: 16.w, right: 16.w ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                     // Colors.red,
                      Color(0xFF020617), // very dark navy
                      Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(22.r) ,topLeft: Radius.circular(22.r)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // first row: SR id + close
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Service Request #SR-${job.id.toString().padLeft(4, '0')}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11.sp,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: widget.onClose,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    // title
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

                    // status badges
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            'PENDING',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            'HIGH PRIORITY',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // inner dark card: Response Time + progress bar + subtitle
                    Container(
                      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111825),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // row: icon + "Response Time" + timer pill
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
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999.r),
                                ),
                                child: Text(
                                  _formattedTime,
                                  style: TextStyle(
                                    color: const Color(0xFF16A34A),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999.r),
                            child: Container(
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4B5563),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _progress.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF22C55E),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
              ),

              // ---------------- BODY (same as age) ----------------

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.w),
                  child: Column(
                    children: [
                      // customer card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  job.customer.isNotEmpty
                                      ? job.customer[0]
                                      : '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.sp,
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
                                    job.customer,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF111827),
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
                            if (job.customerPhone != null &&
                                job.customerPhone!.isNotEmpty)
                              Container(
                                width: 38.w,
                                height: 38.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.phone_rounded,
                                  size: 20.sp,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Job details card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                  Icons.description_outlined,
                                  size: 18.sp,
                                  color: const Color(0xFF4B5563),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Job Details',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            _DetailRow(
                              icon: Icons.category_outlined,
                              label: 'Category',
                              value: job.category ?? 'N/A',
                            ),
                            SizedBox(height: 8.h),

                            if (job.description != null &&
                                job.description!.isNotEmpty) ...[
                              _DetailRow(
                                icon: Icons.notes_outlined,
                                label: 'Description',
                                value: job.description!,
                                multiline: true,
                              ),
                              SizedBox(height: 8.h),
                            ],

                            _DetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: job.address?.isNotEmpty == true
                                  ? '${job.location}\n${job.address}'
                                  : job.location,
                              multiline: true,
                            ),
                            SizedBox(height: 8.h),

                            _DetailRow(
                              icon: Icons.access_time,
                              label: 'Schedule',
                              value:
                              '${job.date}${job.time != null ? ' at ${job.time}' : ''}',
                            ),
                            SizedBox(height: 8.h),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  size: 16.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payment',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: job.payment,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                const Color(0xFF111827),
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              '   Bonus: ${job.bonus.isNotEmpty ? job.bonus : '\$0.00'}',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                const Color(0xFF2563EB),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                  backgroundColor:
                                  const Color(0xFFF3F4F6),
                                  side: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999.r),
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: open in maps
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.h,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.telegram_outlined,
                                        size: 18.sp,
                                        color: const Color(0xFF4B5563),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'Open in Maps',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF111827),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),

              // ---------------- Bottom buttons ----------------
              Container(
                color: const Color(0xFFF4F4F6),
                padding:
                EdgeInsets.symmetric(vertical: 20.w, horizontal: 30.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: widget.onDecline,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: widget.onAccept,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Text(
                            'Accept Work Order',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          color: const Color(0xFF6B7280),
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
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF111827),
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
