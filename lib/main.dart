import 'package:finote_sms/logic/sms_event.dart';
import 'package:finote_sms/login_page.dart';
import 'package:finote_sms/presentation/AppColors.dart';
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // dark mode
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.primary.withOpacity(0.8),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
          ),
        ),
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
