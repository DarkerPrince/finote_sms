import 'package:finote_sms/presentation/groups_page/contact_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/sms_bloc.dart';
import '../logic/sms_event.dart';
import '../logic/sms_state.dart';

class BulkSmsPage extends StatefulWidget {
  const BulkSmsPage({super.key});

  @override
  State<BulkSmsPage> createState() => _BulkSmsPageState();
}

class _BulkSmsPageState extends State<BulkSmsPage> {
  final TextEditingController msgController = TextEditingController();
  String? selectedGroup;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmsBloc()..add(LoadGroupsEvent()),
      child: BlocBuilder<SmsBloc, SmsState>(
        builder: (context, state) {
          final bloc = context.read<SmsBloc>();

          return Scaffold(
            appBar: AppBar(title: const Text("Bulk SMS Manager")),
            body: state.groups.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // --- Input + Send button (shows when group selected) ---
                  if (selectedGroup != null)
                    Column(
                      children: [
                        Text(
                          "Send message to $selectedGroup",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: msgController,
                          decoration: const InputDecoration(
                            hintText:
                            "Type your message (use {name} for personalization)",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text("Send Bulk SMS"),
                          onPressed: () {
                            final message = msgController.text.trim();
                            if (message.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                  Text("Please type a message first!"),
                                ),
                              );
                              return;
                            }
                            bloc.add(SendBulkSmsEvent(message,
                                groupName: selectedGroup!));
                            msgController.clear();
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),

                  // --- Groups list ---
                  Expanded(
                    child: ListView(
                      children: state.groups.map((group) {
                        final logs =
                            state.sentLogsByGroup[group.name] ?? [];

                        return Card(
                          margin:
                          const EdgeInsets.symmetric(vertical: 4),
                          child: ExpansionTile(
                            onExpansionChanged: (expanded) {
                              if (expanded) {
                                setState(() {
                                  selectedGroup = group.name;
                                });
                              }
                            },
                            title: Text(group.name),
                            subtitle: Text(
                                "Contacts: ${group.contacts.length}, Messages sent: ${logs.length}"),
                            children: group.contacts.map((contact) {
                              // --- FIXED: make log nullable ---
                              final SentMessage? log = logs.cast<SentMessage?>().firstWhere(
                                    (l) => l?.contactPhone == contact.phone,
                                orElse: () => null,
                              );

                              return ListTile(
                                title: Text(contact.name),
                                subtitle: Text(
                                  log != null
                                      ? "Message: ${log.message}\nStatus: ${log.status ?? 'Pending'}"
                                      : "Not sent yet",
                                ),
                                onTap: log != null
                                    ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ContactDetailPage(
                                            contact: contact,
                                            logs: state
                                                .sentLogsByContact[
                                            contact.phone] ??
                                                [],
                                          ),
                                    ),
                                  );
                                }
                                    : null,
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
