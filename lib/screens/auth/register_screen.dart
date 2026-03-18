import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final AuthService authService = AuthService.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreeTerms = false;

  // Exact LibriTrack Design Palette
  static const Color brandOrange = Color(0xFFF15A24); 
  static const Color leftPanelBg = Color(0xFFFDF1E9);
  static const Color textMain = Color(0xFF111827);
  static const Color textSub = Color(0xFF4B5563);
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color screenBg = Color(0xFFF9FAFB);

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // CONSTRAINT: Checkbox must be clicked to proceed
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Privacy Policy to create an account.'),
          backgroundColor: brandOrange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await authService.registerWithEmailPassword(
        name: name.text.trim(),
        email: email.text.trim(),
        password: password.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Custom Header ---
              _buildHeader(context),

              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  constraints: const BoxConstraints(maxWidth: 1100),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- LEFT PANEL (Design Side) ---
                        if (screenWidth > 850)
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: leftPanelBg,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),
                                // Light Black Book Watermark Fix
                                Positioned(
                                  top: -30,
                                  right: -50,
                                  child: Transform.rotate(
                                    angle: -0.2,
                                    child: const Icon(
                                      Icons.menu_book_rounded,
                                      size: 380,
                                      color: Colors.black12, // Same as login
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
                                        "Start Your Reading Journey",
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                          color: textMain,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        "Join thousands of book enthusiasts tracking their progress, discovering new titles, and building their digital libraries.",
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
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Create Account", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: textMain)),
                                  const SizedBox(height: 10),
                                  const Text("Fill in your details to get started with LibriTrack.", style: TextStyle(fontSize: 15, color: textSub)),
                                  const SizedBox(height: 40),

                                  _buildFieldLabel("Full Name"),
                                  _buildTextField(
                                    controller: name,
                                    hint: "John Doe",
                                    icon: Icons.person_outline,
                                    validator: Validators.name,
                                  ),
                                  const SizedBox(height: 24),

                                  _buildFieldLabel("Email Address"),
                                  _buildTextField(
                                    controller: email,
                                    hint: "name@example.com",
                                    icon: Icons.email_outlined,
                                    validator: Validators.email,
                                  ),
                                  const SizedBox(height: 24),

                                  _buildFieldLabel("Password"),
                                  _buildTextField(
                                    controller: password,
                                    hint: "••••••",
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
                                          value: _agreeTerms,
                                          activeColor: brandOrange,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          onChanged: (v) => setState(() => _agreeTerms = v!),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: RichText(
                                          text: const TextSpan(
                                            text: "I agree to the ",
                                            style: TextStyle(color: textSub, fontSize: 13),
                                            children: [
                                              TextSpan(text: "Terms of Service", style: TextStyle(color: brandOrange, fontWeight: FontWeight.bold)),
                                              TextSpan(text: " and "),
                                              TextSpan(text: "Privacy Policy", style: TextStyle(color: brandOrange, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: brandOrange,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                                                SizedBox(width: 8),
                                                Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                                              ],
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),
                                  const Center(child: Text("ALREADY A MEMBER?", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1))),
                                  const SizedBox(height: 16),
                                  
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: inputBorder),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text("Sign In to Your Account", style: TextStyle(color: textMain, fontWeight: FontWeight.w600)),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: brandOrange, size: 30),
          const SizedBox(width: 10),
          const Text("LibriTrack", style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 20)),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: brandOrange, 
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
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
            decoration: BoxDecoration(color: brandOrange.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: brandOrange, size: 16),
          ),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textSub)),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textMain)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    required String? Function(String?) validator,
  }) {
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
        fillColor: screenBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: inputBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: inputBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: brandOrange, width: 1.5)),
      ),
    );
  }
}