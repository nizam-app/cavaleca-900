// freelarcer_job_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/internal_technician/screen/job/logic/internal_job_logic.dart';
import 'package:workpleis/features/internal_technician/screen/job/model/internal_job_model.dart';
import 'package:workpleis/features/internal_technician/widget/gPSCheckInPopup.dart';
import 'package:workpleis/features/internal_technician/widget/jobDetails.dart';
import 'package:workpleis/features/internal_technician/widget/viewJobDetails.dart';

import 'package:easy_localization/easy_localization.dart';

///  Colors
const Color kJobsBg = Color(0xFFF4F4F4);
const Color kJobsCard = Colors.white;
const Color kJobsTextMain = Color(0xFF1F2933);
const Color kJobsTextMuted = Color(0xFF9CA3AF);
const Color kJobsHeaderYellow = Color(0xFFFFB111);
const Color kJobsHeaderYellowDark = Color(0xFFE69F0F);
const Color kJobsPrimaryYellow = Color(0xFFFFB111);
const Color kJobsPrimaryBlue = Color(0xFF2563EB);
const Color kJobsSuccess = Color(0xFF16A34A);

/// ------------------------------------------------------
///  Tabs
/// ------------------------------------------------------
enum FreelancerJobsTab { incoming, active, done }

final freelancerJobsTabProvider = StateProvider<FreelancerJobsTab>(
  (ref) => FreelancerJobsTab.incoming,
);

/// ------------------------------------------------------
///  Screen
/// ------------------------------------------------------
class FreelarcerJobScreen extends ConsumerStatefulWidget {
  const FreelarcerJobScreen({super.key});

  static const routeName = '/freelarcerJobScreen';

  @override
  ConsumerState<FreelarcerJobScreen> createState() =>
      _FreelarcerJobScreenState();
}

