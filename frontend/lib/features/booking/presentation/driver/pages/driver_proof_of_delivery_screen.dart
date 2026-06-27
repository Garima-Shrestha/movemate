import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../config/routes/route_names.dart';
import '../view_model/driver_booking_view_model.dart';

class DriverProofOfDeliveryScreen
    extends ConsumerStatefulWidget {

  final Map<String, dynamic> bookingData;

  const DriverProofOfDeliveryScreen({
    super.key,
    required this.bookingData,
  });

  @override
  ConsumerState<DriverProofOfDeliveryScreen>
  createState() =>
      _DriverProofOfDeliveryScreenState();
}

class _DriverProofOfDeliveryScreenState
    extends ConsumerState<
        DriverProofOfDeliveryScreen> {

  File? imageFile;

  @override
  void initState() {
    super.initState();
    Future.microtask(_captureImage);
  }

  Future<void> _captureImage() async {
    final image =
    await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) {
      if (mounted) {
        context.pop();
      }
      return;
    }

    setState(() {
      imageFile = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {

    if (imageFile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proof of Delivery',
        ),
      ),
      body: Column(
        children: [

          Expanded(
            child: Image.file(
              imageFile!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: _captureImage,
                    child: const Text(
                      'Retake',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final bookingId = widget.bookingData['bookingId'];
                      await ref.read(driverBookingViewModelProvider.notifier)
                          .completeTripWithProof(bookingId, imageFile!.path,);

                      if (mounted) {
                        context.go(
                          RouteNames.driverBookings,
                        );
                      }
                    },
                    child: const Text(
                      'Confirm',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}