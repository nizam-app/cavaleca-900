import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:workpleis/features/customer/widget/book_a_service.dart';
import 'package:workpleis/features/customer/widget/genarel_maintenance.dart';
import 'package:workpleis/features/customer/widget/repairs_&_fixes.dart';
import 'package:workpleis/features/customer/widget/service_details.dart';
import 'package:workpleis/features/customer/model/customer_booking_model.dart';
import 'package:workpleis/features/customer/logic/customer_booking_logic.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<CustomerBookingModel> _allBookings = [];
  bool _isLoadingBookings = true;

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

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoadingBookings = true;
    });

    try {
      final bookings = await CustomerBookingLogic.fetchBookings();
      setState(() {
        _allBookings = bookings;
        _isLoadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBookings = false;
      });
      debugPrint('Failed to load bookings: $e');
    }
  }

  List<CustomerBookingModel> _getActiveBookings() {
    return _allBookings.where((b) => b.status == 'ACTIVE').toList();
  }

  void _showBookingDetailsDialog(
    BuildContext context,
    CustomerBookingModel booking,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return _BookingDetailSheet(
          booking: booking,
          onCall: (phone) async {
            if (phone == null || phone.isEmpty) return;
            final uri = Uri.parse('tel:$phone');
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            } catch (e) {
              debugPrint('Error calling: $e');
            }
          },
        );
      },
    );
  }

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
                      '${'hello_guest'.tr()} $_displayName',
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
                      title: 'general_maintenance'.tr(),
                      stepText: 'step_2_select_service_type'.tr(),
                      options: [
                        ServiceTypeOption(
                          title: 'repairs_and_fixes'.tr(),
                          subtitle: '4 services available',
                        ),
                        ServiceTypeOption(
                          title: 'installation'.tr(),
                          subtitle: '3 services available',
                        ),
                        ServiceTypeOption(
                          title: 'inspection'.tr(),
                          subtitle: '2 services available',
                        ),
                      ],
                      onSelect: (option) {
                        showSpecificServiceDialog(
                          context,
                          title:'repairs_and_fixes'.tr(),
                          stepText: 'step_3_select_specific_service'.tr(),
                          options: [
                            SpecificServiceOption(
                              title: 'door_repair'.tr(),
                              priceRange: 'Est. \$50–80',
                            ),
                            SpecificServiceOption(
                              title: 'window_repair'.tr(),
                              priceRange: 'Est. \$40–70',
                            ),
                            SpecificServiceOption(
                              title: 'wall_patching'.tr(),
                              priceRange: 'Est. \$60–100',
                            ),
                            SpecificServiceOption(
                              title: 'floor_repair'.tr(),
                              priceRange: 'Est. \$80–150',
                            ),
                          ],
                          onSelect: (opt) {
                            // ekhane tumi go_router diye ager step e jete / confirmation screen e nite paro
                            // context.goNamed('bookingSummary', extra: opt.title);
                            showServiceDetailsDialog(
                              context,
                              selectedService: 'window_repair'.tr(),
                              categoryPath:
                                  'general_maintenance_repairs_fixes'.tr(),
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
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'book_new_service'.tr(),
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
               Expanded(
                child: Text(
                  'service_categories'.tr(),
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
    final activeBookings = _getActiveBookings();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            children: [
               Expanded(
                child: Text(
                  'active_requests'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onViewAllPressed,
                child:  Text(
                  'view_all'.tr(),
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
          if (_isLoadingBookings)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (activeBookings.isEmpty)
            Card(
              elevation: 1.5,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: const Center(
                  child: Text(
                    'No active requests',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            )
          else
            Column(
              children: activeBookings
                  .map(
                    (booking) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _ActiveRequestCard(
                        booking: booking,
                        onViewDetails: () => _showBookingDetailsDialog(context, booking),
                      ),
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
           Text(
            'recent_services'.tr(),
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
          child:  Text(
            "guest_browsing_notice".tr(),
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
  const _ActiveRequestCard({
    required this.booking,
    required this.onViewDetails,
  });

  final CustomerBookingModel booking;
  final VoidCallback onViewDetails;

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not scheduled';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return 'Today, ${DateFormat('h:mm a').format(date)}';
      } else if (dateOnly == today.add(const Duration(days: 1))) {
        return 'Tomorrow, ${DateFormat('h:mm a').format(date)}';
      } else {
        return DateFormat('MMM d, yyyy, h:mm a').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _callTechnician(String? phone) async {
    if (phone == null || phone.isEmpty) return;

    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error calling: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusBg = const Color(0xFFEFF6FF);
    final Color statusText = const Color(0xFF1D4ED8);
    final String technicianName =
        booking.assignedTechnician?.name ?? 'Not Assigned';
    final String? technicianPhone = booking.assignedTechnician?.phone;
    final String serviceName = booking.service?.name ?? 'Service';
    final String categoryName = booking.category?.name ?? '';

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (categoryName.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          categoryName,
                          style: const TextStyle(fontSize: 12, color: kPrimaryRed),
                        ),
                      ],
                      SizedBox(height: 2.h),
                      Text(
                        'Technician: $technicianName',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
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
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, color: statusText, size: 14),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          booking.readableStatus,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: statusText,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  _formatDate(booking.scheduledAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const Spacer(),
                if (technicianPhone != null && technicianPhone.isNotEmpty) ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryRed,
                      side: const BorderSide(color: kPrimaryRed),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    onPressed: () => _callTechnician(technicianPhone),
                    child: const Icon(Icons.phone, size: 14),
                  ),
                  SizedBox(width: 8.w),
                ],
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
                  onPressed: onViewDetails,
                  child: Text(
                    'view_details'.tr(),
                    style: TextStyle(fontSize: 11.sp),
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

// ------------------ Booking detail bottom sheet ------------------

class _BookingDetailSheet extends StatelessWidget {
  const _BookingDetailSheet({required this.booking, required this.onCall});

  final CustomerBookingModel booking;
  final Future<void> Function(String?) onCall;

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not scheduled';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy, h:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    return parts.map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = booking.status == 'ACTIVE';
    final Color chipBg = isActive
        ? const Color(0xFFEFF6FF)
        : booking.status == 'COMPLETED'
            ? const Color(0xFFD1FAE5)
            : const Color(0xFFFEE2E2);
    final Color chipText = isActive
        ? const Color(0xFF1D4ED8)
        : booking.status == 'COMPLETED'
            ? const Color(0xFF065F46)
            : const Color(0xFF991B1B);
    final String chipLabel = booking.readableStatus;

    final String technicianName = booking.assignedTechnician?.name ?? 'Not Assigned';
    final String? technicianPhone = booking.assignedTechnician?.phone;
    final String initials = _getInitials(technicianName);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'booking_details'.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'view_booking_info'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Status chip
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 16.sp, color: chipText),
                      SizedBox(width: 6.w),
                      Text(
                        chipLabel,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: chipText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // SR Number
              _buildDetailRow('SR Number', booking.srNumber),
              SizedBox(height: 8.h),
              _buildDetailRow('Status', booking.status),
              SizedBox(height: 8.h),
              _buildDetailRow('Internal Status', booking.internalStatus),
              SizedBox(height: 8.h),
              _buildDetailRow('Priority', booking.priority),
              SizedBox(height: 16.h),

              // Service info card
              Card(
                elevation: 2,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        booking.service?.name ?? 'N/A',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (booking.category != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          'category'.tr(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          booking.category!.name,
                          style: TextStyle(fontSize: 13.sp, color: kPrimaryRed),
                        ),
                        if (booking.category!.description.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            booking.category!.description,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                      if (booking.subservice != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          'Subservice',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          booking.subservice!.name,
                          style: TextStyle(fontSize: 13.sp, color: kPrimaryRed),
                        ),
                      ],
                      SizedBox(height: 12.h),
                      Text(
                        'description'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        booking.description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Schedule card
              Card(
                elevation: 2,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: const Color(0xFF1D4ED8),
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'scheduled'.tr(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _formatDate(booking.scheduledAt),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            if (booking.preferredAppointmentDate != null ||
                                booking.preferredAppointmentTime != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                'Preferred: ${booking.preferredAppointmentDate ?? ''} ${booking.preferredAppointmentTime ?? ''}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Location card
              Card(
                elevation: 2,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: kPrimaryRed,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'location'.tr(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              booking.address,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Technician card
              if (booking.assignedTechnician != null)
                Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'assigned_technician'.tr(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [kPrimaryRed, kPrimaryRedDark],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      technicianName,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                    if (technicianPhone != null) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        technicianPhone,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            if (technicianPhone != null)
                              SizedBox(
                                height: 36.h,
                                child: ElevatedButton(
                                  onPressed: () => onCall(technicianPhone),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryRed,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                  child: Icon(Icons.phone, size: 18.sp),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Payment Summary
              if (booking.paymentSummary != null) ...[
                SizedBox(height: 12.h),
                Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Summary',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _buildDetailRow('Total Amount',
                            '\$${booking.paymentSummary!.totalAmount.toStringAsFixed(2)}'),
                        SizedBox(height: 4.h),
                        _buildDetailRow('Payment Status',
                            booking.paymentSummary!.paymentStatus),
                        if (booking.paymentSummary!.paymentMethod != null) ...[
                          SizedBox(height: 4.h),
                          _buildDetailRow('Payment Method',
                              booking.paymentSummary!.paymentMethod!),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              // Technician Rating
              if (booking.technicianRating != null) ...[
                SizedBox(height: 12.h),
                Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Technician Rating',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < booking.technicianRating!.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                        if (booking.technicianRating!.comment != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            booking.technicianRating!.comment!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              // Dates
              SizedBox(height: 12.h),
              _buildDetailRow('Created At', _formatDate(booking.createdAt)),
              SizedBox(height: 4.h),
              _buildDetailRow('Updated At', _formatDate(booking.updatedAt)),

              SizedBox(height: 16.h),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      child: Text(
                        'close'.tr(),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

