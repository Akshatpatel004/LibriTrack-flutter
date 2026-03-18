import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService.instance;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    // Constraint: Checkbox must be clicked to proceed
    if (!_rememberMe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check "Keep me logged in" to proceed.'),
          backgroundColor: Color(0xffF15A24),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await authService.signInWithEmailPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await authService.signInWithGoogle();
      if (!mounted) return;
      if (result != null) Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xffF15A24);
    const bgLight = Color(0xffF9FAFB);
    const peachBg = Color(0xffFDF1E9);
    const textHeadline = Color(0xff111827);
    const textSub = Color(0xff4B5563);
    const borderColor = Color(0xffE5E7EB);

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: primaryOrange, size: 30),
                    const SizedBox(width: 10),
                    const Text(
                      'LibriTrack',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textHeadline),
                    ),
                    const Spacer(),
                    const Text("Don't have an account?", style: TextStyle(fontSize: 14, color: textSub)),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Sign Up', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // --- Main Container ---
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 1100),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 40, offset: const Offset(0, 10))
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- LEFT PANEL (Design Side) ---
                        if (MediaQuery.of(context).size.width > 850)
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: peachBg,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                                  ),
                                ),
                                // Faded Light Black Book Icon Watermark
                                Positioned(
                                  top: -30,
                                  right: -50,
                                  child: Transform.rotate(
                                    angle: -0.2,
                                    child: const Icon(
                                      Icons.menu_book_rounded,
                                      size: 380,
                                      color: Colors.black12, // Light black/grey color
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(60),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Master your personal library.',
                                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: textHeadline, height: 1.1),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Track your reading progress, organize your collection, and discover your next favorite book with LibriTrack.',
                                        style: TextStyle(fontSize: 16, color: textSub, height: 1.6),
                                      ),
                                      const SizedBox(height: 48),
                                      _buildFeatureRow('Catalog thousands of books'),
                                      _buildFeatureRow('Detailed reading statistics'),
                                      _buildFeatureRow('Cloud synchronization'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // --- RIGHT PANEL (Form Side) ---
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 70),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Welcome Back', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: textHeadline)),
                                  const SizedBox(height: 10),
                                  const Text('Please enter your details to sign in.', style: TextStyle(fontSize: 16, color: textSub)),
                                  const SizedBox(height: 48),
                                  
                                  const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textHeadline)),
                                  const SizedBox(height: 10),
                                  _buildTextField(
                                    controller: email,
                                    hint: 'you@example.com',
                                    icon: Icons.email_outlined,
                                    validator: Validators.email,
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textHeadline)),
                                      GestureDetector(
                                        onTap: () {},
                                        child: const Text('Forgot password?', style: TextStyle(fontSize: 13, color: primaryOrange, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildTextField(
                                    controller: password,
                                    hint: '••••••',
                                    icon: Icons.lock_outline,
                                    obscure: _obscurePassword,
                                    validator: Validators.password,
                                    suffix: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: textSub),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24, width: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: primaryOrange,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          onChanged: (v) => setState(() => _rememberMe = v!),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('Keep me logged in for 30 days', style: TextStyle(fontSize: 14, color: textSub)),
                                    ],
                                  ),

                                  const SizedBox(height: 40),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleEmailLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryOrange,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: _isLoading 
                                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                        : const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                  ),

                                  const SizedBox(height: 32),
                                  const Row(
                                    children: [
                                      Expanded(child: Divider(color: borderColor)),
                                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Or continue with', style: TextStyle(fontSize: 12, color: Colors.grey))),
                                      Expanded(child: Divider(color: borderColor)),
                                    ],
                                  ),

                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: OutlinedButton.icon(
                                      onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                                      icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png', height: 22),
                                      label: const Text('Login with Google', style: TextStyle(color: textHeadline, fontWeight: FontWeight.w600, fontSize: 15)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: borderColor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('© 2024 LibriTrack Book Management System. All rights reserved.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xffF15A24).withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Color(0xffF15A24), size: 16),
          ),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff4B5563))),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool obscure = false, Widget? suffix, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xffF9FAFB),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5)),
      ),
    );
  }
}