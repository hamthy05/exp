import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/authService.dart';
import '../../routes/app_routes.dart'; // 

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();

  String errorMsg = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    languageController.dispose();
    currencyController.dispose();
    super.dispose();
  }

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      isLogin ? _controller.reverse() : _controller.forward();
      errorMsg = "";
    });
  }

  Future<void> handleAuth() async {
    setState(() {
      errorMsg = "";
      isLoading = true;
    });
    if (isLogin) {
      final res = await AuthService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      setState(() => isLoading = false);
      if (res["error"] != null) {
        setState(() => errorMsg = res["error"]);
      } else {
        // ✅ Login success: Navigate to dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardHome);
      }
    } else {
      final res = await AuthService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
        phoneController.text.trim(),
        languageController.text.trim().isEmpty
            ? "en"
            : languageController.text.trim(),
        currencyController.text.trim().isEmpty
            ? "LKR"
            : currencyController.text.trim(),
      );
      setState(() => isLoading = false);
      if (res["error"] != null) {
        setState(() => errorMsg = res["error"]);
      } else {
        setState(() {
          isLogin = true;
          errorMsg = "Registration successful! Please login.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.indigoAccent;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _animation,
                  child: Text(
                    isLogin ? "Welcome Back!" : "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (errorMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      errorMsg,
                      style: TextStyle(
                        color: errorMsg.contains("successful")
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email, color: themeColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock, color: themeColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                if (!isLogin) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: "Phone",
                      prefixIcon: Icon(Icons.phone, color: themeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: languageController,
                    decoration: InputDecoration(
                      labelText: "Language",
                      prefixIcon: Icon(Icons.language, color: themeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: currencyController,
                    decoration: InputDecoration(
                      labelText: "Currency",
                      prefixIcon: Icon(Icons.attach_money, color: themeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : handleAuth,
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isLogin ? "Login" : "Register",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isLoading ? null : toggleForm,
                  child: Text(
                    isLogin
                        ? "Don't have an account? Register"
                        : "Already have an account? Login",
                    style: GoogleFonts.poppins(color: themeColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
