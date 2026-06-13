import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../../config/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/selected_vehicle_provider.dart';

class DestinationSearchScreen extends ConsumerStatefulWidget {
  const DestinationSearchScreen({ super.key });

  @override
  ConsumerState<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends ConsumerState<DestinationSearchScreen> {
  final Set<String> _selectedGoodsTypes = {};
  String? _pickupLocation;
  String? _dropoffLocation;
  List<double>? _pickupCoordinates;
  List<double>? _dropoffCoordinates;

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

  final List<Map<String, String>> _goodTypes = [
    {'asset': 'assets/images/furniture.png', 'label': 'Furniture'},
    {'asset': 'assets/images/packages.png', 'label': 'Packages'},
    {'asset': 'assets/images/electronics.png', 'label': 'Electronics'},
    {'asset': 'assets/images/construction.png', 'label': 'Construction'},
    {'asset': 'assets/images/others.png', 'label': 'Others'},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = ref.watch(selectedVehicleProvider);

    final canContinue =
        selectedVehicle != null &&
            _pickupLocation != null &&
            _dropoffLocation != null &&
            _selectedGoodsTypes.isNotEmpty;

    final mapTilerKey = dotenv.env['MAPTILER_API_KEY'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: 'https://api.maptiler.com/maps/bright/style.json?key=$mapTilerKey',
            initialCameraPosition: const CameraPosition(
              target: LatLng(27.7172, 85.3240), // Default to Kathmandu
              zoom: 14,
            ),
          ),

          Container(
            height: 100,
            color: Colors.white,
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 48,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Where to deliver?",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF2BA6D9),
                  child: Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.55,
            builder: (context, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _vehicles.map((v) {
                      // final bool isSelected = _selectedVehicle == v['type'];
                      final bool isSelected = selectedVehicle == v['type'];

                      return GestureDetector(
                        onTap: () {
                          // setState(() {
                          //   _selectedVehicle = v['type'];
                          // });
                          ref.read(selectedVehicleProvider.notifier).state = v['type'];
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.selectionHighlight
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    v['asset'],
                                    height: 59,
                                  ),
                                  Text(
                                    v['label'],
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
                              v['description'],
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
                  const SizedBox(height: 30),

                  // _buildInput("Enter Pick-up Location", Icons.location_on),
                  GestureDetector(
                    onTap: () async {
                      final result = await context.pushNamed(
                        RouteNames.locationSearch,
                        extra: _pickupLocation,
                      );

                      if (result != null) {
                        final place = result as Map;

                        setState(() {
                          _pickupLocation = place['text'];

                          _pickupCoordinates = [
                            place['center'][0],
                            place['center'][1],
                          ];
                        });
                      }
                    },
                    child: _buildInput(
                      _pickupLocation ?? "Enter Pick-up Location",
                      Icons.location_on,
                      isSelected: _pickupLocation != null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // _buildInput("Enter Delivery Destination", Icons.flag),
                  GestureDetector(
                    onTap: () async {
                      final result = await context.pushNamed(
                        RouteNames.locationSearch,
                        extra: _dropoffLocation,
                      );

                      if (result != null) {
                        final place = result as Map;

                        setState(() {
                          _dropoffLocation = place['text'];

                          _dropoffCoordinates = [
                            place['center'][0],
                            place['center'][1],
                          ];
                        });
                      }
                    },
                    child: _buildInput(
                      _dropoffLocation ?? "Enter Delivery Destination",
                      Icons.flag,
                      isSelected: _dropoffLocation != null,
                    ),
                  ),

                  const SizedBox(height: 45),
                  const Text(
                    "Good Types",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF132DB0),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: _goodTypes.length,
                    itemBuilder: (context, i) {
                      final isSelected =
                      _selectedGoodsTypes.contains(
                          _goodTypes[i]['label'],
                      );

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            final label = _goodTypes[i]['label']!;

                            if (_selectedGoodsTypes.contains(label)) {
                              _selectedGoodsTypes.remove(label);
                            } else {
                              _selectedGoodsTypes.add(label);
                            }
                          });
                        },
                        child: SizedBox(
                          width: 79.69,
                          height: 76.76,
                          child: Container(
                            decoration: BoxDecoration(
                              border: isSelected
                                  ? null
                                  : Border.all(
                                color: const Color(0xFFBCC1FF),
                                width: 1,
                              ),
                              color: isSelected
                                  ? const Color(0xFFA9D4FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9BACFF).withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  _goodTypes[i]['asset']!,
                                  height: 28,
                                ),

                                const SizedBox(height: 4),
                                Text(
                                  _goodTypes[i]['label']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13.9,
                                    color: Color(0xFF393939),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                  const Text("Recent History", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xFF132DB0))),

                  const SizedBox(height: 50),

                  Center(
                    child: SizedBox(
                      width: 250, // adjust
                      height: 56,
                      child: ElevatedButton(
                        onPressed: canContinue
                            ? () {
                          context.pushNamed(
                            RouteNames.bookingDetails,
                            extra: {
                              "pickupCoordinates": _pickupCoordinates,
                              "dropoffCoordinates": _dropoffCoordinates,

                              "pickupAddress": _pickupLocation,
                              "dropoffAddress": _dropoffLocation,

                              "goodsTypes": _selectedGoodsTypes.toList(),
                              "selectedVehicle": selectedVehicle,
                            },
                          );
                        }
                            : null,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: canContinue
                              ? const Color(0xFF132DB0)
                              : Colors.grey.shade300,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )
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


  Widget _buildInput(
      String text,
      IconData icon, {
        bool isSelected = false,
      }) =>
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF132DB0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF393939)
                        : const Color(0xFF8E8E8E),
                    fontSize: 17.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}