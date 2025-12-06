

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../internal_technician/widget/jobDetails.dart';
import '../../internal_technician/widget/viewJobDetails.dart';

import 'package:easy_localization/easy_localization.dart';

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
///  Job Models
/// ------------------------------------------------------
enum JobStatus { incoming, accepted, inProgress, completed }

class Job {
  final int id;
  final String title;
  final String customer;
  final String customerPhone;
  final String address;
  final String dateLabel; // "Today", "Tomorrow", "Nov 2, 2025"
  final String timeLabel; // "2:00 PM"
  final double payment;
  final double commission; // numeric – we’ll format as $
  final String description;
  final String category;
  final JobStatus status;

  const Job({
    required this.id,
    required this.title,
    required this.customer,
    required this.customerPhone,
    required this.address,
    required this.dateLabel,
    required this.timeLabel,
    required this.payment,
    required this.commission,
    required this.description,
    required this.category,
    required this.status,
  });

  Job copyWith({
    JobStatus? status,
  }) {
    return Job(
      id: id,
      title: title,
      customer: customer,
      customerPhone: customerPhone,
      address: address,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      payment: payment,
      commission: commission,
      description: description,
      category: category,
      status: status ?? this.status,
    );
  }
}

/// ------------------------------------------------------
///  Riverpod – Jobs State
/// ------------------------------------------------------
class JobsNotifier extends StateNotifier<List<Job>> {
  JobsNotifier()
      : super(const [
    Job(
      id: 1,
      title: 'HVAC Maintenance',
      customer: 'Michael Johnson',
      customerPhone: '+1 234 567 8900',
      address: '123 Main St, Apt 4B',
      dateLabel: 'Today',
      timeLabel: '2:00 PM',
      payment: 120,
      commission: 18,
      description:
      'Regular maintenance check for air conditioning unit',
      category: 'HVAC Services',
      status: JobStatus.inProgress,
    ),
    Job(
      id: 2,
      title: 'Electrical Repair',
      customer: 'Sarah Williams',
      customerPhone: '+1 234 567 8901',
      address: '456 Oak Ave, Suite 12',
      dateLabel: 'Today',
      timeLabel: '4:00 PM',
      payment: 85,
      commission: 12.75,
      description: 'Circuit breaker replacement needed',
      category: 'Electrical Services',
      status: JobStatus.accepted,
    ),
    Job(
      id: 3,
      title: 'Plumbing Fix',
      customer: 'David Brown',
      customerPhone: '+1 234 567 8902',
      address: '789 Pine Street',
      dateLabel: 'Tomorrow',
      timeLabel: '10:00 AM',
      payment: 75,
      commission: 11.25,
      description: 'Leaky faucet repair in kitchen',
      category: 'Plumbing Services',
      status: JobStatus.accepted,
    ),
  ]);

  void updateJob(Job updated) {
    state = [
      for (final job in state) if (job.id == updated.id) updated else job,
    ];
  }
}

// completed jobs আলাদা লিস্ট
final completedJobsProvider = Provider<List<Job>>((ref) {
  return const [
    Job(
      id: 4,
      title: 'HVAC Installation',
      customer: 'Emily Davis',
      customerPhone: '+1 234 567 8903',
      address: '321 Elm Road',
      dateLabel: 'Nov 3, 2025',
      timeLabel: '9:00 AM',
      payment: 250,
      commission: 37.50,
      description: 'New AC unit installation',
      category: 'HVAC Services',
      status: JobStatus.completed,
    ),
    Job(
      id: 5,
      title: 'Electrical Inspection',
      customer: 'Robert Miller',
      customerPhone: '+1 234 567 8904',
      address: '654 Maple Drive',
      dateLabel: 'Nov 2, 2025',
      timeLabel: '1:00 PM',
      payment: 100,
      commission: 15,
      description: 'Safety inspection of electrical panel',
      category: 'Electrical Services',
      status: JobStatus.completed,
    ),
    Job(
      id: 6,
      title: 'Plumbing Maintenance',
      customer: 'Jennifer Wilson',
      customerPhone: '+1 234 567 8905',
      address: '987 Cedar Lane',
      dateLabel: 'Nov 1, 2025',
      timeLabel: '11:00 AM',
      payment: 90,
      commission: 13.50,
      description: 'Drain cleaning and inspection',
      category: 'Plumbing Services',
      status: JobStatus.completed,
    ),
  ];
});

final jobsProvider =
StateNotifierProvider<JobsNotifier, List<Job>>((ref) => JobsNotifier());

// tab – active / completed
enum JobsTab { active, completed }

final jobsTabProvider = StateProvider<JobsTab>((ref) => JobsTab.active);

/// ------------------------------------------------------
///  Freelancers Home Screen (ConsumerWidget)
/// ------------------------------------------------------
class FreelancerHomeScreen extends ConsumerWidget {
  const FreelancerHomeScreen({super.key});

  static const routeName = '/freelancer-home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider);
    final completedJobs = ref.watch(completedJobsProvider);
    final tab = ref.watch(jobsTabProvider);

    final inProgressJobs =
    jobs.where((j) => j.status == JobStatus.inProgress).toList();
    final acceptedJobs =
    jobs.where((j) => j.status == JobStatus.accepted).toList();

