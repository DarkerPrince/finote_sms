// sms_bloc.dart
import 'dart:convert';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/contact_model.dart';
import 'sms_event.dart';
import 'sms_state.dart';

final Telephony telephony = Telephony.instance;

class SmsBloc extends Bloc<SmsEvent, SmsState> {
  SmsBloc() : super(SmsState()) {
    on<LoadGroupsEvent>(_onLoadGroups);
    on<SelectGroupEvent>(_onSelectGroup);
    on<SendBulkSmsEvent>(_onSendBulkSms);
    on<ToggleGroupSelectionEvent>(_onToggleGroupSelection); // 👈 add this
  }

  void _onToggleGroupSelection(
      ToggleGroupSelectionEvent event, Emitter<SmsState> emit) {
    final updatedSelection = List<String>.from(state.selectedGroups);

    if (updatedSelection.contains(event.groupName)) {
      updatedSelection.remove(event.groupName);
    } else {
      updatedSelection.add(event.groupName);
    }

    emit(state.copyWith(selectedGroups: updatedSelection));
  }


  Future<void> _onLoadGroups(
      LoadGroupsEvent event, Emitter<SmsState> emit)
  async {
    try {
      final jsonData = await rootBundle.loadString('assets/data/contacts.json');
      final data = json.decode(jsonData);
      final groups =
      (data['groups'] as List).map((e) => Group.fromJson(e)).toList();

      bool? granted = await telephony.requestPhoneAndSmsPermissions;

      if (granted != true) {
        emit(state.copyWith(status: "SMS permission denied ❌"));
        return;
      }

      emit(state.copyWith(groups: groups, status: "Groups loaded ✅"));
    } catch (e) {
      emit(state.copyWith(status: "Error loading groups: $e"));
    }
  }

  void _onSelectGroup(SelectGroupEvent event, Emitter<SmsState> emit) {
    final updated = List<String>.from(state.selectedGroups);
    if (updated.contains(event.groupName)) {
      updated.remove(event.groupName);
    } else {
      updated.add(event.groupName);
    }
    emit(state.copyWith(selectedGroups: updated));
  }

  Future<void> _onSendBulkSms(
      SendBulkSmsEvent event,
      Emitter<SmsState> emit,
      ) async {
    try {
      final group = state.groups.firstWhere((g) => g.name == event.groupName);

      // Request SMS permission
      bool? granted = await telephony.requestPhoneAndSmsPermissions;
      if (granted != true) {
        emit(state.copyWith(status: "❌ SMS permission denied"));
        return;
      }

      // Initialize logs for this group
      final List<SentMessage> groupLogs =
      List.from(state.sentLogsByGroup[event.groupName] ?? []);

      emit(state.copyWith(
          status: "📤 Sending messages to ${group.name}..."));

      for (final contact in group.contacts) {
        final personalizedMessage =
        event.message.replaceAll("{name}", contact.name);

        try {
          await telephony.sendSms(
            to: contact.phone,
            message: personalizedMessage,
            statusListener: (SendStatus status) {
              final log = SentMessage(
                contactName: contact.name,
                contactPhone: contact.phone,
                message: personalizedMessage,
                status: status.name,
                groupName: group.name,
                timestamp: DateTime.now(),
              );

              // Add log to local groupLogs
              groupLogs.add(log);

              // Update state maps
              final updatedGroupLogs =
              Map<String, List<SentMessage>>.from(state.sentLogsByGroup);
              updatedGroupLogs[event.groupName] = List.from(groupLogs);

              final updatedContactLogs =
              Map<String, List<SentMessage>>.from(state.sentLogsByContact);
              updatedContactLogs[contact.phone] =
              List.from(updatedContactLogs[contact.phone] ?? [])..add(log);

              emit(state.copyWith(
                status: "📩 Sent to ${contact.name}: ${status.name.toUpperCase()}",
                sentLogsByGroup: updatedGroupLogs,
                sentLogsByContact: updatedContactLogs,
              ));
            },
          );
        } catch (e) {
          emit(state.copyWith(
              status: "⚠️ Failed to send to ${contact.name}: $e"));
        }
      }

      emit(state.copyWith(
        status: "✅ All messages sent for group ${group.name}",
      ));
    } catch (e) {
      emit(state.copyWith(status: "❌ Error sending messages: $e"));
    }
  }


}
