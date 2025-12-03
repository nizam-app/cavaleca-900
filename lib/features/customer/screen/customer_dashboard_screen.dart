import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/customer/widget/book_a_service.dart';
import 'package:workpleis/features/customer/widget/custom_booking_details.dart';
import 'package:workpleis/features/customer/widget/genarel_maintenance.dart';
import 'package:workpleis/features/customer/widget/repairs_&_fixes.dart';
import 'package:workpleis/features/customer/widget/service_details.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);
const Color kAccentYellow = Color(0xFFFFB111);
const Color kAccentYellowDark = Color(0xFFE69F0F);
const Color kPageBackground = Color(0xFFF4F4F4);

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({
    super.key,
    this.isGuest = false,
    this.userName,
    this.onViewAllPressed,
  });

  final bool isGuest;
  final String? userName;
  final VoidCallback? onViewAllPressed;
  static const String routeName = '/customer-dashboard';

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final ScrollController _categoryScrollController = ScrollController();

  // demo data – tumi backend data diye replace korte পারো
  final List<_ServiceCategory> _categories = const [
    _ServiceCategory(
      title: 'General',
      description: 'Regular maintenance and\nrepairs',
      serviceCount: 9,
      icon: Icons.build_rounded,
    ),
    _ServiceCategory(
      title: 'HVAC Services',
      description: 'Heating, cooling, and\nventilation',
      serviceCount: 6,
      icon: Icons.air,
    ),
    _ServiceCategory(
      title: 'Cleaning',
      description: 'Home & office cleaning\nsolutions',
      serviceCount: 8,
      icon: Icons.cleaning_services,
    ),
  ];

  final List<_ActiveJob> _activeJobs = const [
    _ActiveJob(
      title: 'AC Maintenance',
      category: 'HVAC Services',
      technician: 'John Smith',
      dateText: 'Today, 2:00 PM',
      status: _JobStatus.inProgress,
    ),
    _ActiveJob(
      title: 'Outlet Repair',
      category: 'Electrical Services',
      technician: 'Sarah Johnson',
      dateText: 'Tomorrow, 10:00 AM',
      status: _JobStatus.scheduled,
    ),
  ];

  final List<_RecentJob> _recentJobs = const [
    _RecentJob(
      title: 'Leak Repair',
      category: 'Plumbing Services',
      dateText: 'Nov 1, 2025',
    ),
    _RecentJob(
      title: 'Deep Cleaning',
      category: 'Cleaning Services',
      dateText: 'Oct 28, 2025',
    ),
    _RecentJob(
      title: 'Door Repair',
      category: 'General Maintenance',
      dateText: 'Oct 25, 2025',
    ),
  ];

  void _scrollCategories(bool forward) {
    if (!_categoryScrollController.hasClients) return;
    const double scrollAmount = 220;
    final double target =
        _categoryScrollController.offset +
        (forward ? scrollAmount : -scrollAmount);

    _categoryScrollController.animateTo(
      target.clamp(
        _categoryScrollController.position.minScrollExtent,
        _categoryScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  String get _displayName {
    if (widget.userName != null && widget.userName!.trim().isNotEmpty) {
      return widget.userName!;
    }
    return widget.isGuest ? 'Guest' : 'John Doe';
  }

  String get _initials {
    final name = _displayName.trim();
    if (name.isEmpty) return 'JD';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            SizedBox(height: 16.h),
            _buildCategoriesSection(),
            SizedBox(height: 24.h),
            if (!widget.isGuest) ...[
              _buildActiveRequestsSection(),
              SizedBox(height: 24.h),
              _buildRecentServicesSection(),
            ] else ...[
              _buildGuestNotice(),
            ],
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryRed, kPrimaryRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $_displayName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.isGuest
                          ? 'Booking as guest'
                          : 'Need a service today?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundColor: kAccentYellow,
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                showBookServiceDialog(
                  context,
                  onServiceSelected: (service) {
                    showServiceTypeDialog(
                      context,
                      title: 'General Maintenance',
                      stepText: 'Step 2 of 3 - Select service type',
                      options: [
                        ServiceTypeOption(
                          title: 'Repairs & Fixes',
                          subtitle: '4 services available',
                        ),
                        ServiceTypeOption(
                          title: 'Installation',
                          subtitle: '3 services available',
                        ),
                        ServiceTypeOption(
                          title: 'Inspection',
                          subtitle: '2 services available',
                        ),
                      ],
                      onSelect: (option) {
                        showSpecificServiceDialog(
                          context,
                          title: 'Repairs & Fixes',
                          stepText: 'Step 3 of 3 - Select specific service',
                          options: [
                            SpecificServiceOption(
                              title: 'Door Repair',
                              priceRange: 'Est. \$50–80',
                            ),
                            SpecificServiceOption(
                              title: 'Window Repair',
                              priceRange: 'Est. \$40–70',
                            ),
                            SpecificServiceOption(
                              title: 'Wall Patching',
                              priceRange: 'Est. \$60–100',
                            ),
                            SpecificServiceOption(
                              title: 'Floor Repair',
                              priceRange: 'Est. \$80–150',
                            ),
                          ],
                          onSelect: (opt) {
                            // ekhane tumi go_router diye ager step e jete / confirmation screen e nite paro
                            // context.goNamed('bookingSummary', extra: opt.title);
                            showServiceDetailsDialog(
                              context,
                              selectedService: 'Window Repair',
                              categoryPath:
                                  'General Maintenance → Repairs & fixes',
                            );
                          },
                        );

                        debugPrint('Selected: ${option.title}');
                      },
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentYellow,
                foregroundColor: const Color(0xFF111827),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Book New Service',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------- SERVICE CATEGORIES -------------

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Service Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _circleIconButton(
                icon: Icons.chevron_left,
                onTap: () => _scrollCategories(false),
              ),
              SizedBox(width: 8.w),
              _circleIconButton(
                icon: Icons.chevron_right,
                onTap: () => _scrollCategories(true),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 156.h,
          child: ListView.separated(
            controller: _categoryScrollController,
            padding: EdgeInsets.only(left: 20.w, right: 16.w),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _ServiceCategoryCard(category: category);
            },
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemCount: _categories.length,
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(icon, size: 18.r, color: const Color(0xFF4B5563)),
      ),
    );
  }

  // ------------- ACTIVE REQUESTS -------------

  Widget _buildActiveRequestsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Active Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onViewAllPressed,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    color: kPrimaryRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Column(
            children: _activeJobs
                .map(
                  (job) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _ActiveRequestCard(job: job),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ------------- RECENT SERVICES -------------

  Widget _buildRecentServicesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),
          Column(
            children: _recentJobs
                .map(
                  (job) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _RecentServiceCard(job: job),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ------------- GUEST NOTICE -------------

  Widget _buildGuestNotice() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Card(
        color: const Color(0xFFFFB111).withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: const Color(0xFFFFB111).withOpacity(0.4)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: const Text(
            "You're browsing as a guest. Create an account to view booking history and track your requests.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
          ),
        ),
      ),
    );
  }
}

// =================== MODELS ===================

class _ServiceCategory {
  final String title;
  final String description;
  final int serviceCount;
  final IconData icon;

  const _ServiceCategory({
    required this.title,
    required this.description,
    required this.serviceCount,
    required this.icon,
  });
}

enum _JobStatus { inProgress, scheduled, completed }

class _ActiveJob {
  final String title;
  final String category;
  final String technician;
  final String dateText;
  final _JobStatus status;

  const _ActiveJob({
    required this.title,
    required this.category,
    required this.technician,
    required this.dateText,
    required this.status,
  });
}

class _RecentJob {
  final String title;
  final String category;
  final String dateText;

  const _RecentJob({
    required this.title,
    required this.category,
    required this.dateText,
  });
}

// =================== WIDGETS ===================

class _ServiceCategoryCard extends StatelessWidget {
  const _ServiceCategoryCard({required this.category});

  final _ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      // margin: EdgeInsets.zero,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(20.r),
      // ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFFB111).withOpacity(0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () {
          // TODO: category tap logic (booking step 1)
        },
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45.r,
                height: 45.r,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryRed, kPrimaryRedDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                child: Icon(
                  Icons.build_rounded,
                  color: Colors.white,
                  size: 22.r,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                category.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              Text(
                '${category.serviceCount} services',
                style: const TextStyle(
                  fontSize: 11,
                  color: kPrimaryRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveRequestCard extends StatelessWidget {
  const _ActiveRequestCard({required this.job});

  final _ActiveJob job;

  @override
  Widget build(BuildContext context) {
    final _StatusStyle status = _statusStyle(job.status);

    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _JobMainInfo(job: job)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: status.bg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(status.icon, color: status.text, size: 14),
                      SizedBox(width: 4.w),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: status.text,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Text(
                  job.dateText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryRed,
                    side: const BorderSide(color: kPrimaryRed),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: () {
                    // TODO: details screen/dialog
                    showBookingDetailsDialog(
                      context,
                      details: BookingDetails(
                        status: BookingStatus.inProgress,
                        serviceName: 'HVAC Maintenance',
                        category: 'HVAC Services',
                        description:
                            'Regular maintenance check for air conditioning unit including filter replacement and coolant level check.',
                        scheduledText: 'Today, 2:00 PM',
                        location: '123 Main St, Apt 4B',
                        technicianName: 'John Smith',
                        technicianPhone: '+1 234 567 8900',
                      ),
                    );
                  },
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JobMainInfo extends StatelessWidget {
  const _JobMainInfo({required this.job});

  final _ActiveJob job;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          job.category,
          style: const TextStyle(fontSize: 12, color: kPrimaryRed),
        ),
        SizedBox(height: 2.h),
        Text(
          'Technician: ${job.technician}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _RecentServiceCard extends StatelessWidget {
  const _RecentServiceCard({required this.job});

  final _RecentJob job;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    job.category,
                    style: const TextStyle(fontSize: 11, color: kPrimaryRed),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    job.dateText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// status style helper
class _StatusStyle {
  final Color bg;
  final Color text;
  final IconData icon;
  final String label;

  const _StatusStyle({
    required this.bg,
    required this.text,
    required this.icon,
    required this.label,
  });
}

_StatusStyle _statusStyle(_JobStatus status) {
  switch (status) {
    case _JobStatus.inProgress:
      return const _StatusStyle(
        bg: Color(0xFFE0F2FE),
        text: Color(0xFF1D4ED8),
        icon: Icons.autorenew_rounded,
        label: 'In Progress',
      );
    case _JobStatus.scheduled:
      return const _StatusStyle(
        bg: Color(0xFFFEF3C7),
        text: Color(0xFF92400E),
        icon: Icons.schedule_rounded,
        label: 'Scheduled',
      );
    case _JobStatus.completed:
      return const _StatusStyle(
        bg: Color(0xFFD1FAE5),
        text: Color(0xFF047857),
        icon: Icons.check_circle,
        label: 'Completed',
      );
  }
}
