import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../model/map_local_data_map.dart';

class MapAddressPickerScreen extends StatefulWidget {
  const MapAddressPickerScreen({super.key, this.initialLocation});
  static const String routeName = '/map-address-picker';

  final LocationData? initialLocation;

  @override
  State<MapAddressPickerScreen> createState() => _MapAddressPickerScreenState();
}

class _MapAddressPickerScreenState extends State<MapAddressPickerScreen> {
  GoogleMapController? _mapController;
  late LocationData _selected;
  bool _isDragging = false;
  bool _gpsAvailable = true;
  double _zoom = 15;

  final TextEditingController _searchController = TextEditingController();

  // Nouakchott default

  static const LatLng _defaultLatLng = LatLng(18.0735, -15.9582);

  @override
  void initState() {
    super.initState();

    final initial = widget.initialLocation;
    _selected =
        initial ??
        LocationData(
          latitude: _defaultLatLng.latitude,
          longitude: _defaultLatLng.longitude,
          address: 'Nouakchott, Mauritania',
          placeName: 'Nouakchott',
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  LatLng get _selectedLatLng => LatLng(_selected.latitude, _selected.longitude);

  // ----------------------------------------------------------------------
  //  handlers
  // ----------------------------------------------------------------------

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _isDragging = true;
    setState(() {
      _zoom = position.zoom;
    });
  }

  void _onCameraIdle() async {
    if (_mapController == null) return;
    final center = await _mapController!.getLatLng(
      const ScreenCoordinate(x: 200, y: 400), // center-ish
    );

    setState(() {
      _isDragging = false;
      _selected = LocationData(
        latitude: center.latitude,
        longitude: center.longitude,
        address:
            '${center.latitude.toStringAsFixed(6)}, ${center.longitude.toStringAsFixed(6)}',
        placeName: _selected.placeName ?? 'Selected Location',
      );
    });

    // TODO: ekhane reverse-geocoding (geocoding package / Places API) korte paro
  }

  Future<void> _zoomIn() async {
    if (_mapController == null) return;
    final double newZoom = (_zoom + 1).clamp(3.0, 20.0) as double;
    await _mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
    setState(() => _zoom = newZoom);
  }

  Future<void> _zoomOut() async {
    if (_mapController == null) return;
    final double newZoom = (_zoom - 1).clamp(3.0, 20.0) as double;
    await _mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
    setState(() => _zoom = newZoom);
  }
  //
  // Future<void> _zoomOut() async {
  //   if (_mapController == null) return;
  //   final newZoom = (_zoom - 1).clamp(3, 20);
  //   await _mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
  //   setState(() => _zoom = newZoom);
  // }

  Future<void> _goToCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location service disabled')),
        );
        setState(() => _gpsAvailable = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied, use search instead'),
          ),
        );
        setState(() => _gpsAvailable = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );

      setState(() {
        _gpsAvailable = true;
        _selected = LocationData(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          address:
              '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}',
          placeName: 'Your location',
        );
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get current location')),
      );
      setState(() => _gpsAvailable = false);
    }
  }

  Future<void> _handleSearch() async {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return;

    // very simple demo search – tui pore Google Places / geocoding add korte parbi
    LatLng? result;
    String? label;
    if (q.contains('nouakchott')) {
      result = _defaultLatLng;
      label = 'Nouakchott';
    }

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not found (try: Nouakchott)')),
      );
      return;
    }

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: result, zoom: 16)),
    );
    setState(() {
      _selected = LocationData(
        latitude: result!.latitude,
        longitude: result.longitude,
        address: '$label, Mauritania',
        placeName: label,
      );
    });
  }

  void _confirm() {
    Navigator.of(context).pop<LocationData>(_selected);
  }

  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_selected.placeName != null) _buildSelectedCard(),
            Expanded(child: _buildMapArea()),
            _buildConfirmBar(),
          ],
        ),
      ),
    );
  }

  // ---------------- UI parts ----------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _handleSearch(),
              decoration: InputDecoration(
                hintText: _gpsAvailable
                    ? 'Search for your address or landmark'
                    : 'Search e.g. Nouakchott',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() {
                          _searchController.clear();
                        }),
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _gpsAvailable
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFFFFB111),
                    width: _gpsAvailable ? 1 : 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: kPrimaryRed, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selected.placeName ?? 'Selected location',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selected.address,
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
    );
  }

  Widget _buildMapArea() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _selectedLatLng,
            zoom: _zoom,
          ),
          onMapCreated: _onMapCreated,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
        ),

        // instruction bubble
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _gpsAvailable
                    ? Colors.black.withOpacity(0.8)
                    : const Color(0xFFFFB111),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _gpsAvailable
                    ? 'Drag the map to position the pin'
                    : 'GPS unavailable • use search or drag map',
                style: TextStyle(
                  fontSize: 12,
                  color: _gpsAvailable ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),

        // center pin
        IgnorePointer(
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 120),
              scale: _isDragging ? 1.05 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 40, color: kPrimaryRed),
                  Container(
                    width: 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // zoom buttons
        Positioned(
          right: 16,
          top: 80,
          child: Column(
            children: [
              _roundIconButton(icon: Icons.add, onTap: _zoomIn),
              const SizedBox(height: 8),
              _roundIconButton(icon: Icons.remove, onTap: _zoomOut),
            ],
          ),
        ),

        // current-location button
        Positioned(
          right: 16,
          bottom: 24,
          child: _roundIconButton(
            icon: Icons.navigation_rounded,
            enabled: _gpsAvailable,
            onTap: _goToCurrentLocation,
          ),
        ),
      ],
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: enabled ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child:  Text(
            'confirm'.tr(),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
