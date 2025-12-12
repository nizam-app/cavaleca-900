import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:workpleis/features/customer/model/customer_booking_model.dart';
import 'package:workpleis/features/customer/logic/customer_booking_logic.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({
    super.key,
    this.isGuest = false,
    this.onSignUp,
  });

  static const String routeName = '/customerBookings';

  final bool isGuest;
  final VoidCallback? onSignUp;

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  List<CustomerBookingModel> _allBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookings = await CustomerBookingLogic.fetchBookings();
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showSnack('${'failed_to_load_bookings'.tr()}: ${e.toString()}');
    }
  }

  List<CustomerBookingModel> _getActiveBookings() {
    return _allBookings.where((b) => b.status == 'ACTIVE').toList();
  }

  List<CustomerBookingModel> _getCompletedBookings() {
    return _allBookings.where((b) => b.status == 'COMPLETED').toList();
  }

  List<CustomerBookingModel> _getCancelledBookings() {
    return _allBookings.where((b) => b.status == 'CANCELLED').toList();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'not_scheduled'.tr();
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return '${'today'.tr()}, ${DateFormat('h:mm a').format(date)}';
      } else if (dateOnly == today.add(const Duration(days: 1))) {
        return '${'tomorrow'.tr()}, ${DateFormat('h:mm a').format(date)}';
      } else {
        return DateFormat('MMM d, yyyy, h:mm a').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateOnly(String? dateString) {
    if (dateString == null) return 'n_a'.tr();
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // ------------------ Helpers ------------------

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _call(String? phone) async {
    if (phone == null || phone.isEmpty) {
      _showSnack('phone_number_not_available'.tr());
      return;
    }

    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnack('cannot_make_phone_call'.tr());
      }
    } catch (e) {
      _showSnack('${'error_calling'.tr()}: ${e.toString()}');
    }
  }

  void _openBookingDetails(CustomerBookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return _BookingDetailSheet(booking: booking, onCall: _call);
      },
    );
  }

  Future<void> _handleBookAgain(int srId) async {
    try {
      await CustomerBookingLogic.bookAgain(srId);
      _showSnack('service_booked_again_successfully'.tr());
      _loadBookings(); // Refresh the list
    } catch (e) {
      _showSnack('${'failed_to_book_again'.tr()}: ${e.toString()}');
    }
  }

  Future<void> _handleRebook(int srId) async {
    try {
      await CustomerBookingLogic.rebook(srId);
      _showSnack('service_rebooked_successfully'.tr());
      _loadBookings(); // Refresh the list
    } catch (e) {
      _showSnack('${'failed_to_rebook'.tr()}: ${e.toString()}');
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10.r,
          offset: Offset(0, 4.h),
        ),
      ],
    );
  }

  // ------------------ Build ------------------

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest) {
      return _buildGuestView(context);
    }
    return _buildAuthedView(context);
  }

  // -------- Guest view --------

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BookingsHeader(),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Card(
                // elevation: 3,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 32.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64.w,
                        height: 64.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB111).withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          color: const Color(0xFFFFB111),
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'guest_access_limited'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'create_account_to_view_history'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 44.h,
                        child: ElevatedButton(
                          onPressed: widget.onSignUp ?? () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'create_account'.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  // -------- Authenticated view --------

  Widget _buildAuthedView(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BookingsHeader(),
                  SizedBox(height: 16.h),

                  // Tabs container (pills)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Container(
                      height: 50.h,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: kPrimaryRed,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF6B7280),
                        dividerColor: Colors.transparent,
                        labelStyle: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs:  [
                          Tab(text: 'all'.tr()),
                          Tab(text: 'active'.tr()),
                          Tab(text: 'completed'.tr()),
                          Tab(text: 'cancelled'.tr()),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Tab contents
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
                      child: TabBarView(
                        children: [
                          _buildAllList(),
                          _buildActiveList(),
                          _buildCompletedList(),
                          _buildCancelledList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ List builders ------------------

  Widget _buildAllList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${'error'.tr()}: $_errorMessage'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadBookings,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (_allBookings.isEmpty) {
      return Center(child: Text('no_bookings'.tr()));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 24.h),
        itemCount: _allBookings.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final booking = _allBookings[index];
          // Show appropriate card based on status
          if (booking.status == 'ACTIVE') {
            return _buildActiveCard(booking);
          } else if (booking.status == 'COMPLETED') {
            return _buildCompletedCard(booking);
          } else if (booking.status == 'CANCELLED') {
            return _buildCancelledCard(booking);
          } else {
            // Fallback to active card for unknown statuses
            return _buildActiveCard(booking);
          }
        },
      ),
    );
  }

  Widget _buildActiveList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${'error'.tr()}: $_errorMessage'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadBookings,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    final activeBookings = _getActiveBookings();
    if (activeBookings.isEmpty) {
      return Center(child: Text('no_active_bookings'.tr()));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 24.h),
        itemCount: activeBookings.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final booking = activeBookings[index];
          return _buildActiveCard(booking);
        },
      ),
    );
  }

  Widget _buildCompletedList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${'error'.tr()}: $_errorMessage'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadBookings,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    final completedBookings = _getCompletedBookings();
    if (completedBookings.isEmpty) {
      return Center(child: Text('no_completed_bookings'.tr()));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 24.h),
        itemCount: completedBookings.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final booking = completedBookings[index];
          return _buildCompletedCard(booking);
        },
      ),
    );
  }

  Widget _buildCancelledList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${'error'.tr()}: $_errorMessage'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadBookings,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    final cancelledBookings = _getCancelledBookings();
    if (cancelledBookings.isEmpty) {
      return Center(child: Text('no_cancelled_bookings'.tr()));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 24.h),
        itemCount: cancelledBookings.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final booking = cancelledBookings[index];
          return _buildCancelledCard(booking);
        },
      ),
    );
  }

  // ------------------ Cards ------------------

  Widget _buildActiveCard(CustomerBookingModel booking) {
    final bool hasTechnician = booking.assignedTechnician != null;
    final String technicianName = hasTechnician
        ? booking.assignedTechnician!.name
        : 'not_assigned'.tr();
    final String? technicianPhone = hasTechnician
        ? booking.assignedTechnician!.phone
        : null;

    final Color chipBg = const Color(0xFFEFF6FF);
    final Color chipText = const Color(0xFF1D4ED8);
    final String chipLabel = booking.readableStatus;

    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.service?.name ?? 'service'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${'technician_label'.tr()} $technicianName',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
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
                    color: chipBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 14.sp, color: chipText),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          chipLabel,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: chipText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _formatDate(booking.scheduledAt),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    booking.address,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Buttons
            Row(
              children: [
                if (hasTechnician && technicianPhone != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _call(technicianPhone),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: const Color(0xFF4B5563),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      icon: Icon(Icons.phone, size: 16.sp),
                      label: Text('call'.tr(), style: TextStyle(fontSize: 13.sp)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openBookingDetails(booking),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: kPrimaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'view_details'.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// COMPLETED TAB – pixel perfect to screenshot
  Widget _buildCompletedCard(CustomerBookingModel booking) {
    final String technicianName = booking.assignedTechnician?.name ?? 'not_assigned'.tr();

    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + green check circle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.service?.name ?? 'service'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${'technician_label'.tr()} $technicianName',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 1.5.w,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14.sp,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _formatDateOnly(booking.updatedAt),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),

            // Location
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    booking.address,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Book Again pill button
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: OutlinedButton(
                onPressed: () => _handleBookAgain(booking.srId),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  side: const BorderSide(color: Color(0xFFF5F5F5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                ),
                child: Text(
                  'book_again'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledCard(CustomerBookingModel booking) {
    final String technicianName = booking.assignedTechnician?.name ?? 'not_assigned'.tr();

    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + X icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.service?.name ?? 'service'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        technicianName,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.cancel, color: Colors.red, size: 20.sp),
              ],
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _formatDateOnly(booking.updatedAt),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: OutlinedButton(
                onPressed: () => _handleRebook(booking.srId),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'rebook_service'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF4B5563),
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

// ------------------ Header (red gradient) ------------------

class _BookingsHeader extends StatelessWidget {
  const _BookingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 32.h,
        bottom: 20.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryRed, kPrimaryRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'my_bookings'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'track_service_requests'.tr(),
            style: TextStyle(fontSize: 13.sp, color: Colors.white70),
          ),
        ],
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
    if (dateString == null) return 'not_scheduled'.tr();
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

    final String technicianName = booking.assignedTechnician?.name ?? 'not_assigned'.tr();
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
              _buildDetailRow('sr_number'.tr(), booking.srNumber),
              SizedBox(height: 8.h),
              _buildDetailRow('status'.tr(), booking.status),
              SizedBox(height: 8.h),
              _buildDetailRow('internal_status'.tr(), booking.internalStatus),
              SizedBox(height: 8.h),
              _buildDetailRow('priority'.tr(), booking.priority),
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
                        'service'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        booking.service?.name ?? 'n_a'.tr(),
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
                          'subservice'.tr(),
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
                                '${'preferred'.tr()} ${booking.preferredAppointmentDate ?? ''} ${booking.preferredAppointmentTime ?? ''}',
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
                          'payment_summary'.tr(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _buildDetailRow('total_amount'.tr(),
                            '\$${booking.paymentSummary!.totalAmount.toStringAsFixed(2)}'),
                        SizedBox(height: 4.h),
                        _buildDetailRow('payment_status'.tr(),
                            booking.paymentSummary!.paymentStatus),
                        if (booking.paymentSummary!.paymentMethod != null) ...[
                          SizedBox(height: 4.h),
                          _buildDetailRow('payment_method'.tr(),
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
                          'technician_rating'.tr(),
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
              _buildDetailRow('created_at'.tr(), _formatDate(booking.createdAt)),
              SizedBox(height: 4.h),
              _buildDetailRow('updated_at'.tr(), _formatDate(booking.updatedAt)),

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

