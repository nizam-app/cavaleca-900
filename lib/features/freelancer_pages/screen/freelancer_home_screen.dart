import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/internal_technician/screen/dashboard/logic/technician_dashboard_api.dart';
import 'package:workpleis/features/internal_technician/screen/dashboard/model/technician_dashboard_model.dart';
import 'package:workpleis/features/internal_technician/screen/job/logic/internal_job_logic.dart';
import 'package:workpleis/features/internal_technician/screen/job/model/internal_job_model.dart';
import 'package:workpleis/features/internal_technician/widget/gPSCheckInPopup.dart';
import 'package:workpleis/features/internal_technician/widget/jobDetails.dart';
import 'package:workpleis/features/internal_technician/widget/viewJobDetails.dart';

/// ------------------------------------------------------
///  Colors
/// ------------------------------------------------------
const Color kBg = Color(0xFFF4F4F4);
const Color kCard = Colors.white;
const Color kTextMain = Color(0xFF364153);
const Color kTextMuted = Color(0xFF9CA3AF);
const Color kPrimaryYellow = Color(0xFFE69F0F);
const Color kPrimaryYellowDark = Color(0xFFE69F0F);
const Color kPrimaryBlue = Color(0xFF2563EB);
const Color kInProgressBg = Color(0xFFE3F0FF);

/// ------------------------------------------------------
///  Tabs – active / completed
/// ------------------------------------------------------
enum JobsTab { active, completed }

final jobsTabProvider = StateProvider<JobsTab>((ref) => JobsTab.active);

/// ------------------------------------------------------
///  Freelancers Home Screen
/// ------------------------------------------------------
class FreelancerHomeScreen extends ConsumerStatefulWidget {
  const FreelancerHomeScreen({super.key});

  static const routeName = '/freelancer-home';

  @override
  ConsumerState<FreelancerHomeScreen> createState() =>
      _FreelancerHomeScreenState();
}

