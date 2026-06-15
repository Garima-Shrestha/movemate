import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../../config/routes/route_names.dart';
import '../view_model/booking_user_view_model.dart';

class BookingDetailsPage extends ConsumerStatefulWidget {
  final List<double> pickupCoordinates;
  final List<double> dropoffCoordinates;

  final String pickupAddress;
  final String dropoffAddress;

  final List<String> goodsTypes;
  final String selectedVehicle;

  const BookingDetailsPage({
    super.key,
    required this.pickupCoordinates,
    required this.dropoffCoordinates,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.goodsTypes,
    required this.selectedVehicle,
  });

  @override
  ConsumerState<BookingDetailsPage> createState() =>
      _BookingDetailsPageState();
}

class _BookingDetailsPageState
    extends ConsumerState<BookingDetailsPage> {
  String? _selectedVehicle;

  @override
  void initState() {
    super.initState();

    _selectedVehicle = widget.selectedVehicle.toLowerCase();

    Future.microtask(() {
      ref
          .read(bookingUserViewModelProvider.notifier)
          .estimatePrice(
        pickupCoordinates:
        widget.pickupCoordinates,
        dropCoordinates:
        widget.dropoffCoordinates,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(bookingUserViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  MapLibreMap(
                    styleString:
                    'https://api.maptiler.com/maps/bright/style.json?key=${dotenv.env['MAPTILER_API_KEY']}',
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget.pickupCoordinates[1],
                        widget.pickupCoordinates[0],
                      ),
                      zoom: 14,
                    ),
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
              
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 18),

                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: const Text(
                        "Choose Vehicle",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 2),

                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: const Text(
                        "Select based on your load size",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888787),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 20),
              
                    _vehicleCard(
                      vehicle: "Tempo",
                      price: state.tempoPrice ?? 0,
                    ),
              
                    const SizedBox(height: 12),
              
                    _vehicleCard(
                      vehicle: "Pickup",
                      price: state.pickupPrice ?? 0,
                    ),
              
                    const SizedBox(height: 12),
              
                    _vehicleCard(
                      vehicle: "Truck",
                      price: state.truckPrice ?? 0,
                    ),
              
                    const SizedBox(height: 30),
              
                    Center(
                      child: SizedBox(
                        width: 238,
                        height: 59,
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref.read(
                              bookingUserViewModelProvider.notifier,
                            ).createBooking(
                              vehicleType: _selectedVehicle!,
                              pickupCoordinates: widget.pickupCoordinates,
                              dropCoordinates: widget.dropoffCoordinates,
                              goodsTypes: widget.goodsTypes
                                  .map((e) => e.toLowerCase())
                                  .toList(),
                              pickupAddress: widget.pickupAddress,
                              dropAddress: widget.dropoffAddress,
                            );

                            final booking =
                                ref.read(bookingUserViewModelProvider).activeBooking;

                            if (context.mounted && booking != null) {
                              context.pushNamed(
                                RouteNames.driverSearching,
                                extra: {
                                  "_id": booking.bookingId,

                                  "vehicleType": _selectedVehicle,
                                  "goodsTypes": widget.goodsTypes,

                                  "pickupCoordinates": widget.pickupCoordinates,
                                  "dropoffCoordinates": widget.dropoffCoordinates,

                                  "pickupAddress": widget.pickupAddress,
                                  "dropoffAddress": widget.dropoffAddress,

                                  "distance": state.estimatedDistance,

                                  "price": _selectedVehicle == "tempo"
                                      ? state.tempoPrice
                                      : _selectedVehicle == "pickup"
                                      ? state.pickupPrice
                                      : state.truckPrice,
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFFF97316),
                            elevation: 8,
                            shadowColor: const Color(0x40F97316),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),
                          child: const Text(
                            "Choose",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                              FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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

  Widget _vehicleCard({
    required String vehicle,
    required int price,
  }) {
    final selected = _selectedVehicle == vehicle.toLowerCase();

    String imagePath = '';

    switch (vehicle.toLowerCase()) {
      case 'tempo':
        imagePath = 'assets/images/tempo.png';
        break;
      case 'pickup':
        imagePath = 'assets/images/pickup.png';
        break;
      case 'truck':
        imagePath = 'assets/images/truck.png';
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicle =
              vehicle.toLowerCase();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEAF1FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(
            color: const Color(0xFF272BFF),
            width: 1,
          )
              : null,
          boxShadow: selected ? [
            BoxShadow(
              color: const Color(0xFF272BFF).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 55,
              height: 55,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    widget.goodsTypes.join(", "),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              "NPR $price",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}