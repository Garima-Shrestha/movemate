import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});


  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}


class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            children: [
              _buildPageOne(),
              _buildPageTwo(),
              _buildPageThree(),
            ],
          ),


          if (_currentPage < 2) // Only shows on Page 1 and 2
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, right: 5),
                  child: TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),


          // FIXED LOGO
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 93,
                ),
              ),
            ),
          ),


          // FIXED DOTS
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => _buildDot(index)),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // PAGE 1
  Widget _buildPageOne() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Image.asset(
            'assets/images/onboarding screen 1.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, 0.2),
          ),
        ),
        _buildTextOverlay(
          title: 'Move Anything,\nAnytime',
          description: 'Book trusted vehicles for shifting, delivery, or heavy transport in minutes.',
        ),
      ],
    );
  }


  // PAGE 2
  Widget _buildPageTwo() {
    return Stack(
      children: [
        // Replaced Column with a single Container to eliminate the gap
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // Adjust the 'stops' to match exactly where you want the color to flip
              stops: [0.4, 0.4],
              colors: [
                Color(0xFFB1D9FD), // Top Color
                Color(0xFFE9F3FD), // Bottom Color
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.10,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/onboarding screen 2.png',
            fit: BoxFit.contain,
          ),
        ),
        _buildTextOverlay(
          title: 'Choose. Book. Move.',
          titleSize: 35,
          description: 'Select your vehicle, set pickup & drop, and confirm your ride instantly.',
        ),
      ],
    );
  }


  // PAGE 3
  Widget _buildPageThree() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Image.asset(
            'assets/images/onboarding screen 3.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.6,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: const Color(0xFFF8FBFF),
          ),
        ),
        _buildTextOverlay(
          title: 'Move with Confidence',
          description: 'Real-time tracking, verified drivers, and transparent pricing.',
        ),
        // GET STARTED BUTTON
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(70, 0, 70, 100),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  context.go(RouteNames.roleSelection);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildTextOverlay({
    required String title,
    required String description,
    double titleSize = 36,
  }) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 220),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDot(int index) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? const Color(0xFF2B4C8C) : Colors.grey.shade300,
      ),
    );
  }
}
