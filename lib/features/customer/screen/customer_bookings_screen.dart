import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);

enum BookingStatus { inProgress, scheduled, completed, cancelled }

class Booking {
  final int id;
  final String service;
  final String? category;
  final String technician;
  final String date;
  final String? location;
  final BookingStatus status;
  final String? phone;
  final String? description;
  final String? reason;

  const Booking({
    required this.id,
    required this.service,
    this.category,
    required this.technician,
    required this.date,
    this.location,
    required this.status,
    this.phone,
    this.description,
    this.reason,
  });
}

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
  // ------------------ Dummy data (TSX er moto) ------------------

  final List<Booking> _activeBookings = const [
    Booking(
      id: 1,
      service: 'HVAC Maintenance',
      category: 'HVAC Services',
      technician: 'John Smith',
      date: 'Today, 2:00 PM',
      location: '123 Main St, Apt 4B',
      status: BookingStatus.inProgress,
      phone: '+1 234 567 8900',
      description:
          'Regular maintenance check for air conditioning unit including filter replacement and coolant level check.',
    ),
    Booking(
      id: 2,
      service: 'Electrical Repair',
      category: 'Electrical Services',
      technician: 'Sarah Johnson',
      date: 'Tomorrow, 10:00 AM',
      location: '123 Main St, Apt 4B',
      status: BookingStatus.scheduled,
      phone: '+1 234 567 8901',
      description:
          'Fix faulty electrical outlet in the living room. Safety inspection included.',
    ),
    Booking(
      id: 3,
      service: 'Plumbing Inspection',
      category: 'Plumbing Services',
      technician: 'Mike Davis',
      date: 'Nov 6, 2025, 3:00 PM',
      location: '123 Main St, Apt 4B',
      status: BookingStatus.scheduled,
      phone: '+1 234 567 8902',
      description:
          'Comprehensive plumbing system inspection and leak detection.',
    ),
  ];

  final List<Booking> _completedBookings = const [
    Booking(
      id: 4,
      service: 'Plumbing Fix',
      category: 'Plumbing Services',
      technician: 'Mike Davis',
      date: 'Nov 1, 2025',
      location: '123 Main St, Apt 4B',
      status: BookingStatus.completed,
    ),
    Booking(
      id: 5,
      service: 'General Maintenance',
      category: 'General Maintenance',
      technician: 'Lisa Brown',
      date: 'Oct 28, 2025',
      location: '123 Main St, Apt 4B',
      status: BookingStatus.completed,
    ),
    Booking(
      id: 6,
      service: 'Electrical Installation',
      category: 'Electrical Services',
      technician: 'John Smith',
      date: 'Oct 15, 2025',
      location: '123 Main St, Apt 4B',
      status: BookingStatus.completed,
    ),
  ];

  final List<Booking> _cancelledBookings = const [
    Booking(
      id: 7,
      service: 'HVAC Repair',
      category: 'HVAC Services',
      technician: 'Not Assigned',
      date: 'Oct 20, 2025',
      status: BookingStatus.cancelled,
      reason: 'Rescheduled by customer',
    ),
  ];

  // ------------------ Helpers ------------------

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _call(String? phone) {
    if (phone == null) return;
    // TODO: url_launcher diye real call korbe
    _showSnack('Calling $phone ...');
  }

  void _openBookingDetails(Booking booking) {
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
                        'Guest Access Limited',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Create an account to view and track your booking history',
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
                            'Create Account',
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
      length: 3,
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
                        labelStyle: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: 'Active'),
                          Tab(text: 'Completed'),
                          Tab(text: 'Cancelled'),
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

  Widget _buildActiveList() {
    if (_activeBookings.isEmpty) {
      return const Center(child: Text('No active bookings'));
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: _activeBookings.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final booking = _activeBookings[index];
        return _buildActiveCard(booking);
      },
    );
  }

  Widget _buildCompletedList() {
    if (_completedBookings.isEmpty) {
      return const Center(child: Text('No completed bookings'));
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: _completedBookings.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final booking = _completedBookings[index];
        return _buildCompletedCard(booking);
      },
    );
  }

  Widget _buildCancelledList() {
    if (_cancelledBookings.isEmpty) {
      return const Center(child: Text('No cancelled bookings'));
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: _cancelledBookings.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final booking = _cancelledBookings[index];
        return _buildCancelledCard(booking);
      },
    );
  }

  // ------------------ Cards ------------------

  Widget _buildActiveCard(Booking booking) {
    final bool isInProgress = booking.status == BookingStatus.inProgress;

    final Color chipBg = isInProgress
        ? const Color(0xFFEFF6FF)
        : const Color(0xFFFEF3C7);
    final Color chipText = isInProgress
        ? const Color(0xFF1D4ED8)
        : const Color(0xFF92400E);
    final String chipLabel = isInProgress ? 'In Progress' : 'Scheduled';

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
                        booking.service,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Technician: ${booking.technician}',
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
                      Text(
                        chipLabel,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: chipText,
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
                    booking.date,
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
            if (booking.location != null) ...[
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
                      booking.location!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _call(booking.phone),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF4B5563),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    icon: Icon(Icons.phone, size: 16.sp),
                    label: Text('Call', style: TextStyle(fontSize: 13.sp)),
                  ),
                ),
                SizedBox(width: 8.w),
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
                      'View Details',
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
  Widget _buildCompletedCard(Booking booking) {
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
                        booking.service,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Technician: ${booking.technician}',
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
                    booking.date,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),

            // Location
            if (booking.location != null) ...[
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
                      booking.location!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 12.h),

            // Book Again pill button
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: OutlinedButton(
                onPressed: () {
                  _showSnack('Booking ${booking.service} again...');
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  side: const BorderSide(color: Color(0xFFF5F5F5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                ),
                child: Text(
                  'Book Again',
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

  Widget _buildCancelledCard(Booking booking) {
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
                        booking.service,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        booking.technician,
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
                    booking.date,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
            if (booking.reason != null) ...[
              SizedBox(height: 4.h),
              Text(
                'Reason: ${booking.reason}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: OutlinedButton(
                onPressed: () {
                  _showSnack('Rebooking ${booking.service} ...');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Rebook Service',
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
  const _BookingsHeader({super.key});

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
            'My Bookings',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Track your service requests',
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

  final Booking booking;
  final void Function(String?) onCall;

  @override
  Widget build(BuildContext context) {
    final bool isInProgress = booking.status == BookingStatus.inProgress;
    final bool isScheduled = booking.status == BookingStatus.scheduled;

    final Color chipBg = isInProgress
        ? const Color(0xFFEFF6FF)
        : const Color(0xFFFEF3C7);
    final Color chipText = isInProgress
        ? const Color(0xFF1D4ED8)
        : const Color(0xFF92400E);
    final String chipLabel = isInProgress
        ? 'In Progress'
        : (isScheduled ? 'Scheduled' : '');

    String initials = '';
    if (booking.technician.isNotEmpty) {
      final parts = booking.technician.split(' ');
      initials = parts.map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
    }

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
                  'Booking Details',
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
                  'View your service booking information',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              if (chipLabel.isNotEmpty)
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
                        Icon(Icons.access_time, size: 16.sp, color: chipText),
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
                        booking.service,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (booking.category != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          booking.category!,
                          style: TextStyle(fontSize: 13.sp, color: kPrimaryRed),
                        ),
                      ],
                      if (booking.description != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          booking.description!,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheduled',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.date,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Location card
              if (booking.location != null)
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              booking.location!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 12.h),

              // Technician card
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
                        'Assigned Technician',
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
                                  initials.toUpperCase(),
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
                                    booking.technician,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  if (booking.phone != null) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      booking.phone!,
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
                          if (booking.phone != null)
                            SizedBox(
                              height: 36.h,
                              child: ElevatedButton(
                                onPressed: () => onCall(booking.phone),
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
                        'Close',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  if (isScheduled) ...[
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reschedule feature coming soon!'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                        child: const Text('Reschedule'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
