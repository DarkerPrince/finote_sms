import 'package:finote_sms/logic/sms_event.dart';
import 'package:finote_sms/login_page.dart';
import 'package:finote_sms/presentation/bulk_sms_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'logic/sms_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmsBloc()..add(LoadGroupsEvent()),
      child: MaterialApp(
        title: 'Bulk SMS Manager',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
      ),
    );
  }
}

// This widget decides which page to show based on FirebaseAuth state
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Already signed in
      return BulkSmsPage();
    } else {
      // Not signed in
      return LoginPage();
    }
  }
}
