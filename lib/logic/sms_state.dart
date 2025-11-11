// sms_state.dart
import '../data/contact_model.dart';

class SentMessage {
  final String contactName;
  final String contactPhone;
  final String message;
  final String? status;
  final String groupName;
  final DateTime timestamp;

  SentMessage({
    required this.contactName,
    required this.contactPhone,
    required this.message,
    required this.groupName,
    required this.timestamp,
    this.status,
  });
}

class SmsState {
  final List<Group> groups;
  final List<String> selectedGroups;
  final String? status;
  final Map<String, List<SentMessage>> sentLogsByGroup;
  final Map<String, List<SentMessage>> sentLogsByContact;

  SmsState({
    this.groups = const [],
    this.selectedGroups = const [],
    this.status,
    this.sentLogsByGroup = const {},
    this.sentLogsByContact = const {},
  });

  SmsState copyWith({
    List<Group>? groups,
    List<String>? selectedGroups,
    String? status,
    Map<String, List<SentMessage>>? sentLogsByGroup,
    Map<String, List<SentMessage>>? sentLogsByContact,
  }) {
    return SmsState(
      groups: groups ?? this.groups,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      status: status ?? this.status,
      sentLogsByGroup: sentLogsByGroup ?? this.sentLogsByGroup,
      sentLogsByContact: sentLogsByContact ?? this.sentLogsByContact,
    );
  }
}
