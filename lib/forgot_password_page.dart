import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? message;

  Future<void> resetPassword() async {
    setState(() { isLoading = true; message = null; });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      setState(() {
        message = "Password reset link sent! Check your email.";
      });
    } on FirebaseAuthException catch (e) {
      setState(() { message = e.message; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "Enter your email to reset your password.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: resetPassword,
              child: Text("Send Reset Link"),
            ),

            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(message!,
                    style: TextStyle(color: Colors.blueAccent)),
              ),
          ],
        ),
      ),
    );
  }
}
