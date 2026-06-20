import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../state/auth_state.dart';
import '../view_model/auth_view_model.dart';

class DriverRegisterPage extends ConsumerStatefulWidget {
  const DriverRegisterPage({super.key});

  @override
  ConsumerState<DriverRegisterPage> createState() =>
      _DriverRegisterPageState();
}

class _DriverRegisterPageState
    extends ConsumerState<DriverRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _vehicleModelController = TextEditingController();
  final _numberPlateController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _vehicleColorController = TextEditingController();


  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedVehicleType;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _vehicleModelController.dispose();
    _numberPlateController.dispose();
    _licenseNumberController.dispose();
    _vehicleColorController.dispose();

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
      padding: const EdgeInsets.only(bottom: 18),
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
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Colors.black26,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: suffixIcon,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFB0C4DE),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E3A8A),
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
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
          next.errorMessage ?? 'Registration failed',
        );
      }

      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(
          context,
          'Driver account created successfully',
        );

        context.go(RouteNames.login, extra: 'driver');
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading =
        authState.status == AuthStatus.loading;

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
                      children: [
                        const SizedBox(height: 35),

                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Start Driving & Earning',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Turn your vehicle into a steady\nsource of income.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 35),

                        SizedBox(
                          width: 351,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                label: 'Full Name',
                                hintText: 'Ram Thapa',
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 2) {
                                    return 'Username must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Email',
                                hintText:
                                'ramthapa123@email.com',
                                controller: _emailController,
                                keyboardType:
                                TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return 'Email is required';
                                  }

                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );

                                  if (!emailRegex
                                      .hasMatch(value)) {
                                    return 'Invalid email address';
                                  }

                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Phone Number',
                                hintText: '9800000000',
                                controller: _phoneController,
                                keyboardType:
                                TextInputType.phone,
                                validator: (value) {
                                  if (value == null ||
                                      !RegExp(r'^\d{10}$')
                                          .hasMatch(value)) {
                                    return 'Phone number must be exactly 10 digits';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Password',
                                hintText: '********',
                                controller:
                                _passwordController,
                                obscureText:
                                _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons
                                        .visibility_off_outlined
                                        : Icons
                                        .visibility_outlined,
                                    color: Colors.black26,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                      !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Confirm Password',
                                hintText: '********',
                                controller:
                                _confirmPasswordController,
                                obscureText:
                                _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons
                                        .visibility_off_outlined
                                        : Icons
                                        .visibility_outlined,
                                    color: Colors.black26,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value !=
                                      _passwordController
                                          .text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const Text(
                                'Vehicle Type',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: _vehicleTypeCard(
                                      title: 'Tempo',
                                      value: 'tempo',
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: _vehicleTypeCard(
                                      title: 'Pickup',
                                      value: 'pickup',
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: _vehicleTypeCard(
                                      title: 'Truck',
                                      value: 'truck',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              _buildTextField(
                                label: 'Vehicle Model',
                                hintText: 'Suzuki Carry',
                                controller:
                                _vehicleModelController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Vehicle model is required';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Vehicle Color',
                                hintText: 'White',
                                controller: _vehicleColorController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vehicle color is required';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Number Plate',
                                hintText: 'BA-01-PA-1234',
                                controller:
                                _numberPlateController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Number plate is required';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'License Number',
                                hintText: 'LIC123456',
                                controller:
                                _licenseNumberController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'License number is required';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: 265,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                              if (_selectedVehicleType == null) {
                                SnackbarUtils.showError(
                                  context,
                                  'Please select a vehicle type',
                                );
                                return;
                              }

                              if (_formKey.currentState!.validate()) {
                                await ref.read(authViewModelProvider.notifier,).register(
                                  username: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  role: 'driver',
                                  vehicleType: _selectedVehicleType!,
                                  vehicleModel: _vehicleModelController.text.trim(),
                                  vehicleColor: _vehicleColorController.text.trim(),
                                  numberPlate: _numberPlateController.text.trim(),
                                  licenseNumber: _licenseNumberController.text.trim(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF1D3A8A),
                              foregroundColor:
                              Colors.white,
                              elevation: 0,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child:
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight:
                                FontWeight.normal,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.go(
                                  RouteNames.login,
                                  extra: 'driver',
                                );
                              },
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Color(0xFF1A68EE),
                                  fontWeight:
                                  FontWeight.bold,
                                  fontSize: 16,
                                ),
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
                top: 25,
                left: 24,
                child: GestureDetector(
                  onTap: () => context.go(
                    RouteNames.roleSelection,
                  ),
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

  Widget _vehicleTypeCard({
    required String title,
    required String value,
  }) {
    final selected = _selectedVehicleType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = value;
        });
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF3F6FD9)
              : Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF5B8DEF)
                : const Color(0xFFD6E4FF),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF6D8FEF).withOpacity(0.20)
                  : Colors.black.withOpacity(0.04),
              blurRadius: selected ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}