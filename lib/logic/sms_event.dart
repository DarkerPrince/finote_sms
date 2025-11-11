abstract class SmsEvent {}

class LoadGroupsEvent extends SmsEvent {}

class SelectGroupEvent extends SmsEvent {
  final String groupName;
  SelectGroupEvent(this.groupName);
}

class SelectSimEvent extends SmsEvent {
  final int simIndex;
  SelectSimEvent(this.simIndex);
}

class SendBulkSmsEvent extends SmsEvent {
  final String message;
  final String groupName; // send only to this group

  SendBulkSmsEvent(this.message, {required this.groupName});
}
