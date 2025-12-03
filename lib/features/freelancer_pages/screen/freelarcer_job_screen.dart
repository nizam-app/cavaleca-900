import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../internal_technician/widget/jobDetails.dart';
import '../../internal_technician/widget/job_detail-overlay.dart';
import '../../internal_technician/widget/viewJobDetails.dart';
import '../widgets/freelancerJobDetails.dart';

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
///  Models
/// ------------------------------------------------------
enum ActiveJobStatus { inProgress, scheduled }

class ActiveJob {
  final int id;
  final String title;
  final String customer;
  final String location;
  final String dateLabel; // "Today, 2:00 PM"
  final double payment;
  final double earning;
  final ActiveJobStatus status;

  const ActiveJob({
    required this.id,
    required this.title,
    required this.customer,
    required this.location,
    required this.dateLabel,
    required this.payment,
    required this.earning,
    required this.status,
  });
}

enum JobUrgency { high, medium, low }

class AvailableJob {
  final int id;
  final String srId;
  final String title;
  final String category;
  final String description;
  final String locationShort;
  final String address;
  final String customerName;
  final String customerPhone;
  final int customerRating;
  final String time;
  final String date;
  final String distance;
  final double payment;
  final double earning;
  final JobUrgency urgency;

  const AvailableJob({
    required this.id,
    required this.srId,
    required this.title,
    required this.category,
    required this.description,
    required this.locationShort,
    required this.address,
    required this.customerName,
    required this.customerPhone,
    required this.customerRating,
    required this.time,
    required this.date,
    required this.distance,
    required this.payment,
    required this.earning,
    required this.urgency,
  });
}

class CompletedJob {
  final int id;
  final String title;
  final String customer;
  final String location;
  final String dateLabel;
  final double payment;
  final double earning;

  const CompletedJob({
    required this.id,
    required this.title,
    required this.customer,
    required this.location,
    required this.dateLabel,
    required this.payment,
    required this.earning,
  });
}

/// ------------------------------------------------------
///  Riverpod Providers
/// ------------------------------------------------------
enum FreelancerJobsTab { active, available, completed }

final freelancerJobsTabProvider =
StateProvider<FreelancerJobsTab>((ref) => FreelancerJobsTab.active);

final activeJobsProvider = StateProvider<List<ActiveJob>>((ref) {
  return const [
    ActiveJob(
      id: 1,
      title: 'HVAC Maintenance',
      customer: 'Michael Johnson',
      location: '123 Main St, Apt 4B',
      dateLabel: 'Today, 2:00 PM',
      payment: 120,
      earning: 95,
      status: ActiveJobStatus.inProgress,
    ),
    ActiveJob(
      id: 2,
      title: 'Electrical Inspection',
      customer: 'Sarah Williams',
      location: '456 Oak Avenue',
      dateLabel: 'Today, 4:30 PM',
      payment: 85,
      earning: 65,
      status: ActiveJobStatus.scheduled,
    ),
  ];
});

final availableJobsProvider = StateProvider<List<AvailableJob>>((ref) {
  return const [
    AvailableJob(
      id: 6,
      srId: 'SR-2025-1106',
      title: 'Electrical Repair',
      category: 'Electrical',
      description:
      'Urgent electrical outlet repair needed. Multiple outlets not working in living room and bedroom. May need circuit breaker inspection.',
      locationShort: '456 Oak Avenue',
      address: '456 Oak Avenue, Tevragh Zeina, Nouakchott',
      customerName: 'Fatima Hassan',
      customerPhone: '+222 45 23 45 67',
      customerRating: 5,
      time: '3:00 PM',
      date: 'Nov 5, 2025',
      distance: '2.3 km',
      payment: 85,
      earning: 65,
      urgency: JobUrgency.high,
    ),
    AvailableJob(
      id: 7,
      srId: 'SR-2025-1107',
      title: 'HVAC Inspection',
      category: 'HVAC',
      description:
      'Annual HVAC system inspection and maintenance. Check filters, coolant levels, and overall system performance.',
      locationShort: '789 Pine Street',
      address: '789 Pine Street, Ksar District, Nouakchott',
      customerName: 'Omar Abdullah',
      customerPhone: '+222 45 34 56 78',
      customerRating: 4,
      time: '10:00 AM',
      date: 'Nov 6, 2025',
      distance: '4.1 km',
      payment: 120,
      earning: 95,
      urgency: JobUrgency.medium,
    ),
    AvailableJob(
      id: 8,
      srId: 'SR-2025-1108',
      title: 'Plumbing Fix',
      category: 'Plumbing',
      description:
      'Minor plumbing leak under kitchen sink. Need quick repair to prevent water damage.',
      locationShort: '321 Elm Road',
      address: '321 Elm Road, Arafat District, Nouakchott',
      customerName: 'Aminata Diallo',
      customerPhone: '+222 45 45 67 89',
      customerRating: 5,
      time: '5:00 PM',
      date: 'Nov 5, 2025',
      distance: '1.8 km',
      payment: 75,
      earning: 55,
      urgency: JobUrgency.low,
    ),
  ];
});

