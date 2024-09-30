class ChatwootUser {
  final String identifier;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String? phoneNumber;

  const ChatwootUser({
    required this.identifier,
    required this.email,
    this.name,
    this.avatarUrl,
    this.phoneNumber,
  });
}

class ChatwootSettings {
  final String? locale;
  final String? position;

  const ChatwootSettings({this.locale, this.position});
}