class _FreelarcerJobScreenState extends ConsumerState<FreelarcerJobScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  List<InternalJob> _incomingJobs = [];
  List<InternalJob> _activeJobs = [];
  List<InternalJob> _completedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadAllJobs();
  }

  Future<void> _loadAllJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final incoming = await TechnicianJobsApi.fetchJobs('incoming');
      final active = await TechnicianJobsApi.fetchJobs('active');
      final done = await TechnicianJobsApi.fetchJobs('done');

      setState(() {
        _incomingJobs = incoming;
        _activeJobs = active;
        _completedJobs = done;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAcceptJob(InternalJob job) async {
    try {
      final updated = await TechnicianJobsApi.respondToWorkOrder(
        woId: job.id,
        action: 'ACCEPT',
      );

      setState(() {
        _incomingJobs = _incomingJobs.where((j) => j.id != job.id).toList();
        _activeJobs = [..._activeJobs, updated];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job accepted and moved to Active.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to accept job: $e')));
      }
    }
  }

  Future<void> _handleStartJob(InternalJob job) async {
    // GPS popup dekhao + start API
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const Gpscheckinpopup(),
    );

    final lat = job.latitude ?? 0;
    final lng = job.longitude ?? 0;

    try {
      final updated = await TechnicianJobsApi.startWorkOrder(
        woId: job.id,
        lat: lat,
        lng: lng,
      );

      setState(() {
        _activeJobs = _activeJobs
            .map((j) => j.id == updated.id ? updated : j)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start job: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(freelancerJobsTabProvider);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kJobsBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: kJobsBg,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    // active tab → jobs already accepted
    // available tab → incoming offers
    // completed tab → done
    return Scaffold(
      backgroundColor: kJobsBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllJobs,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _JobsHeader(),
                SizedBox(height: 16.h),
                _JobsTabs(
                  currentTab: tab,
                  onTabChanged: (newTab) =>
                      ref.read(freelancerJobsTabProvider.notifier).state =
                          newTab,
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Builder(
                    builder: (_) {
                      switch (tab) {
                        case FreelancerJobsTab.incoming:
                          return _ActiveJobsList(
                            jobs: _activeJobs,
                            onStartJob: _handleStartJob,
                          );
                        case FreelancerJobsTab.active:
                          return _AvailableJobsList(
                            jobs: _incomingJobs,
                            onAcceptJob: _handleAcceptJob,
                          );
                        case FreelancerJobsTab.done:
                          return _CompletedJobsList(jobs: _completedJobs);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Header
/// ------------------------------------------------------
class _JobsHeader extends StatelessWidget {
  const _JobsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 30.h,
        bottom: 14.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kJobsHeaderYellow, kJobsHeaderYellowDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'my_jobs'.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'manage_assignments'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black.withOpacity(0.92),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
///  Tabs
/// ------------------------------------------------------
class _JobsTabs extends StatelessWidget {
  final FreelancerJobsTab currentTab;
  final ValueChanged<FreelancerJobsTab> onTabChanged;

  const _JobsTabs({required this.currentTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: kJobsCard,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabChip(
                label: 'active'.tr(),
                selected: currentTab == FreelancerJobsTab.active,
                onTap: () => onTabChanged(FreelancerJobsTab.active),
              ),
            ),
            Expanded(
              child: _TabChip(
                label: 'available'.tr(),
                selected: currentTab == FreelancerJobsTab.incoming,
                onTap: () => onTabChanged(FreelancerJobsTab.incoming),
              ),
            ),
            Expanded(
              child: _TabChip(
                label: 'completed'.tr(),
                selected: currentTab == FreelancerJobsTab.done,
                onTap: () => onTabChanged(FreelancerJobsTab.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? kJobsHeaderYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: kJobsTextMain,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Active Jobs Tab (accepted + in-progress)
/// ------------------------------------------------------
class _ActiveJobsList extends StatelessWidget {
  final List<InternalJob> jobs;
  final Future<void> Function(InternalJob job) onStartJob;

  const _ActiveJobsList({required this.jobs, required this.onStartJob});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'no_active_jobs_right_now'.tr(),
            style: TextStyle(fontSize: 13.sp, color: kJobsTextMuted),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final job in jobs) ...[
          _ActiveJobCard(job: job, onStartJob: onStartJob),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final InternalJob job;
  final Future<void> Function(InternalJob job) onStartJob;

  const _ActiveJobCard({required this.job, required this.onStartJob});

  @override
  Widget build(BuildContext context) {
    final isInProgress = job.status == JobStatus.inProgress;
    final address = job.address ?? job.location;
    final dateLabel = '${job.date}${job.time != null ? ' at ${job.time}' : ''}';

    return Container(
      decoration: BoxDecoration(
        color: kJobsCard,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title + status badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: kJobsTextMain,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Customer: ${job.customer}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kJobsTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isInProgress
                        ? const Color(0xFFE5F1FF)
                        : const Color(0xFFFFF4D7),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Text(
                    isInProgress ? 'In Progress' : 'Scheduled',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: isInProgress
                          ? kJobsPrimaryBlue
                          : const Color(0xFFE6A400),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // location + time
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14.sp,
                  color: kJobsTextMuted,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 14.sp, color: kJobsTextMuted),
                SizedBox(width: 4.w),
                Text(
                  dateLabel,
                  style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(color: kJobsTextMuted, height: 1.h),
            SizedBox(height: 6.h),

            // payment + earning
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total_payment'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kJobsTextMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.payment,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: kJobsTextMain,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'your_earning'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kJobsTextMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.bonus,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: kJobsSuccess,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // bottom button
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                onPressed: () async {
                  if (isInProgress) {
                    await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => Jobdetails(job: job),
                    );
                  } else {
                    await onStartJob(job);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kJobsPrimaryYellow,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  isInProgress ? 'Continue Job' : 'Start Job',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Available Jobs Tab (incoming offers)
/// ------------------------------------------------------
class _AvailableJobsList extends StatelessWidget {
  final List<InternalJob> jobs;
  final Future<void> Function(InternalJob job) onAcceptJob;

  const _AvailableJobsList({required this.jobs, required this.onAcceptJob});

  Color _priorityDotColor(JobPriority? priority) {
    switch (priority) {
      case JobPriority.high:
        return Colors.red;
      case JobPriority.medium:
        return Colors.orange;
      case JobPriority.low:
        return Colors.green;
      default:
        return kJobsTextMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'no_available_jobs'.tr(),
            style: TextStyle(fontSize: 13.sp, color: kJobsTextMuted),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final job in jobs) ...[
          Container(
            decoration: BoxDecoration(
              color: kJobsCard,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + urgency + payment
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: kJobsTextMain,
                                ),
                              ),
                            ),
                            Container(
                              height: 8.w,
                              width: 8.w,
                              decoration: BoxDecoration(
                                color: _priorityDotColor(job.priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            job.payment,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: kJobsTextMain,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Earn ${job.bonus}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kJobsSuccess,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // location + date
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: kJobsTextMuted,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          job.address ?? job.location,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: kJobsTextMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: kJobsTextMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        job.date,
                        style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => Viewjobdetails(
                                job: job,
                                bonusRate: 5.0,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          child: Text(
                            'details'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: kJobsTextMain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => onAcceptJob(job),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kJobsPrimaryYellow,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          child: Text(
                            'accept_job'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

/// ------------------------------------------------------
///  Completed Jobs Tab
/// ------------------------------------------------------
class _CompletedJobsList extends StatelessWidget {
  final List<InternalJob> jobs;

  const _CompletedJobsList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'no_completed_jobs_yet'.tr(),
            style: TextStyle(fontSize: 13.sp, color: kJobsTextMuted),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final job in jobs) ...[
          Container(
            decoration: BoxDecoration(
              color: kJobsCard,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + check icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: kJobsTextMain,
                          ),
                        ),
                      ),
                      const Icon(Icons.check_circle, color: kJobsSuccess),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Customer: ${job.customer}',
                    style: TextStyle(fontSize: 12.sp, color: kJobsTextMuted),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: kJobsTextMuted,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          job.address ?? job.location,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: kJobsTextMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: kJobsTextMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        job.date,
                        style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'earned'.tr(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kJobsTextMuted,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            job.bonus,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: kJobsSuccess,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}
