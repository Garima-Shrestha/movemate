import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../config/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../view_model/booking_user_view_model.dart';
import '../view_model/selected_vehicle_provider.dart';
import '../../../../../core/services/socket/socket_service.dart';
import '../../../../../core/services/storage/user_session_service.dart';
import '../view_model/booking_user_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedVehicle;
  MapLibreMapController? _mapController;
  Symbol? _driverSymbol;
  LatLng _userLocation = const LatLng(27.7172, 85.3240);

  final List<Map<String, dynamic>> _vehicles = [
    {
      'type': 'tempo',
      'asset': 'assets/images/tempo.png',
      'label': 'Tempo',
      'description': 'Small /\nMedium Items',
    },
    {
      'type': 'pickup',
      'asset': 'assets/images/pickup.png',
      'label': 'Pickup',
      'description': 'Medium /\nLarge Items',
    },
    {
      'type': 'truck',
      'asset': 'assets/images/truck.png',
      'label': 'Truck',
      'description': 'Large /\nBulk Items',
    },
  ];

  void _connectUserSocket() {
    final session = ref.read(userSessionServiceProvider);

    final userId = session.getCurrentUserId();

    if (userId == null) return;

    final socketService = ref.read(socketServiceProvider);

    if (!socketService.isConnected) {
      socketService.connect(userId, "user");
    }
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
    _connectUserSocket();

    Future.microtask(() {
      ref
          .read(bookingUserViewModelProvider.notifier)
          .getMyBookingsHistory();
    });
  }


  Future<void> _initLocation() async {
    // check if location service is enabled first
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return; // just show default Kathmandu, no crash

    final status = await Permission.location.request();
    if (!status.isGranted) return;

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_userLocation, 14),
    );
  }

  // called every time the socket sends a new driver location
  Future<void> _updateDriverMarker(LatLng newLocation) async {
    if (_mapController == null) return;

    if (_driverSymbol == null) {
      // first time
      _driverSymbol = await _mapController!.addSymbol(
        SymbolOptions(
          geometry: newLocation,
          iconSize: 1.5,
          iconOffset: const Offset(0, 0),
          textField: 'Driver',
          textSize: 12,
          textOffset: const Offset(0, 2),
          textColor: '#264987',
        ),
      );
    } else {
      await _mapController!.updateSymbol(
        _driverSymbol!,
        SymbolOptions(geometry: newLocation),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapTilerKey = dotenv.env['MAPTILER_API_KEY'] ?? '';

    final history = ref.watch(
      bookingUserViewModelProvider.select(
            (s) => s.bookingsHistory,
      ),
    );

    final recentHistory = history.take(2).toList();

    // whenever socket pushes a new driver location, this runs
    ref.listen(
      bookingUserViewModelProvider.select((s) => s.driverLocation),
          (previous, next) {
        if (next != null) {
          _updateDriverMarker(LatLng(next[0], next[1]));
        }
      },
    );

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString:
            'https://api.maptiler.com/maps/streets-v2/style.json?key=$mapTilerKey',
            initialCameraPosition: CameraPosition(
              target: _userLocation,
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.tracking,
            compassEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_userLocation, 14),
              );
            },
            onMapClick: (point, latLng) {},
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _vehicles.map((v) {
                      final selectedVehicle = ref.watch(selectedVehicleProvider);

                      final bool isSelected = selectedVehicle == v['type'];

                      // final bool isSelected = _selectedVehicle == v['type'];
                      return GestureDetector(
                        onTap: () =>
                            // setState(() => _selectedVehicle = v['type']),
                        ref.read(selectedVehicleProvider.notifier).state = v['type'],
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.selectionHighlight
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    v['asset'] as String,
                                    height: 59,
                                    fit: BoxFit.contain,
                                  ),
                                  // const SizedBox(height: 1),
                                  Text(
                                    v['label'] as String,
                                    style: const TextStyle(
                                      color: AppColors.vehicleText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              v['description'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.itemDescription,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  GestureDetector(
                    onTap: () {
                      // context.pushNamed(RouteNames.destinationSearch);
                      context.pushNamed(
                        RouteNames.destinationSearch,
                        // extra: _selectedVehicle,
                        extra: ref.read(selectedVehicleProvider),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7FF),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8E8E8E).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Color(0xFF6B7280), size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Where to',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...recentHistory.map(
                        (b) => ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(
                            vertical: -3,
                          ),
                          minVerticalPadding: 0,
                      leading: const Icon(
                        Icons.history,
                        color: Colors.grey,
                      ),
                      title: Text(
                        b.dropAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        b.pickupAddress,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}