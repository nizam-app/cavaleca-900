import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/customer/model/map_local_data_map.dart';
import 'package:workpleis/features/customer/screen/map.dart';
import 'package:easy_localization/easy_localization.dart';
import '../screen/service/data/service_data.dart';
import '../screen/service/model/create_sr_model.dart';
import '../screen/profile/data/customer_profile_data.dart';
const _kPrimaryRed = Color(0xFFC20001);
const _kPrimaryRedDark = Color(0xFF9A0001);
const _kDialogShadow = BoxShadow(
  color: Color(0x22000000),
  blurRadius: 18,
  offset: Offset(0, 6),
);

/// Call this to open the dialog:
/// showServiceDetailsDialog(
///   context,
///   selectedService: 'Window Repair',
///   categoryPath: 'General Maintenance → Repairs & fixes',
/// );
Future<void> showServiceDetailsDialog(
  BuildContext context, {
  required String selectedService,
  required String categoryPath,
  required int categoryId, // NEW
  required int serviceId, // NEW
  required int subserviceId, // NEW
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'service_details'.tr(),
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (_, __, ___) {
      return _ServiceDetailsDialog(
        selectedService: selectedService,
        categoryPath: categoryPath,
        categoryId: categoryId,
        serviceId: serviceId,
        subserviceId: subserviceId,
      );
    },
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ServiceDetailsDialog extends StatefulWidget {
  const _ServiceDetailsDialog({
    required this.selectedService,
    required this.categoryPath,
    required this.categoryId,
    required this.serviceId,
    required this.subserviceId,
  });

  final String selectedService;
  final String categoryPath;
  final int categoryId;
  final int serviceId;
  final int subserviceId;

  @override
  State<_ServiceDetailsDialog> createState() => _ServiceDetailsDialogState();
}

class _ServiceDetailsDialogState extends State<_ServiceDetailsDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _dateText;
  String? _timeText;
  bool _cashSelected = true;
  bool _isSubmitting = false;

  LocationData? _selectedLocation; // map থেকে latitude/longitude

  @override
  void initState() {
    super.initState();
    _loadCustomerProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerProfile() async {
    try {
      final profile = await CustomerProfileApi.getProfile();
      
      if (!mounted) return;
      
      // Auto-fill name, phone, and address if available
      if (profile.name.isNotEmpty) {
        _nameCtrl.text = profile.name;
      }
      if (profile.phone.isNotEmpty) {
        _phoneCtrl.text = profile.phone;
      }
      if (profile.homeAddress != null && profile.homeAddress!.isNotEmpty) {
        _addressCtrl.text = profile.homeAddress!;
      }
      
      // Set location if available
      if (profile.latitude != null && profile.longitude != null) {
        _selectedLocation = LocationData(
          latitude: profile.latitude!,
          longitude: profile.longitude!,
          address: profile.homeAddress ?? '',
          placeName: null,
        );
      }
    } catch (e) {
      // If profile load fails (e.g., user not logged in or guest), just continue
      // without auto-filling - this is expected for guest users
      debugPrint('Failed to load customer profile: $e');
    }
  }


  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black87,             // Header & selected date color
              onPrimary: Colors.white,          // Header text color
              onSurface: Colors.black,          // Normal text color
            ),
            dialogBackgroundColor: Colors.white, // Calendar background
            datePickerTheme: DatePickerThemeData(
              todayForegroundColor: MaterialStateProperty.all(Color(0xFFFFB111)),
              todayBackgroundColor: MaterialStateProperty.all(
                Colors.blue.withOpacity(0.15),
              ),
             // selectedDayBackgroundColor: Colors.blue, // Selected date circle
              //selectedDayForegroundColor: Colors.white, // Selected date text
              dayStyle: TextStyle(color: Colors.black),
              weekdayStyle: TextStyle(color: Colors.blueGrey),
              headerForegroundColor: Colors.white, // Month-year text
              headerBackgroundColor:Color(0xFFFFB111),  // Header background
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateText =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }


  // Future<void> _pickDate() async {
  //   final now = DateTime.now();
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: now,
  //     firstDate: now,
  //     lastDate: now.add(const Duration(days: 365)),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _dateText =
  //           '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  //     });
  //   }
  // }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,              // Picker background
              dialBackgroundColor: Colors.blue.shade50,   // Clock circle
              dialHandColor: Colors.white,                 // Clock hand
              dialTextColor: Colors.black,                // Clock numbers
              hourMinuteColor: Colors.blue.shade100,      // Hour/min box
              hourMinuteTextColor: Colors.black,          // Hour/min text
              entryModeIconColor: Colors.black87,            // Keyboard icon
            ),
            colorScheme: ColorScheme.light(
              primary: Colors.black87,                       // AM/PM select color
              onSurface: Colors.black,                    // Text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        _timeText = '$hour:$minute $period';
      });
    }
  }


  // Future<void> _pickTime() async {
  //   final picked = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
  //       final minute = picked.minute.toString().padLeft(2, '0');
  //       final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
  //       _timeText = '$hour:$minute $period';
  //     });
  //   }
  // }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('name_phone_address_required'.tr())),
      );
      return;
    }

    final payload = ServiceRequestPayload(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      categoryId: widget.categoryId,
      serviceId: widget.serviceId,
      subserviceId: widget.subserviceId,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      paymentType: _cashSelected ? 'CASH' : 'MOBILE_MONEY',
      priority: 'MEDIUM', // চাইলে UI থেকে নাও
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
    );

    setState(() => _isSubmitting = true);

    try {
      await FsmCustomerApi.createServiceRequest(payload);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // dialog close

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('service_request_submitted_successfully'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'failed_to_submit_request'.tr()}: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Container(
              width: 430,
              constraints: const BoxConstraints(maxHeight: 640),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [_kDialogShadow],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  children: [
                    _buildHeader(context),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSelectedServiceCard(),
                            const SizedBox(height: 18),
                            _buildTextField(
                              label: 'full_name'.tr(),
                              hint: 'enter_name'.tr(),
                              controller: _nameCtrl,
                              textInputType: TextInputType.name,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'phone_number'.tr(),
                              hint: 'enter_your_phone_number'.tr(),
                              controller: _phoneCtrl,
                              textInputType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            _buildAddressField(),
                            const SizedBox(height: 12),
                            _buildDescriptionField(),
                            const SizedBox(height: 16),
                            _buildDateTimeSection(),
                            const SizedBox(height: 16),
                            _buildPaymentSection(),
                            const SizedBox(height: 24),
                            _buildFooterButtons(context),
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
      ),
    );
  }

  // ---------------- header ----------------

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4, right: 8, top: 12, bottom: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:  [
                Text(
                  'service_details'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'fill_details_to_complete_booking'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  // ---------------- selected service card ----------------

  Widget _buildSelectedServiceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimaryRed, _kPrimaryRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'selected_service'.tr(),
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.selectedService,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.categoryPath,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- fields ----------------

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType textInputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: textInputType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: label.startsWith('Full')
                ? const Icon(Icons.person_outline, size: 20)
                : label.startsWith('Phone')
                ? const Icon(Icons.phone_outlined, size: 20)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kPrimaryRed),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'service_address'.tr(),
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _addressCtrl,
          decoration: InputDecoration(
            hintText: 'tap_to_select_location'.tr(),
            prefixIcon: const Icon(Icons.home_outlined, size: 20),
            suffixIcon: Container(
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: _kPrimaryRed,
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: () async {
                  final result = await context.push<LocationData>(
                    MapAddressPickerScreen.routeName,
                  );

                  if (result != null) {
                    setState(() {
                      // place name + address
                      final name = result.placeName?.trim();
                      if (name != null && name.isNotEmpty) {
                        _addressCtrl.text = '$name, ${result.address}';
                      } else {
                        _addressCtrl.text = result.address;
                      }
                    });
                  }
                },
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kPrimaryRed),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'description_optional'.tr(),
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _descCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'describe_requirements'.tr(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kPrimaryRed),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
          ),
        ),
      ],
    );
  }

  // ---------------- date & time ----------------

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'preferred_appointment_date_time'.tr(),
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DateTimeChip(
                icon: Icons.calendar_today_outlined,
                label: _dateText ?? 'date'.tr(),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateTimeChip(
                icon: Icons.access_time,
                label: _timeText ?? 'time'.tr(),
                onTap: _pickTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
         Text(
          'appointment_notice'.tr(),
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  // ---------------- payment method ----------------

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'payment_method'.tr(),
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _PaymentOptionCard(
          title: 'cash_payment'.tr(),
          subtitle: 'pay_with_cash'.tr(),
          selected: _cashSelected,
          onTap: () => setState(() => _cashSelected = true),
        ),
         SizedBox(height: 8),
        _PaymentOptionCard(
          title: 'mobile_money'.tr(),
          subtitle: 'pay_via_mobile_money'.tr(),
          selected: !_cashSelected,
          onTap: () => setState(() => _cashSelected = false),
        ),
      ],
    );
  }

  // ---------------- footer buttons ----------------

  Widget _buildFooterButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFFF9FAFB),
            ),
            child:  Text(
              'cancel'.tr(),
              style: TextStyle(color: Color(0xFF111827), fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                :  Text(
                    'submit_request'.tr(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------
// helper widgets
// ------------------------------------------------------------------

class _DateTimeChip extends StatelessWidget {
  const _DateTimeChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: label == 'date'.tr() || label == 'time'.tr()
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? _kPrimaryRed : const Color(0xFFE5E7EB);
    final dotColor = selected ? _kPrimaryRed : const Color(0xFFD1D5DB);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? _kPrimaryRed : Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
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
