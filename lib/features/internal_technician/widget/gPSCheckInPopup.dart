import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workpleis/features/customer/model/map_local_data_map.dart';
import 'package:workpleis/features/customer/screen/map.dart';

import 'package:easy_localization/easy_localization.dart';

/// ---------------- COLORS ----------------
const kDialogBg = Color(0xFFF4F4F4);
const kCardBg = Colors.white;
const kTextMain = Color(0xFF222222);
const kTextMuted = Color(0xFF9E9E9E);
const kPrimaryBlue = Color(0xFF2563EB);
const kBorderLight = Color(0xFFE5E5E5);
const kPrimaryRed = Color(0xFFE60000);

class Gpscheckinpopup extends StatefulWidget {
  final String? jobAddress;
  final Function(double lat, double lng)? onLocationVerified;

  const Gpscheckinpopup({
    super.key,
    this.jobAddress,
    this.onLocationVerified,
  });

  @override
  State<Gpscheckinpopup> createState() => _GpscheckinpopupState();
}

class _GpscheckinpopupState extends State<Gpscheckinpopup> {
  bool _isLoadingLocation = true;
  double? _currentLat;
  double? _currentLng;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
          _locationError = 'Location service disabled';
        });
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
          _locationError = 'Location permission denied';
        });
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
        _locationError = 'Could not get location: $e';
      });
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
              "gps_check_equired".tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: kTextMain,
              ),
            ),
            SizedBox(height: 6.h),

            Text(
              "verify_your_location_at_job_site_start_working".tr(),
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
                  Icons.navigation_rounded,    // <-- replace with Lottie later
                  size: 48.sp,
                  color: Colors.blue.shade400,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              "job_location".tr(),
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
                        "your_location".tr(),
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
                    Text(
                      _locationError!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red,
                      ),
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

            // ----------- VERIFY BUTTON -----------
            GestureDetector(
              onTap: () async {
                // Close GPS popup first
                context.pop();
                
                // Open map to verify/select location
                if (widget.onLocationVerified != null) {
                  final locationData = await Navigator.push<LocationData>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapAddressPickerScreen(
                        initialLocation: (_currentLat != null && _currentLng != null)
                            ? LocationData(
                                latitude: _currentLat!,
                                longitude: _currentLng!,
                                address: widget.jobAddress ?? '',
                              )
                            : null,
                      ),
                    ),
                  );
                  
                  if (locationData != null) {
                    widget.onLocationVerified!(locationData.latitude, locationData.longitude);
                  }
                }
              },
              child: Container(
                height: 50.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: (_currentLat != null && _currentLng != null) 
                      ? kPrimaryBlue 
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(26.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "accept_location".tr(),
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
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
