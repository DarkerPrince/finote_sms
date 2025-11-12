import 'package:finote_sms/data/contact_model.dart';
import 'package:finote_sms/logic/sms_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/sms_bloc.dart';
import '../logic/sms_state.dart';

class BulkSmsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmsBloc, SmsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("📱 Bulk SMS Sender"),
          ),
          body: Column(
            children: [
              // 🟢 STATUS BAR
              if (state.status != null && state.status!.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    state.status!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),

              // 🟩 GROUPS LIST
              Expanded(
                child: ListView.builder(
                  itemCount: state.groups.length,
                  itemBuilder: (context, index) {
                    final group = state.groups[index];
                    final groupLogs =
                        state.sentLogsByGroup[group.name] ?? [];

                    // 🕓 Find last sent time
                    final lastSentTime = groupLogs.isNotEmpty
                        ? groupLogs.last.timestamp
                        : null;

                    // 🟢 Find last status
                    final lastStatus = groupLogs.isNotEmpty
                        ? groupLogs.last.status
                        : "Not sent";

                    return Card(
                      elevation: 3,
                      margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text(group.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Contacts: ${group.contacts.length}"),
                            if (lastSentTime != null)
                              Text(
                                "Last: $lastStatus at ${lastSentTime.hour}:${lastSentTime.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  color: lastStatus == "SENT"
                                      ? Colors.green
                                      : lastStatus == "FAILED"
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✅ Select Button
                            IconButton(
                              icon: Icon(
                                state.selectedGroups.contains(group.name)
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                context
                                    .read<SmsBloc>()
                                    .add(ToggleGroupSelectionEvent(group.name));
                              },
                            ),
                            // 🔍 View Details
                            IconButton(
                              icon: const Icon(Icons.list_alt_rounded),
                              onPressed: () {
                                _showGroupContacts(context, group.name, groupLogs);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 🟣 SEND BUTTON
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Send Message"),
                  onPressed: state.selectedGroups.isEmpty
                      ? null
                      : () => _showSendBottomSheet(context, state.selectedGroups),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContactMessages(BuildContext context, String phone) {
    final bloc = context.read<SmsBloc>();
    final contactLogs = bloc.state.sentLogsByContact[phone] ?? [];

    if (contactLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No messages sent to this contact yet.")),
      );
      return;
    }

    final contactName = contactLogs.first.contactName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    contactName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  reverse: true, // show latest first
                  itemCount: contactLogs.length,
                  itemBuilder: (_, i) {
                    final log = contactLogs[contactLogs.length - 1 - i];
                    final isSent = log.status == "SENT";

                    return Align(
                      alignment: isSent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSent
                              ? Colors.teal.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.message,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  log.status == "SENT"
                                      ? Icons.check_circle
                                      : log.status == "FAILED"
                                      ? Icons.error
                                      : Icons.hourglass_empty,
                                  size: 14,
                                  color: log.status == "SENT"
                                      ? Colors.green
                                      : log.status == "FAILED"
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  // 👇 Show contacts list
  void _showGroupContacts(
      BuildContext context,
      String groupName,
      List<SentMessage> logs,
      ) {
    final bloc = context.read<SmsBloc>();
    final group =
    bloc.state.groups.firstWhere((g) => g.name == groupName); // get group

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "👥 ${group.name} — ${group.contacts.length} contacts",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: group.contacts.length,
                  itemBuilder: (_, i) {
                    final contact = group.contacts[i];
                    final log = logs.firstWhere(
                          (l) => l.contactPhone == contact.phone,
                      orElse: () => SentMessage(
                        contactName: contact.name,
                        contactPhone: contact.phone,
                        message: "",
                        status: "Not sent",
                        groupName: groupName,
                        timestamp: DateTime.now(),
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(contact.name),
                        subtitle: Text("📞 ${contact.phone}\nStatus: ${log.status}"),
                        trailing: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                        onTap: () {
                          Navigator.pop(context); // close contact list first
                          _showContactMessages(context, contact.phone);
                        },
                      ),
                    );

                  },
                ),
              ),
            ],
          ),
        );
      },
      isScrollControlled: true,
    );
  }


  // 👇 Message bottom sheet
  void _showSendBottomSheet(BuildContext context, List<String> selectedGroups) {
    final msgController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Send Message to Selected Groups"),
              const SizedBox(height: 10),
              TextField(
                controller: msgController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Enter message (use {name} for personalization)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded),
                label: const Text("Send Now"),
                onPressed: () {
                  Navigator.pop(context); // close modal

                  // Dispatch sending event
                  for (var groupName in selectedGroups) {
                    context.read<SmsBloc>().add(
                      SendBulkSmsEvent(
                        groupName: groupName,
                        message: msgController.text,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
