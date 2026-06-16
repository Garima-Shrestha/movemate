import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'dart:async';
import '../../../../../config/routes/route_names.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/socket/socket_service.dart';
import '../view_model/booking_user_view_model.dart';

class DriverSearchingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;

  const DriverSearchingScreen({
    super.key,
    required this.bookingData,
  });


  @override
  ConsumerState<DriverSearchingScreen> createState() =>
      _DriverSearchingScreenState();
}

class _DriverSearchingScreenState extends ConsumerState<DriverSearchingScreen> {
  int remainingSeconds = 120;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _listenForDriverAccepted());

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          timer?.cancel();
        }
      },
    );
  }

  void _listenForDriverAccepted() {
    final socketService = ref.read(socketServiceProvider);
    socketService.off('bookingAccepted');
    socketService.on('bookingAccepted', (data) {
      if (!mounted) return;
      context.go(
        RouteNames.driverFound,
        extra: data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      );
    });

    socketService.off('bookingTimeout');
    socketService.on('bookingTimeout', (data) {
      if (!mounted) return;
      // Show timeout message and go back to home
      SnackbarUtils.showError(context, 'No driver found. Please try again.');
      context.go(RouteNames.userHome);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _showCancelDialog() {
    timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const SizedBox(height: 8),

                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFFF4A3D),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),


                // Image.asset(
                //   "assets/images/cancel.png",
                //   width: 52,
                //   height: 52,
                // ),

                const SizedBox(height: 24),

                const Text(
                  "Cancel Ride Request?",
                  style: TextStyle(
                    color: Color(0xFFFF4A3D),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "We're currently finding a driver for you.\nCancelling now will stop the search.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4D4D4D),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
                          side: const BorderSide(
                            color: Color(0xFFFF8A3D),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Continue Searching",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () async {
                          final bookingId = widget.bookingData['_id'];

                          if (bookingId != null) {
                            await ref
                                .read(bookingUserViewModelProvider.notifier)
                                .cancelBooking(bookingId);
                          }

                          if (mounted) {
                            Navigator.pop(context);
                            context.go(RouteNames.userHome);
                          }
                        },
                        child: const Text(
                          "Cancel Booking",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
      },
    ).then((_) {

      if (remainingSeconds > 0) {
        timer = Timer.periodic(
          const Duration(seconds: 1),
              (_) {
            if (remainingSeconds > 0) {
              setState(() {
                remainingSeconds--;
              });
            }
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.bookingData["vehicleType"];
    final goodsTypes = List<String>.from(widget.bookingData["goodsTypes"]);
    final String pickupAddress = widget.bookingData["pickupAddress"] ?? "";
    final String dropoffAddress = widget.bookingData["dropoffAddress"] ?? "";
    final double distance = (widget.bookingData["distance"] ?? 0).toDouble();
    final price = widget.bookingData["price"];
    final int etaMinutes = ((distance / 30) * 60).ceil();

    String vehicleImage = "";

    switch (vehicle) {
      case "tempo":
        vehicleImage = "assets/images/tempo.png";
        break;

      case "pickup":
        vehicleImage = "assets/images/pickup.png";
        break;

      case "truck":
        vehicleImage = "assets/images/truck.png";
        break;
    }

    return Scaffold(
      body: Stack(
        children: [

          MapLibreMap(
            styleString:
            'https://api.maptiler.com/maps/bright/style.json?key=${dotenv.env['MAPTILER_API_KEY']}',
            initialCameraPosition: const CameraPosition(
              target: LatLng(27.7172, 85.3240),
              zoom: 14,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 540,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(50),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              const Text(
                                "Finding your driver...",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                remainingSeconds > 0
                                    ? "Your request is being viewed by drivers."
                                    : "Still searching for drivers...",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF7B7B7B),
                                ),
                              )
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            "${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Color(0xFF2255E5),
                              fontWeight: FontWeight.w700,
                              fontSize: 19,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: remainingSeconds / 120,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFB2CBFF),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF3462E3),
                        ),
                      )
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: Transform.scale(
                        scaleX: 1.15,
                        child: Container(
                          height: 1,
                          color: const Color(0xFFB8B8B8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "ORDER SUMMARY",
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [

                        Image.asset(
                          vehicleImage,
                          width: 60,
                        ),

                        const SizedBox(width: 10),

                         Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Text(
                                vehicle.toString()[0].toUpperCase() +
                                    vehicle.toString().substring(1),
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000),
                                ),
                              ),

                          Text(goodsTypes.join(", "),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "NPR $price",
                          style: const TextStyle(
                            color: Color(0xFF2255E5),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEEF7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Column(
                            children: [

                              const SizedBox(height: 10),

                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF134AE9),
                                  shape: BoxShape.circle,
                                ),
                              ),

                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                width: 2,
                                height: 40,
                                color: const Color(0xFFB7B7B7),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF97316),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      const Text(
                                        "Pick-up",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF848484),
                                        ),
                                      ),

                                      Text(
                                        pickupAddress,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 19,
                                          color: Color(0xFF000000),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      const Text(
                                        "Drop-off",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF848484),
                                        ),
                                      ),

                                      Text(
                                        dropoffAddress,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 19,
                                          color: Color(0xFF000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 110),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${distance.toStringAsFixed(1)} km",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF565656),
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "~$etaMinutes min",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: SizedBox(
                        width: 322,
                        child: OutlinedButton(
                          onPressed: () {
                            _showCancelDialog();
                          },

                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8FAFC),

                            side: const BorderSide(
                              color: Color(0xFFACACAC),
                              width: 1,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),

                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),

                          child: const Text(
                            "Cancel Request",
                            style: TextStyle(
                              color: Color(0xFF828282),
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}