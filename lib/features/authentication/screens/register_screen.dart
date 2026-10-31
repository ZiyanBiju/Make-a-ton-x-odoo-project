import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  static const Color navy = Color(0xFF151A35);
  static const Color purple = Color(0xFF7657F6);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void register() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful! API integration is next.'),
        backgroundColor: Color(0xFF269B79),
      ),
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: purple, size: 21),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F8FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE9E7F1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: purple, width: 1.5),
      ),
    );
  }

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: navy,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withValues(alpha: 0.22),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -90,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38CFA3).withValues(alpha: 0.10),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Branding
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF987CFF),
                              Color(0xFF6845E8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: const Icon(
                          Icons.all_inclusive_rounded,
                          color: Colors.white,
                          size: 37,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'BrightLoop',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'YOUR SUBSCRIPTION JOURNEY STARTS HERE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFB9B9D0),
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Registration card
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  color: navy,
                                ),
                              ),

                              const SizedBox(height: 7),

                              const Text(
                                'Join BrightLoop and manage your subscriptions smarter.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 25),

                              fieldLabel('Full Name'),

                              TextFormField(
                                controller: nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: inputDecoration(
                                  hint: 'Enter your full name',
                                  icon: Icons.person_outline,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 19),

                              fieldLabel('Email Address'),

                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: inputDecoration(
                                  hint: 'Enter your email address',
                                  icon: Icons.email_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }

                                  if (!RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(value.trim())) {
                                    return 'Enter a valid email address';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 19),

                              fieldLabel('Password'),

                              TextFormField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                decoration: inputDecoration(
                                  hint: 'Create a strong password',
                                  icon: Icons.lock_outline,
                                  suffix: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }

                                  if (value.length <= 8 ||
                                      !RegExp(r'[A-Z]').hasMatch(value) ||
                                      !RegExp(r'[a-z]').hasMatch(value) ||
                                      !RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
                                    return 'Use more than 8 characters, uppercase, lowercase and a special character';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 19),

                              fieldLabel('Confirm Password'),

                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: obscureConfirmPassword,
                                decoration: inputDecoration(
                                  hint: 'Re-enter your password',
                                  icon: Icons.lock_reset_outlined,
                                  suffix: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscureConfirmPassword =
                                            !obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }

                                  if (value != passwordController.text) {
                                    return 'Passwords do not match';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 27),

                              // Gradient registration button
                              Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF896BFF),
                                      Color(0xFF6845E8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: purple.withValues(alpha: 0.3),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create My Account',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_forward_rounded),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              const Text(
                                'By creating an account, you agree to our Terms & Conditions.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        '© 2026 BrightLoop. All rights reserved.',
                        style: TextStyle(
                          color: Color(0xFFAAAAC2),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

