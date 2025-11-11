import 'package:finote_sms/data/contact_model.dart';
import 'package:finote_sms/logic/sms_state.dart';
import 'package:flutter/material.dart';

class ContactDetailPage extends StatelessWidget {
  final Contact contact;
  final List<SentMessage> logs;

  const ContactDetailPage({
    super.key,
    required this.contact,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: logs.isEmpty
          ? const Center(child: Text("No messages sent yet"))
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return ListTile(
            title: Text(log.message),
            subtitle: Text("Status: ${log.status ?? 'Pending'}"),
            trailing: Text(
                "${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}"),
          );
        },
      ),
    );
  }
}
