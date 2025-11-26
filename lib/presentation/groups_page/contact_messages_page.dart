import 'package:finote_sms/logic/sms_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finote_sms/logic/sms_bloc.dart';

class ContactMessagesPage extends StatelessWidget {
  final String contactPhone;
  final String contactName;

  const ContactMessagesPage({super.key, required this.contactPhone, required this.contactName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contactName)),
  body: BlocBuilder<SmsBloc, SmsState>(builder: (context, state) {
        final logs = state.sentLogsByContact[contactPhone] ?? [];

        if (logs.isEmpty) {
          return const Center(child: Text('No messages sent to this contact yet.'));
        }

        return ListView.builder(
          reverse: true,
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[logs.length - 1 - index];
            final isSent = log.status == 'SENT';
            return Align(
              alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSent ? Colors.teal.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.message),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          log.status == 'SENT' ? Icons.check_circle : log.status == 'FAILED' ? Icons.error : Icons.hourglass_empty,
                          size: 14,
                          color: log.status == 'SENT' ? Colors.green : log.status == 'FAILED' ? Colors.red : Colors.orange,
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