    final completedCount = 28; // as per design text
    final activeCount = inProgressJobs.length + acceptedJobs.length;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(
                monthlyCommission: 5066,
                completedJobsThisMonth: completedCount,
                userName: 'freelancer_tech'.tr(),
              ),
              SizedBox(height: 12.h),
              _StatsRow(
                active: acceptedJobs.length,
                inProgress: inProgressJobs.length,
                completedThisMonth: completedCount,
              ),
              SizedBox(height: 16.h),
              _TabSwitcher(activeCount: activeCount, completedCount: completedCount),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: tab == JobsTab.active
                    ? _ActiveJobsSection(
                  inProgressJobs: inProgressJobs,
                  acceptedJobs: acceptedJobs,
                )
                    : _CompletedJobsSection(completedJobs: completedJobs),
              ),
              SizedBox(height: 16.h),
              const _TopPerformerCard(),
            ],
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
      padding:
      EdgeInsets.only(left: 16.w, right: 16.w, top: 18.h, bottom: 18.h),
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
                    // width: 36,
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
                        'Monthly Commission (15%)',
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
                      'November 2025',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.brown.shade900.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '$completedJobsThisMonth jobs completed',
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
          )
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
              label: 'Ready to start',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              icon: Icons.access_time,
              iconBg: const Color(0xFFE5F1FF),
              iconColor: kPrimaryBlue,
              value: inProgress.toString(),
              label: 'Active now',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              iconBg: const Color(0xFFE7F9ED),
              iconColor: const Color(0xFF16A34A),
              value: completedThisMonth.toString(),
              label: 'This month',
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
          )
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
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: kTextMuted),
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

  const _TabSwitcher({
    required this.activeCount,
    required this.completedCount,
  });

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
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabChip(
                label: 'Active ($activeCount)',
                selected: tab == JobsTab.active,
                onTap: () => ref.read(jobsTabProvider.notifier).state =
                    JobsTab.active,
              ),
            ),
            Expanded(
              child: _TabChip(
                label: 'Completed ($completedCount)',
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
///  Active Jobs Section
/// ------------------------------------------------------
class _ActiveJobsSection extends StatelessWidget {
  final List<Job> inProgressJobs;
  final List<Job> acceptedJobs;

  const _ActiveJobsSection({
    required this.inProgressJobs,
    required this.acceptedJobs,
  });

  @override
  Widget build(BuildContext context) {
    if (inProgressJobs.isEmpty && acceptedJobs.isEmpty) {
      return Center(
        child: Text(
          'no_completed_jobs_yet'.tr(),
          style: TextStyle(fontSize: 13.sp, color: kTextMuted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (inProgressJobs.isNotEmpty) ...[
          _SectionTitle(
            icon: Icons.access_time,
            label: 'in_progress'.tr(),
          ),
          SizedBox(height: 6.h),
          for (final job in inProgressJobs)
            _JobCard(job: job, isInProgressCard: true),
          SizedBox(height: 16.h),
        ],
        if (acceptedJobs.isNotEmpty) ...[
          _SectionTitle(
            icon: Icons.work_outline,
            label: 'ready_start'.tr(),
          ),
          SizedBox(height: 6.h),
          for (final job in acceptedJobs)
            _JobCard(job: job, isInProgressCard: false),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: kTextMuted),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: kTextMuted,
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------
///  Single Job Card
/// ------------------------------------------------------
class _JobCard extends ConsumerWidget {
  final Job job;
  final bool isInProgressCard;

  const _JobCard({
    required this.job,
    required this.isInProgressCard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = isInProgressCard ? kInProgressBg : kCard;
    final borderColor =
    isInProgressCard ? kPrimaryBlue.withOpacity(0.3) : Colors.transparent;
    final isInProgress = job.status == JobStatus.inProgress;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor, width: isInProgressCard ? 1.5 : 0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title & payment
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
                        color: kTextMain,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.category,
                      style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${job.payment.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: kTextMain,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Earn \$${job.commission.toStringAsFixed(2)}',
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

          // address & time
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14.sp, color: kTextMuted),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  job.address,
                  style: TextStyle(fontSize: 12.sp, color: kTextMain),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14.sp, color: kTextMuted),
              SizedBox(width: 4.w),
              Text(
                '${job.dateLabel} at ${job.timeLabel}',
                style: TextStyle(fontSize: 12.sp, color: kTextMain),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusBadge(
                label: isInProgressCard ? 'In Progress' : 'Ready to Start',
                color: isInProgressCard
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE6A400),
                bgColor: isInProgressCard
                    ? const Color(0xFFE5F1FF)
                    : const Color(0xFFFFF4D7),
              ),
              SizedBox(
                height: 32.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isInProgressCard
                        ? const Color(0xFF2563EB) // 🔵 In Progress solid bg
                        : kPrimaryYellow,          // 🟡 Ready to Start solid bg
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (isInProgress) {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => Jobdetails(),
                        );
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => Viewjobdetails(),
                        );
                      }
                    },


                    style: ElevatedButton.styleFrom(
                      // button ke transparent rakhlam, background niche DecoratedBox theke asche
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: Text(
                      isInProgressCard ? 'Continue' : 'View Details',
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
          )

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
  final List<Job> completedJobs;

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
                )
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
                    const Icon(Icons.check_circle,
                        color: Color(0xFF16A34A)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Customer: ${job.customer}',
                  style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14.sp, color: kTextMuted),
                    SizedBox(width: 4.w),
                    Text(
                      job.dateLabel,
                      style: TextStyle(fontSize: 12.sp, color: kTextMain),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14.sp, color: kTextMuted),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        job.address,
                        style:
                        TextStyle(fontSize: 12.sp, color: kTextMain),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Divider(color:kTextMuted,height: 1.h,),
                SizedBox(height: 8.h,),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'commission_earned'.tr(),
                          style: TextStyle(
                              fontSize: 11.sp, color: kTextMuted),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '\$${job.commission.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F9ED),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Paid',
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
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
            )
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
              child: const Icon(Icons.workspace_premium,
                  color: Color(0xFF7C3AED)),
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
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: kTextMuted,
                    ),
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
