import 'package:finote_sms/email_verification_page.dart';
import 'package:finote_sms/presentation/bulk_sms_page.dart';
import 'package:finote_sms/forgot_password_page.dart';
import 'package:finote_sms/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPagePrev extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPagePrev> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );

      User? user = userCred.user;

      // CHECK IF NOT VERIFIED
      if (user != null && !user.emailVerified) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EmailVerificationPage(user: user)),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BulkSmsPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() { isLoading = true; errorMessage = null; });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BulkSmsPage()),
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("FinoteSMS Login",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

                if (errorMessage != null)
                  Text(errorMessage!, style: TextStyle(color: Colors.red)),

                SizedBox(height: 20),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      labelText: "Email", border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Password", border: OutlineInputBorder()),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text("Forgot Password?"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                isLoading
                    ? CircularProgressIndicator()
                    : Column(
                  children: [
                    ElevatedButton(
                        onPressed: loginUser, child: Text("Login")),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(" Dont have an Account? "),
                        OutlinedButton(
                          child: Text("Create New"),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => RegisterPage()
                            ),
                          ),
                        ),
                      ],),


                    Divider(height: 40),

                    ElevatedButton(
                      onPressed: signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Google button is usually white
                        elevation: 2,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300), // light border
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'http://pngimg.com/uploads/google/google_PNG19635.png',
                            height: 24,
                            width: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Sign in with Google",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )

                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
