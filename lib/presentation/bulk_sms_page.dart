import 'package:ethiopian_datetime_picker/ethiopian_datetime_picker.dart';
import 'package:finote_sms/data/contact_model.dart';
import 'package:finote_sms/logic/sms_event.dart';
import 'package:finote_sms/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/sms_bloc.dart';
import '../logic/sms_state.dart';

class BulkSmsPage extends StatelessWidget {

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 48, color: Colors.blue),

                SizedBox(height: 16),

                Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Are you sure you want to log out of FinoteSMS?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        Navigator.pop(context); // close dialog

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Logout",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? "User";

    return BlocConsumer<SmsBloc, SmsState>(
      listener: (context, state) {
        if (state.status != null && state.status!.isNotEmpty) {
          Future.delayed(const Duration(seconds: 2), () {
            // Dispatch event to clear status only if still the same
            context.read<SmsBloc>().add(ClearStatusEvent());
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text("📱 Welcome $userName"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: "Logout",
                onPressed: () async {
                  showLogoutDialog(context);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // 🟢 STATUS BAR
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: (state.status != null && state.status!.isNotEmpty)
                    ? Container(
                  key: ValueKey(state.status),
                  width: double.infinity,
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    state.status!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                )
                    : const SizedBox.shrink(),
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
      )
  {
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



  void _showSendBottomSheet(BuildContext context, List<String> selectedGroups) {
    final msgController = TextEditingController();

    void insertTag(String tag) {
      final text = msgController.text;
      final selection = msgController.selection;

      // Fallback to 0 if the selection is invalid
      final start = selection.start >= 0 ? selection.start : 0;
      final end = selection.end >= 0 ? selection.end : 0;

      final newText = text.replaceRange(start, end, tag);

      msgController.text = newText;
      msgController.selection = TextSelection.collapsed(
        offset: start + tag.length,
      );
    }


    // TODAY DATE
    String getTodayDate() {
      final now = ETDateTime.now();
      final formatter = ETDateFormat("EEEE፡ d MMMM y");
      final dateStr = formatter.format(now);
      return dateStr;
    }

    String convertToEthiopianHour(int hour) {
      int ethHour = hour - 6;
      if (ethHour <= 0) ethHour += 12;
      return ethHour.toString();
    }

    String getEthiopianTimeLabel(int hour) {
      if (hour >= 0 && hour < 6) {
        return "ጠዋት"; // Midnight → 6 AM
      } else if (hour >= 6 && hour < 12) {
        return "ቀን"; // 6 AM → 12 PM
      } else if (hour >= 12 && hour < 18) {
        return "ከሰዓት"; // 12 PM → 6 PM
      } else {
        return "ማታ"; // 6 PM → Midnight
      }
    }

    // CURRENT TIME
    String getNowTime() {
      final picked = ETDateTime.now();

        // int hour = picked.hour;
        // final minute = picked.minute.toString().padLeft(2, "0");

        // Determine Amharic label
        // String label;


        int hour = picked.hour;
        int minute = picked.minute;

        final label = getEthiopianTimeLabel(hour);
        final ethHour = convertToEthiopianHour(hour);

        final timeStr = "$label $ethHour:${minute.toString().padLeft(2, '0')}";

        return timeStr;

    }

    // PICK DATE
    Future<void> pickCustomDate() async {
      ETDateTime? picked = await showETDatePicker(
        context: context,
        initialDate: ETDateTime.now(),
        firstDate: ETDateTime.now(),
        lastDate: ETDateTime(2040, 9),
        locale: const Locale('am'),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDatePickerMode: DatePickerMode.day,
      );
      // final picked = await showDatePicker(
      //   context: context,
      //   firstDate: DateTime(2020),
      //   lastDate: DateTime(2100),
      //   initialDate: DateTime.now(),
      // );

      if (picked != null) {
        final formatter = ETDateFormat("EEEE፡ d MMMM y");

        final dateStr = formatter.format(picked);

        insertTag(dateStr);
      }
    }




    // PICK TIME
    Future<void> pickCustomTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (picked != null) {
        int hour = picked.hour;
        int minute = picked.minute;

        final label = getEthiopianTimeLabel(hour);
        final ethHour = convertToEthiopianHour(hour);

        final timeStr = "$label $ethHour:${minute.toString().padLeft(2, '0')}";

        insertTag(timeStr);
      }
    }




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
              const Text(
                "Send Message to Selected Groups",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              /// ---------- TAG SHORTCUT BUTTONS ----------
              Wrap(
                spacing: 10,
                children: [
                  _tagButton("{name}", () => insertTag("{name}")),

                  /// DATE TAGS
                  _tagButton("Today Date", () => insertTag(getTodayDate())),
                  _tagButton("Pick Date", () => pickCustomDate()),

                  /// TIME TAGS
                  _tagButton("Now Time", () => insertTag(getNowTime())),
                  _tagButton("Pick Time", () => pickCustomTime()),

                  _tagButton("{phone}", () => insertTag("{phone}")),
                ],
              ),

              const SizedBox(height: 12),

              /// ---------- MESSAGE TEXT FIELD ----------
              TextField(
                controller: msgController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Enter message (use tags for personalization)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              /// ---------- SEND BUTTON ----------
              ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded),
                label: const Text("Send Now"),
                onPressed: () {
                  Navigator.pop(context);

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

  Widget _tagButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }


}
