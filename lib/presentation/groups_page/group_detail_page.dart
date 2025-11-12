import 'package:finote_sms/data/contact_model.dart';
import 'package:finote_sms/logic/sms_bloc.dart';
import 'package:finote_sms/logic/sms_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'contact_detail_page.dart';

class GroupDetailPage extends StatelessWidget {
  final Group group;

  const GroupDetailPage({required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmsBloc, SmsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(group.name)),
          body: ListView.builder(
            itemCount: group.contacts.length,
            itemBuilder: (context, index) {
              final contact = group.contacts[index];
              final logs = state.sentLogsByContact[contact.phone] ?? [];

              return ListTile(
                title: Text(contact.name),
                subtitle: Text("${logs.length} messages sent"),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactDetailPage(group: group),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
