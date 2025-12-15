import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workpleis/features/customer/model/map_local_data_map.dart';
import 'package:workpleis/features/customer/screen/map.dart';
import 'package:workpleis/features/shared/profile_update_service.dart';
import 'package:workpleis/features/shared/location_update_service.dart';
import 'package:workpleis/features/shared/realtime_location_service.dart';
import 'package:easy_localization/easy_localization.dart';

/// ---------------- COLORS ----------------
const kDialogBg = Color(0xFFF4F4F4);
const kCardBg = Colors.white;
const kTextMain = Color(0xFF222222);
const kTextMuted = Color(0xFF9E9E9E);
const kPrimaryBlue = Color(0xFF2563EB);
const kBorderLight = Color(0xFFE5E5E5);
const kPrimaryRed = Color(0xFFE60000);

class LocationUpdatePopup extends StatefulWidget {
  const LocationUpdatePopup({super.key});

  @override
  State<LocationUpdatePopup> createState() => _LocationUpdatePopupState();
}

class _LocationUpdatePopupState extends State<LocationUpdatePopup>
    with WidgetsBindingObserver {
  bool _isLoadingLocation = true;
  bool _isUpdating = false;
  double? _currentLat;
  double? _currentLng;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When user returns from settings, check location again
    if (state == AppLifecycleState.resumed && _locationError != null) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'location_service_disabled'.tr();
        });
        // Automatically open location settings
        await _openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'location_permission_denied'.tr();
        });
        // Automatically open app settings for permission
        await _openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = '${'could_not_get_current_location'.tr()}: $e';
      });
    }
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
    // The lifecycle observer will handle retry when user returns from settings
    // Also retry after a delay as backup
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _getCurrentLocation();
    }
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
    // The lifecycle observer will handle retry when user returns from settings
    // Also retry after a delay as backup
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _getCurrentLocation();
    }
  }

  Future<void> _updateLocation(double lat, double lng) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Update profile location via PATCH /api/auth/profile
      await ProfileUpdateService.updateLocation(
        latitude: lat,
        longitude: lng,
      );

      // Update location via POST /api/location/update (without status)
      await LocationUpdateService.updateLocation(
        latitude: lat,
        longitude: lng,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('location_updated_successfully'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      // Start real-time location updates after successful update
      RealtimeLocationService().start();
      
      // Close popup after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340.w,
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(28.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ----------- TITLE -----------
            Text(
              "update_your_location".tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: kTextMain,
              ),
            ),
            SizedBox(height: 6.h),

            Text(
              "please_update_your_location_to_continue".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: kTextMuted,
              ),
            ),

            SizedBox(height: 28.h),

            // ----------- LOTTIE / ICON -----------
            Container(
              height: 100.w,
              width: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade50,
              ),
              child: Center(
                child: Icon(
                  Icons.location_on_rounded,
                  size: 48.sp,
                  color: Colors.blue.shade400,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              "your_location".tr(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: kTextMain,
              ),
            ),

            SizedBox(height: 24.h),

            // ----------- LOCATION CARD -----------
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      Icon(Icons.location_on, size: 18.sp, color: Colors.red),
                      SizedBox(width: 6.w),
                      Text(
                        "current_location".tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  if (_isLoadingLocation)
                    Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "getting_location".tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: kTextMuted,
                          ),
                        ),
                      ],
                    )
                  else if (_locationError != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _locationError!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () async {
                            final serviceEnabled =
                                await Geolocator.isLocationServiceEnabled();
                            if (!serviceEnabled) {
                              await _openLocationSettings();
                            } else {
                              final permission = await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied ||
                                  permission == LocationPermission.deniedForever) {
                                await _openAppSettings();
                              }
                            }
                          },
                          child: Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: kPrimaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.settings, size: 14.sp, color: kPrimaryBlue),
                                SizedBox(width: 4.w),
                                Text(
                                  'open_location_settings'.tr(),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: kPrimaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (_currentLat != null && _currentLng != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lat: ${_currentLat!.toStringAsFixed(6)}",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: kTextMain,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Lng: ${_currentLng!.toStringAsFixed(6)}",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: kTextMain,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      "location_not_available".tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: kTextMuted,
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ----------- SELECT FROM MAP BUTTON -----------
            if (_currentLat != null && _currentLng != null)
              GestureDetector(
                onTap: () async {
                  // Store current location and context before closing dialog
                  final lat = _currentLat!;
                  final lng = _currentLng!;
                  final navigator = Navigator.of(context, rootNavigator: true);
                  
                  // Close GPS popup first
                  navigator.pop();

                  // Wait a bit for dialog to close
                  await Future.delayed(const Duration(milliseconds: 300));

                  // Check if still mounted before navigating
                  if (!mounted) return;
                  
                  // Open map to verify/select location
                  final locationData = await navigator.push<LocationData>(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => MapAddressPickerScreen(
                        initialLocation: LocationData(
                          latitude: lat,
                          longitude: lng,
                          address: '',
                        ),
                      ),
                    ),
                  );

                  if (locationData != null && mounted) {
                    // Update location with selected coordinates
                    await _updateLocation(
                      locationData.latitude,
                      locationData.longitude,
                    );
                  }
                },
                child: Container(
                  height: 50.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kPrimaryBlue,
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "select_from_map".tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_currentLat != null && _currentLng != null) SizedBox(height: 12.h),

            // ----------- UPDATE BUTTON -----------
            GestureDetector(
              onTap: _isUpdating ||
                      _isLoadingLocation ||
                      _currentLat == null ||
                      _currentLng == null
                  ? null
                  : () async {
                      await _updateLocation(_currentLat!, _currentLng!);
                    },
              child: Container(
                height: 50.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: (_currentLat != null &&
                          _currentLng != null &&
                          !_isUpdating &&
                          !_isLoadingLocation)
                      ? kPrimaryBlue
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(26.r),
                ),
                child: _isUpdating
                    ? Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "update_location".tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 12.h),
            // ----------- SKIP BUTTON -----------
            TextButton(
              onPressed: _isUpdating ? null : () {
                context.pop();
              },
              child: Text(
                "skip_for_now".tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: kTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
