import 'package:finote_sms/data/contact_model.dart';
import 'package:flutter/material.dart';

class ContactDetailPage extends StatelessWidget {
  final Group group;
  const ContactDetailPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${group.name} Contacts")),
      body: ListView.builder(
        itemCount: group.contacts.length,
        itemBuilder: (context, index) {
          final contact = group.contacts[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(contact.name),
            subtitle: Text(contact.phone),
          );
        },
      ),
    );
  }
}
