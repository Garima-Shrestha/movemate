import 'package:flutter/material.dart';
import 'dart:async';

class DriverBookingRequestCard extends StatefulWidget {
  final dynamic booking;

  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const DriverBookingRequestCard({
    super.key,
    required this.onAccept,
    required this.onDecline,
    required this.booking,
  });

  @override
  State<DriverBookingRequestCard> createState() =>
      _DriverBookingRequestCardState();
}
class _DriverBookingRequestCardState
    extends State<DriverBookingRequestCard> {

  int secondsLeft = 30;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
            if (secondsLeft > 0) {
              setState(() {
                secondsLeft--;
              });
            } else {
              timer.cancel();

              widget.onDecline();
            }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          // height: 295,
          margin: const EdgeInsets.only(
            top: 60,
            left: 12,
            right: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A33D6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "New Delivery Request",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Text(
                      "0:${secondsLeft.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        const Text(
                          "Pick-up",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF848484),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.booking['pickupAddress'] ?? 'Pickup Location',
                        style: const TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        const Text(
                          "Drop-off",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF848484),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.booking['dropAddress'] ?? 'Drop Location',
                        style: const TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.booking['goodsTypes'] != null
                                  ? (widget.booking['goodsTypes'] as List).join(', ')
                                  : '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "NRP${widget.booking['price'] ?? 0}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [

                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFBABABA),
                              ),
                            ),
                            onPressed: widget.onDecline,
                            child: Text(
                              "Decline",
                              style: TextStyle(
                                color: Color(0xFFBF0101),
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2255E5),
                              ),
                            onPressed: widget.onAccept,
                            child: Text(
                              "Accept",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
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
      ),
    );
  }
}