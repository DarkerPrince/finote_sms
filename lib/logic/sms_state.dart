import '../data/contact_model.dart';

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
    Map<String, List<SentMessage>>? sentLogsByGroup,
    Map<String, List<SentMessage>>? sentLogsByContact,
  })  : sentLogsByGroup = sentLogsByGroup ?? {},
        sentLogsByContact = sentLogsByContact ?? {};

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
