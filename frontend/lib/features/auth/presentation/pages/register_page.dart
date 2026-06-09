import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../state/auth_state.dart';
import '../view_model/auth_view_model.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final String role;

  const RegisterPage({super.key, required this.role});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 351,
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: suffixIcon,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFB0C4DE), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Registration failed. Please try again.',
        );
      } else if (next.status == AuthStatus.registered) {
        context.go( RouteNames.login, extra: 'user');
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

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
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 35),
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 33),
                        const Text(
                          'Create Your Account?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Create your account to explore\nexciting features',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 35),
                        SizedBox(
                          width: 351,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                label: 'Full Name',
                                hintText: 'Ram Thapa',
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.trim().length < 2) {
                                    return 'Username must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Email',
                                hintText: 'ramthapa123@email.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Invalid email address';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Phone Number',
                                hintText: '9800000000',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || !RegExp(r'^\d{10}$').hasMatch(value)) {
                                    return 'Phone number must be exactly 10 digits';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Password',
                                hintText: '*********',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.black26,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Confirm Password',
                                hintText: '*********',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.black26,
                                  ),
                                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 265,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                // Calls your viewmodel using the correct required parameters
                                await ref.read(authViewModelProvider.notifier).register(
                                  username: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  role: widget.role,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D3A8A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                                : const Text(
                              'Create Account',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Have an account? ',
                              style: TextStyle(color: Color(0xFF888888), fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () => context.go(RouteNames.login, extra: 'user'),
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(color: Color(0xFF1A68EE), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 25.0,
                left: 24.0,
                child: GestureDetector(
                  onTap: () => context.go(RouteNames.roleSelection),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}