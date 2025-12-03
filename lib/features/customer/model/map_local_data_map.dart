// map_address_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:workpleis/features/customer/screen/map.dart';

const kPrimaryRed = Color(0xFFC20001);
const kPrimaryRedDark = Color(0xFF9A0001);

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

/// use:
/// final picked = await showMapAddressPicker(context);
Future<LocationData?> showMapAddressPicker(
  BuildContext context, {
  LocationData? initialLocation,
}) {
  return Navigator.of(context).push<LocationData>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => MapAddressPickerScreen(initialLocation: initialLocation),
    ),
  );
}
