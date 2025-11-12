import 'package:finote_sms/logic/sms_event.dart';
import 'package:finote_sms/presentation/bulk_sms_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'logic/sms_bloc.dart';

void main() {
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
        home: BulkSmsPage(),
      ),
    );
  }
}
