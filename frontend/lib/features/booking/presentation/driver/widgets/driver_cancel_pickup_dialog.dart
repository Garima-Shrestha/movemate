import 'package:flutter/material.dart';

class DriverCancelPickupDialog extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const DriverCancelPickupDialog({
    super.key,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 6),

            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFFF4A3D),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Cancel Pickup Request?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFF4A3D),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "You've already accepted this request.\nCancelling now will notify other drivers.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF4D4D4D),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336),
                    ),
                    onPressed: onContinue,
                    child: const FittedBox(
                      child: Text(
                        "Continue Pickup",
                        style: TextStyle(
                          color: Colors.white,
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
                    onPressed: onCancel,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Cancel",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
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
  }
}