class ChatwootUser {
  final String identifier;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? identifierHash;

  const ChatwootUser({
    required this.identifier,
    required this.email,
    this.name,
    this.avatarUrl,
    this.phoneNumber,
    this.identifierHash,
  });
}

class ChatwootSettings {
  final String? locale;
  final String? position;
  final bool? hideMessageBubble;

  const ChatwootSettings({this.hideMessageBubble, this.locale, this.position});
}
