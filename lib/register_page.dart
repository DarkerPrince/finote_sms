import 'package:finote_sms/email_verification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> registerUser() async {
    setState(() { isLoading = true; errorMessage = null; });

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );

      User? user = userCred.user;

      await user?.sendEmailVerification();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(user: user!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
            ),

            SizedBox(height: 30),

            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: registerUser,
              child: Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