class _FreelancerHomeScreenState extends ConsumerState<FreelancerHomeScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  List<InternalJob> _incomingJobs = [];
  List<InternalJob> _activeJobs = [];
  List<InternalJob> _completedJobs = [];
  TechnicianDashboardModel? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  String _statusName(InternalJob j) => j.status.toString().split('.').last;

  bool _isInProgress(InternalJob j) => _statusName(j) == 'inProgress';

  bool _isReadyToStart(InternalJob j) {
    final s = _statusName(j);
    return s == 'assigned' || s == 'accepted';
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dashboardData = await TechnicianDashboardApi.fetchDashboard();

      final incoming = await TechnicianJobsApi.fetchJobs('incoming');
      final active = await TechnicianJobsApi.fetchJobs('active');
      final done = await TechnicianJobsApi.fetchJobs('done');

      setState(() {
        _dashboardData = dashboardData;
        _incomingJobs = incoming;
        _activeJobs = active;
        _completedJobs = done;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          SnackBar(content: Text('job_accepted_and_moved_to_active'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'failed_to_accept_job'.tr()}: $e')),
        );
      }
    }
  }

  Future<void> _handleStartJob(InternalJob job) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Gpscheckinpopup(
        jobAddress: job.address ?? job.location,
        onLocationVerified: (lat, lng) async {
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

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('job_started_successfully'.tr())),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${'failed_to_start_job'.tr()}: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(jobsTabProvider);

    // ✅ Active tab এ incoming + active একসাথে দেখাবে
    final incomingIds = _incomingJobs.map((j) => j.id).toSet();

    // merge & dedupe by id (incoming first; active overrides if same id)
    final Map<String, InternalJob> byId = {};
    for (final j in _incomingJobs) {
      byId[j.id.toString()] = j;
    }
    for (final j in _activeJobs) {
      byId[j.id.toString()] = j;
    }

    final homeActiveJobs = byId.values.toList();

    // incoming আগে দেখাতে sort
    homeActiveJobs.sort((a, b) {
      final aInc = incomingIds.contains(a.id);
      final bInc = incomingIds.contains(b.id);
      if (aInc == bInc) return 0;
      return aInc ? -1 : 1;
    });

    // counts
    final activeCount = homeActiveJobs.length;

    // Stats: activeJobs থেকেই logically count (incoming বাদ)
    final inProgressCount = _activeJobs.where(_isInProgress).length;
    final readyToStartCount = _activeJobs.where(_isReadyToStart).length;

    final completedCount =
        _dashboardData?.completedThisMonth ?? _completedJobs.length;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadJobs,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderSection(
                  monthlyCommission: (_dashboardData?.thisWeekEarned ?? 0)
                      .toDouble(),
                  completedJobsThisMonth: completedCount,
                  userName: 'freelancer_tech'.tr(),
                ),
                SizedBox(height: 12.h),
                _StatsRow(
                  active: readyToStartCount,
                  inProgress: inProgressCount,
                  completedThisMonth: completedCount,
                ),
                SizedBox(height: 16.h),
                _TabSwitcher(
                  activeCount: activeCount,
                  completedCount: completedCount,
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: tab == JobsTab.active
                      ? _ActiveJobsSection(
                          activeJobs: homeActiveJobs,
                          incomingIds: incomingIds,
                          onStartJob: _handleStartJob,
                          onAcceptJob: _handleAcceptJob,
                        )
                      : _CompletedJobsSection(completedJobs: _completedJobs),
                ),
                SizedBox(height: 16.h),
                const _TopPerformerCard(),
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
class _HeaderSection extends StatelessWidget {
  final String userName;
  final double monthlyCommission;
  final int completedJobsThisMonth;

  const _HeaderSection({
    required this.userName,
    required this.monthlyCommission,
    required this.completedJobsThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 18.h,
        bottom: 18.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryYellow, kPrimaryYellowDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $userName',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'ready_earn_today'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 44.w,
                width: 44.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logoicon.png',
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'monthly_commission_label'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '\$${monthlyCommission.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.brown.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'current_month_year'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.brown.shade900.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '$completedJobsThisMonth ${'jobs_completed'.tr()}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
///  Stats Row (3 cards)
/// ------------------------------------------------------
class _StatsRow extends StatelessWidget {
  final int active;
  final int inProgress;
  final int completedThisMonth;

  const _StatsRow({
    required this.active,
    required this.inProgress,
    required this.completedThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.work_outline,
              iconBg: const Color(0xFFFFF4D7),
              iconColor: const Color(0xFFE6A400),
              value: active.toString(),
              label: 'ready_to_start_label'.tr(),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              icon: Icons.access_time,
              iconBg: const Color(0xFFE5F1FF),
              iconColor: kPrimaryBlue,
              value: inProgress.toString(),
              label: 'active_now'.tr(),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              iconBg: const Color(0xFFE7F9ED),
              iconColor: const Color(0xFF16A34A),
              value: completedThisMonth.toString(),
              label: 'this_month'.tr(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32.w,
            width: 32.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: iconColor),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: kTextMain,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: kTextMuted),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
///  Tabs (Active / Completed)
/// ------------------------------------------------------
class _TabSwitcher extends ConsumerWidget {
  final int activeCount;
  final int completedCount;

  const _TabSwitcher({required this.activeCount, required this.completedCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(jobsTabProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(24.r),
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
                label: '${'active'.tr()} ($activeCount)',
                selected: tab == JobsTab.active,
                onTap: () =>
                    ref.read(jobsTabProvider.notifier).state = JobsTab.active,
              ),
            ),
            Expanded(
              child: _TabChip(
                label: '${'completed'.tr()} ($completedCount)',
                selected: tab == JobsTab.completed,
                onTap: () => ref.read(jobsTabProvider.notifier).state =
                    JobsTab.completed,
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
          color: selected ? kPrimaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : kTextMain,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Active Jobs Section (incoming + active merged)
/// ------------------------------------------------------
class _ActiveJobsSection extends StatelessWidget {
  final List<InternalJob> activeJobs;
  final Set<dynamic> incomingIds;
  final Future<void> Function(InternalJob job)? onStartJob;
  final Future<void> Function(InternalJob job)? onAcceptJob;

  const _ActiveJobsSection({
    required this.activeJobs,
    required this.incomingIds,
    this.onStartJob,
    this.onAcceptJob,
  });

  @override
  Widget build(BuildContext context) {
    if (activeJobs.isEmpty) {
      return Center(
        child: Text(
          'no_active_jobs_yet'.tr(),
          style: TextStyle(fontSize: 13.sp, color: kTextMuted),
        ),
      );
    }

    return Column(
      children: [
        for (final job in activeJobs)
          _JobCard(
            job: job,
            isIncomingCard: incomingIds.contains(job.id),
            onStartJob: onStartJob,
            onAcceptJob: onAcceptJob,
          ),
      ],
    );
  }
}

/// ------------------------------------------------------
///  Single Job Card
///  - incoming: Details + Accept
///  - active: Start/Continue/View
/// ------------------------------------------------------
class _JobCard extends ConsumerWidget {
  final InternalJob job;
  final bool isIncomingCard;
  final Future<void> Function(InternalJob job)? onStartJob;
  final Future<void> Function(InternalJob job)? onAcceptJob;

  const _JobCard({
    required this.job,
    required this.isIncomingCard,
    this.onStartJob,
    this.onAcceptJob,
  });

  String _statusName() => job.status.toString().split('.').last;

  bool _isInProgress() => _statusName() == 'inProgress';

  bool _isReadyToStart() {
    final s = _statusName();
    return s == 'assigned' || s == 'accepted';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInProgress = _isInProgress();

    final bgColor = isInProgress ? kInProgressBg : kCard;
    final borderColor = isInProgress
        ? kPrimaryBlue.withOpacity(0.3)
        : Colors.transparent;

    final address = job.address ?? job.location;
    final dateLabel = '${job.date}${job.time != null ? ' at ${job.time}' : ''}';

    Future<void> openDetails() async {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Viewjobdetails(job: job, bonusRate: 5.0),
      );
    }

    Future<void> doPrimaryAction() async {
      if (isIncomingCard) {
        if (onAcceptJob != null) await onAcceptJob!(job);
        return;
      }

      if (isInProgress) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => Jobdetails(job: job),
        );
        return;
      }

      if (_isReadyToStart() && onStartJob != null) {
        await onStartJob!(job);
        return;
      }

      await openDetails();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor, width: isInProgress ? 1.5 : 0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title & payment
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: kTextMain,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    job.payment,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: kTextMain,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${'earn_label'.tr()} ${job.bonus}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // address
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14.sp, color: kTextMuted),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 12.sp, color: kTextMain),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // date/time
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14.sp,
                color: kTextMuted,
              ),
              SizedBox(width: 4.w),
              Text(
                dateLabel,
                style: TextStyle(fontSize: 12.sp, color: kTextMain),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // bottom area
          if (isIncomingCard) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: openDetails,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: Text(
                      'details'.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: kTextMain,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: doPrimaryAction, // accept
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryYellow,
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
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusBadge(
                  label: isInProgress
                      ? 'in_progress'.tr()
                      : (_isReadyToStart()
                            ? 'ready_to_start'.tr()
                            : 'view_details'.tr()),
                  color: isInProgress
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE6A400),
                  bgColor: isInProgress
                      ? const Color(0xFFE5F1FF)
                      : const Color(0xFFFFF4D7),
                ),
                SizedBox(
                  height: 32.h,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isInProgress
                          ? const Color(0xFF2563EB)
                          : kPrimaryYellow,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: ElevatedButton(
                      onPressed: doPrimaryAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      child: Text(
                        isInProgress
                            ? 'continue'.tr()
                            : (_isReadyToStart()
                                  ? 'start_job_short'.tr()
                                  : 'view_details'.tr()),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Completed Jobs Section
/// ------------------------------------------------------
class _CompletedJobsSection extends StatelessWidget {
  final List<InternalJob> completedJobs;

  const _CompletedJobsSection({required this.completedJobs});

  @override
  Widget build(BuildContext context) {
    if (completedJobs.isEmpty) {
      return Center(
        child: Text(
          'no_completed_jobs_yet'.tr(),
          style: TextStyle(fontSize: 14.sp, color: kTextMuted),
        ),
      );
    }

    return Column(
      children: [
        for (final job in completedJobs)
          Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: kTextMain,
                        ),
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${'customer_label'.tr()} ${job.customer}',
                  style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: kTextMuted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      job.date,
                      style: TextStyle(fontSize: 12.sp, color: kTextMain),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.sp,
                      color: kTextMuted,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        job.address ?? job.location,
                        style: TextStyle(fontSize: 12.sp, color: kTextMain),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Divider(color: kTextMuted, height: 1.h),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'earned'.tr(),
                          style: TextStyle(fontSize: 11.sp, color: kTextMuted),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          job.bonus,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F9ED),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'paid'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF16A34A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// ------------------------------------------------------
///  Top Performer Card
/// ------------------------------------------------------
class _TopPerformerCard extends StatelessWidget {
  const _TopPerformerCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF4EAFF), Color(0xFFFEE7F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 44.w,
              width: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE9D5FF),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Color(0xFF7C3AED),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'top_performer'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: kTextMain,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'keep_up_great_work'.tr(),
                    style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.trending_up, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }
}
