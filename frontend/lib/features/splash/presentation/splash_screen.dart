import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage/user_session_service.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );


    _controller.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final userSession = ref.read(userSessionServiceProvider);
    if (userSession.isLoggedIn()) {
      final role = userSession.getCurrentUserRole();
      if (role == 'driver') {
        context.go(RouteNames.driverHome);
      } else {
        context.go(RouteNames.userHome);
      }
    } else {
      context.go(RouteNames.onboarding);
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFC2D7FD),
              Color(0xFFCAEBFE),
              Color(0xFFE7F8FF),
              Color(0xFFE8F9FF),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
