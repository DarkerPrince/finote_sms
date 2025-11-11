class Contact {
  final String name;
  final String phone;

  Contact({required this.name, required this.phone});

  factory Contact.fromJson(Map<String, dynamic> json) =>
      Contact(name: json['name'], phone: json['phone']);
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
