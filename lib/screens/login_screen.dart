
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'onboarding_screen.dart';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final auth = AuthService();
  final firestore = FirestoreService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resume Builder"),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome Back",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              "Build your amazing resume",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.email),
              ),
              enabled: !isLoading,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passController,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Enter your password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              enabled: !isLoading,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _handleLogin(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "Sign In",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => _showRegisterDialog(),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
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

  void _handleLogin() async {
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);
    try {
      var user = await auth.login(emailController.text, passController.text);
      if (user != null) {
        var profile = await firestore.getUser(user.uid);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => profile == null
                ? OnboardingScreen()
                : ProfileScreen(),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showRegisterDialog() {
    final regEmailController = TextEditingController();
    final regPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: regEmailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: regPassController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => _handleRegister(
              regEmailController.text,
              regPassController.text,
              context,
            ),
            child: Text("Sign Up"),
          ),
        ],
      ),
    );
  }

  void _handleRegister(String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    try {
      var user = await auth.register(email, password);
      if (user != null) {
        Navigator.pop(context);
        _showError("Account created! Please login");
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }
}
