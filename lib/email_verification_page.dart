import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finote_sms/presentation/bulk_sms_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final User user;

  EmailVerificationPage({required this.user});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? timer;
  bool emailVerified = false;

  @override
  void initState() {
    super.initState();

    // start checking every 3 seconds
    timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
  }

  Future<void> checkEmailVerified() async {
    await widget.user.reload();
    var refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null && refreshedUser.emailVerified) {
      timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BulkSmsPage()),
      );
    }
  }

  Future<void> resendVerification() async {
    await widget.user.sendEmailVerification();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Verification email sent again")),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify your email")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                "A verification link has been sent to:",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                widget.user.email!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: resendVerification,
                child: Text("Resend Verification Email"),
              ),
              SizedBox(height: 20),
              Text(
                "Waiting for email verification...",
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
