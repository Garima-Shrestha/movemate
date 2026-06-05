import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';


class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});


  @override
  Widget build(BuildContext context) {
    // This is the specific blue you wanted for the bottom section
    const Color bottomMatchColor = Color(0xFFA6CAFD);
    // The top light background color
    const Color topBackgroundColor = Color(0xFFF3F5FD);


    return Scaffold(
      // Setting the background to your color hides the system gap
      backgroundColor: bottomMatchColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: topBackgroundColor,
            ),
          ),


          // 2. Background Image
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Image.asset(
                'assets/images/role_selection_illustration.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),


          // 3. UI CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 70),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                  ),
                ),


                const SizedBox(height: 50),


                // Left-Aligned Heading
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How do you want to use\nthe app?',
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Choose your role to get started',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),


                const Spacer(),


                // Buttons positioned exactly like your design
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            // PASSING 'user' SILENTLY AS EXTRA DATA
                            context.go(RouteNames.register, extra: 'user');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A), // Theme blue
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Book a Vehicle',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 53,
                        child: OutlinedButton(
                            onPressed: () {
                              context.go(RouteNames.driverRegister, extra: 'driver');
                            },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.8),
                            // Updated background color to match the desired blue for transparency effect
                            backgroundColor: bottomMatchColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Drive & Earn',
                            style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom padding to clear the home indicator bar
                const SizedBox(height: 110),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
