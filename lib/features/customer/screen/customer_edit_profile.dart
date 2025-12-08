import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);
const Color kAccentYellow = Color(0xFFFFB111);
const Color kAccentYellowDark = Color(0xFFE69F0F);

/// Same idea as your TSX ProfileData + LocationData
class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String? placeName;
  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeName,
  });
}

class CustomerProfileData {
  final String name;
  final String phone;
  final String email;
  final String address;
  final String? placeName;
  final LocationData? location;

  const CustomerProfileData({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.placeName,
    this.location,
  });
}

class CustomerEditProfile extends ConsumerStatefulWidget {
  const CustomerEditProfile({
    super.key,
    this.initialName = '',
    this.initialPhone = '',
    this.initialEmail = '',
    this.initialAddress = '',
    this.initialPlaceName,
    this.initialLocation,
  });

  static const String routeName = '/customer-edit-profile';

  final String initialName;
  final String initialPhone;
  final String initialEmail;
  final String initialAddress;
  final String? initialPlaceName;
  final LocationData? initialLocation;

  @override
  ConsumerState<CustomerEditProfile> createState() =>
      _CustomerEditProfileState();
}

class _CustomerEditProfileState
    extends ConsumerState<CustomerEditProfile> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  LocationData? _locationData;
  String? _placeName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);
    _addressController = TextEditingController(text: widget.initialAddress);
    _placeName = widget.initialPlaceName;
    _locationData = widget.initialLocation;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _openMapPicker() async {
    // GoRouter diye map picker screen e jao
    // Route theke LocationData return korbe
    final result = await context.push<LocationData>(
      '/map-address-picker',
      extra: _locationData,
    );

    if (result != null) {
      setState(() {
        _locationData = result;
        _placeName = result.placeName;
        _addressController.text = result.address;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      _showToast('Please enter your name');
      return;
    }
    if (phone.isEmpty) {
      _showToast('Please enter your phone number');
      return;
    }
    if (email.isEmpty) {
      _showToast('Please enter your email');
      return;
    }

    setState(() => _isSaving = true);

    // TODO: ekhane real API call korbe (Riverpod repo theke)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSaving = false);

    final result = CustomerProfileData(
      name: name,
      phone: phone,
      email: email,
      address: address,
      placeName: _placeName,
      location: _locationData,
    );

    _showToast('Profile updated successfully!');
    context.pop<CustomerProfileData>(result);
  }

  Widget _buildLabeledField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              icon,
              size: 20.sp,
              color: Colors.grey[400],
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: kPrimaryRed,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Header (gradient, back, title) ----------
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimaryRed, kPrimaryRedDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- Content ----------
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar card
                    SizedBox(
                      width: double.infinity,
                      // height: 170.w,
                      child: Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 20.h,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 48.r,
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            kPrimaryRed,
                                            kPrimaryRedDark,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getInitials(_nameController.text),
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        // TODO: photo change handle
                                      },
                                      child: Container(
                                        width: 32.w,
                                        height: 32.w,
                                        decoration: BoxDecoration(
                                          color: kAccentYellow,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                              Colors.black.withOpacity(0.25),
                                              offset: const Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.camera_alt_rounded,
                                          size: 16.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Tap to change photo',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[500],
                                  fontSize: 14.sp,

                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Personal Information title
                    Text(
                      'Personal Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[900],
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Name
                    _buildLabeledField(
                      label: 'Full Name *',
                      icon: Icons.person_outline_rounded,
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      keyboardType: TextInputType.name,

                    ),
                    SizedBox(height: 16.h),

                    // Phone
                    _buildLabeledField(
                      label: 'Phone Number *',
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                      hintText: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),
                    // Email
                    _buildLabeledField(
                      label: 'Email Address *',
                      icon: Icons.mail_outline_rounded,
                      controller: _emailController,
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.h),

                    // Address (map picker)
                    Text(
                      'Address',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    InkWell(
                      onTap: _openMapPicker,
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Icon(
                                Icons.location_on_outlined,
                                size: 20.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _addressController.text.isNotEmpty
                                  ? Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  if (_placeName != null &&
                                      _placeName!.isNotEmpty)
                                    Padding(
                                      padding:
                                      EdgeInsets.only(bottom: 2.h),
                                      child: Text(
                                        _placeName!,
                                        style: theme
                                            .textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.grey[900],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    _addressController.text,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              )
                                  : Text(
                                'Tap to select location from map',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: kPrimaryRed,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.fromHeight(48.h),
                              side: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                            _isSaving ? null : () => _handleSubmit(),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(48.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              backgroundColor: kPrimaryRed,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              _isSaving ? 'Saving...' : 'Save Changes',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
