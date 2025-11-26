// sms_bloc.dart
import 'dart:convert';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    on<RestoreLogsEvent>(_onRestoreLogs);
    on<ClearStatusEvent>((event, emit) {
      emit(state.copyWith(status: ""));
    });
    // Try to load persisted logs on creation
    _loadPersistedLogs();
  }

  Future<void> _loadPersistedLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupJson = prefs.getString('sentLogsByGroup');
      final contactJson = prefs.getString('sentLogsByContact');

      Map<String, List<SentMessage>> loadedGroups = {};
      Map<String, List<SentMessage>> loadedContacts = {};

      if (groupJson != null) {
        final Map<String, dynamic> decoded = json.decode(groupJson);
        decoded.forEach((k, v) {
          final list = (v as List).map((e) => SentMessage.fromJson(e)).toList();
          loadedGroups[k] = list;
        });
      }

      if (contactJson != null) {
        final Map<String, dynamic> decoded = json.decode(contactJson);
        decoded.forEach((k, v) {
          final list = (v as List).map((e) => SentMessage.fromJson(e)).toList();
          loadedContacts[k] = list;
        });
      }

      if (loadedGroups.isNotEmpty || loadedContacts.isNotEmpty) {
        add(RestoreLogsEvent(loadedGroups.map((k, v) => MapEntry(k, v)), loadedContacts.map((k, v) => MapEntry(k, v))));
      }
    } catch (e) {
      // ignore load errors
    }
  }

  Future<void> _persistLogs(SmsState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupMap = state.sentLogsByGroup.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()));
      final contactMap = state.sentLogsByContact.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()));
      await prefs.setString('sentLogsByGroup', json.encode(groupMap));
      await prefs.setString('sentLogsByContact', json.encode(contactMap));
    } catch (e) {
      // ignore persist errors
    }
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

  void _onRestoreLogs(RestoreLogsEvent event, Emitter<SmsState> emit) {
    // convert dynamic lists to SentMessage lists
    final restoredGroups = <String, List<SentMessage>>{};
    event.groups.forEach((k, v) {
      restoredGroups[k] = (v as List).map((e) => SentMessage.fromJson(e)).toList();
    });

    final restoredContacts = <String, List<SentMessage>>{};
    event.contacts.forEach((k, v) {
      restoredContacts[k] = (v as List).map((e) => SentMessage.fromJson(e)).toList();
    });

    emit(state.copyWith(
      sentLogsByGroup: restoredGroups,
      sentLogsByContact: restoredContacts,
    ));

    // Persist again to ensure storage is normalized
    _persistLogs(state.copyWith(
      sentLogsByGroup: restoredGroups,
      sentLogsByContact: restoredContacts,
    ));
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

    print("\n\n Sending the sms for ${event.groupName} message : ${event.message}");

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
              // Persist updated logs
              _persistLogs(state.copyWith(
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
      // persist final state
      _persistLogs(state.copyWith(
        sentLogsByGroup: Map<String, List<SentMessage>>.from(state.sentLogsByGroup)
          ..[event.groupName] = List.from(groupLogs),
        sentLogsByContact: Map<String, List<SentMessage>>.from(state.sentLogsByContact),
      ));
    } catch (e) {
      emit(state.copyWith(status: "❌ Error sending messages: $e"));
    }
  }


}
