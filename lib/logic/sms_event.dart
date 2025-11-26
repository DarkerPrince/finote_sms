abstract class SmsEvent {}

class LoadGroupsEvent extends SmsEvent {}

class SelectGroupEvent extends SmsEvent {
  final String groupName;
  SelectGroupEvent(this.groupName);
}

class SendBulkSmsEvent extends SmsEvent {
  final String groupName;
  final String message;
  SendBulkSmsEvent({required this.groupName, required this.message});
}

// 👇 new event
class ToggleGroupSelectionEvent extends SmsEvent {
  final String groupName;
  ToggleGroupSelectionEvent(this.groupName);
}

class ClearStatusEvent extends SmsEvent {}

// Internal event used to restore persisted logs on startup
class RestoreLogsEvent extends SmsEvent {
  final Map<String, List<dynamic>> groups;
  final Map<String, List<dynamic>> contacts;
  RestoreLogsEvent(this.groups, this.contacts);
}