final completedJobsProvider = StateProvider<List<CompletedJob>>((ref) {
  return const [
    CompletedJob(
      id: 3,
      title: 'Plumbing Repair',
      customer: 'Robert Brown',
      location: '789 Pine Street',
      dateLabel: 'Nov 3, 2025',
      payment: 95,
      earning: 75,
    ),
    CompletedJob(
      id: 4,
      title: 'HVAC Installation',
      customer: 'Emily Davis',
      location: '321 Elm Road',
      dateLabel: 'Nov 2, 2025',
      payment: 250,
      earning: 200,
    ),
    CompletedJob(
      id: 5,
      title: 'Electrical Repair',
      customer: 'James Wilson',
      location: '654 Maple Drive',
      dateLabel: 'Nov 1, 2025',
      payment: 75,
      earning: 55,
    ),
  ];
});

/// ------------------------------------------------------
///  Screen
/// ------------------------------------------------------
class FreelarcerJobScreen extends ConsumerWidget {
  const FreelarcerJobScreen({super.key});

  static const routeName = '/freelarcerJobScreen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(freelancerJobsTabProvider);
    final activeJobs = ref.watch(activeJobsProvider);
    final availableJobs = ref.watch(availableJobsProvider);
    final completedJobs = ref.watch(completedJobsProvider);

    return Scaffold(
      backgroundColor: kJobsBg,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      case FreelancerJobsTab.active:
                        return _ActiveJobsList(jobs: activeJobs);
                      case FreelancerJobsTab.available:
                        return _AvailableJobsList(jobs: availableJobs);
                      case FreelancerJobsTab.completed:
                        return _CompletedJobsList(jobs: completedJobs);
                    }
                  },
                ),
              ),
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
class _JobsHeader extends StatelessWidget {
  const _JobsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      width: double.infinity,
      padding:
      EdgeInsets.only(left: 16.w, right: 16.w, top: 30.h, bottom: 14.h),
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
            'My Jobs',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Manage your assignments',
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

  const _JobsTabs({
    required this.currentTab,
    required this.onTabChanged,
  });

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
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabChip(
                label: 'Active',
                selected: currentTab == FreelancerJobsTab.active,
                onTap: () => onTabChanged(FreelancerJobsTab.active),
              ),
            ),
            Expanded(
              child: _TabChip(
                label: 'Available',
                selected: currentTab == FreelancerJobsTab.available,
                onTap: () => onTabChanged(FreelancerJobsTab.available),
              ),
            ),
            Expanded(
              child: _TabChip(
                label: 'Completed',
                selected: currentTab == FreelancerJobsTab.completed,
                onTap: () => onTabChanged(FreelancerJobsTab.completed),
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
              color: selected ? kJobsTextMain: kJobsTextMain,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Active Jobs Tab
/// ------------------------------------------------------
class _ActiveJobsList extends StatelessWidget {
  final List<ActiveJob> jobs;

  const _ActiveJobsList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'No active jobs right now',
            style: TextStyle(fontSize: 13.sp, color: kJobsTextMuted),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final job in jobs) ...[
          _ActiveJobCard(job: job),
          SizedBox(height: 12.h),
        ]
      ],
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final ActiveJob job;

  const _ActiveJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final isInProgress = job.status == ActiveJobStatus.inProgress;

    return Container(
      decoration: BoxDecoration(
        color: kJobsCard,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
                )
              ],
            ),
            SizedBox(height: 10.h),

            // location + time
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14.sp, color: kJobsTextMuted),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    job.location,
                    style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14.sp, color: kJobsTextMuted),
                SizedBox(width: 4.w),
                Text(
                  job.dateLabel,
                  style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(color:kJobsTextMuted , height: 1.h,),
            SizedBox(height: 6.h),
            // payment + earning
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Payment',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kJobsTextMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '\$${job.payment.toStringAsFixed(0)}',
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
                      'Your Earning',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kJobsTextMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '\$${job.earning.toStringAsFixed(0)}',
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
            )
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Available Jobs Tab
/// ------------------------------------------------------
class _AvailableJobsList extends ConsumerWidget {
  final List<AvailableJob> jobs;

