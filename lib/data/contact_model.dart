class Contact {
  final String name;
  final String phone;
  final bool isMale;

  Contact({required this.name, required this.phone,required this.isMale});

  factory Contact.fromJson(Map<String, dynamic> json) =>
      Contact(name: json['name'], phone: json['phone'],isMale: json['isMale']);
}

class Group {
  final String name;
  final List<Contact> contacts;

  Group({required this.name, required this.contacts});

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    name: json['name'],
    contacts: (json['contacts'] as List)
        .map((c) => Contact.fromJson(c))
        .toList(),
  );
}

class SentMessage {
  final String contactName;
  final String contactPhone;
  final String message;
  final String status; // e.g. "Sent", "Failed", "Pending"
  final String groupName;
  final DateTime timestamp;

  SentMessage({
    required this.contactName,
    required this.contactPhone,
    required this.message,
    required this.status,
    required this.groupName,
    required this.timestamp,
  });

  SentMessage copyWith({
    String? contactName,
    String? contactPhone,
    String? message,
    String? status,
    String? groupName,
    DateTime? timestamp,
  }) {
    return SentMessage(
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      message: message ?? this.message,
      status: status ?? this.status,
      groupName: groupName ?? this.groupName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'contactName': contactName,
        'contactPhone': contactPhone,
        'message': message,
        'status': status,
        'groupName': groupName,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SentMessage.fromJson(Map<String, dynamic> json) => SentMessage(
        contactName: json['contactName'] ?? '',
        contactPhone: json['contactPhone'] ?? '',
        message: json['message'] ?? '',
        status: json['status'] ?? 'Not sent',
        groupName: json['groupName'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      );
}