  const _AvailableJobsList({required this.jobs});

  Color _urgencyDotColor(JobUrgency urgency) {
    switch (urgency) {
      case JobUrgency.high:
        return Colors.red;
      case JobUrgency.medium:
        return Colors.orange;
      case JobUrgency.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (jobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'No available jobs',
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
                )
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
                                color: _urgencyDotColor(job.urgency),
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
                            '\$${job.payment.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: kJobsTextMain,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Earn \$${job.earning.toStringAsFixed(0)}',
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
                      Icon(Icons.location_on_outlined,
                          size: 14.sp, color: kJobsTextMuted),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          job.locationShort,
                          style:
                          TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '• ${job.distance}',
                        style:
                        TextStyle(fontSize: 11.sp, color: kJobsTextMuted),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14.sp, color: kJobsTextMuted),
                      SizedBox(width: 4.w),
                      Text(
                        job.date,
                        style:
                        TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          // onPressed: () {
                          //
                          //   // Details → route to job detail (modal/screen)
                          //   context.pushNamed(
                          //     'freelancer-available-detail',
                          //     pathParameters: {'id': job.id.toString()},
                          //     extra: job,
                          //   );
                          // },

                            onPressed: () {

                          },
                 style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.grey, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          child: Text(
                            'Details',
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
                          onPressed: () {
                            // Accept Job:
                            // 1) move from available -> active (scheduled)
                            // 2) navigate to details/workflow screen

                            final availableCtrl =
                            ref.read(availableJobsProvider.notifier);
                            final activeCtrl =
                            ref.read(activeJobsProvider.notifier);

                            // remove from available list
                            final currentAvailable = [...availableCtrl.state];
                            final idx = currentAvailable
                                .indexWhere((e) => e.id == job.id);
                            if (idx != -1) {
                              currentAvailable.removeAt(idx);
                              availableCtrl.state = currentAvailable;
                            }

                            // add to active list
                            final newActive = [
                              ...activeCtrl.state,
                              ActiveJob(
                                id: job.id,
                                title: job.title,
                                customer: job.customerName,
                                location: job.locationShort,
                                dateLabel: '${job.date}, ${job.time}',
                                payment: job.payment,
                                earning: job.earning,
                                status: ActiveJobStatus.scheduled,
                              )
                            ];
                            activeCtrl.state = newActive;

                            // navigate
                            context.pushNamed(
                              'freelancer-available-detail',
                              pathParameters: {'id': job.id.toString()},
                              extra: job,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kJobsPrimaryYellow,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          child: Text(
                            'Accept Job',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ]
      ],
    );
  }
}

/// ------------------------------------------------------
///  Completed Jobs Tab
/// ------------------------------------------------------
class _CompletedJobsList extends StatelessWidget {
  final List<CompletedJob> jobs;

  const _CompletedJobsList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'No completed jobs yet',
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
                )
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
                    style:
                    TextStyle(fontSize: 12.sp, color: kJobsTextMuted),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14.sp, color: kJobsTextMuted),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          job.location,
                          style:
                          TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14.sp, color: kJobsTextMuted),
                      SizedBox(width: 4.w),
                      Text(
                        job.dateLabel,
                        style:
                        TextStyle(fontSize: 12.sp, color: kJobsTextMain),
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
                            'Earned',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kJobsTextMuted,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '\$${job.earning.toStringAsFixed(0)}',
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
        ]
      ],
    );
  }
}
