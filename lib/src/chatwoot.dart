import 'models.dart';

abstract class ChatwootBase {
  Future<void> init({
    required String baseUrl,
    required String token,
    ChatwootUser? user,
    ChatwootSettings? settings,
  });
  Future<void> setUser(ChatwootUser user);
  Future<void> setSettings(ChatwootSettings settings);
  Future<void> setLabel(String label);
  Future<void> removeLabel(String label);
  Future<void> setCustomAttributes(Map<String, dynamic> attributes);
  Future<void> removeCustomAttribute(String attribute);
  Future<void> setConversationCustomAttributes(Map<String, dynamic> attributes);
  Future<void> removeConversationCustomAttribute(String attribute);
  Future<void> toggle();
  Future<void> reset();
  Stream<ChatwootEvent> get eventsStream;
  bool get isOpen;
}

class Chatwoot implements ChatwootBase {
  @override
  Future<void> init({
    required String baseUrl,
    required String token,
    ChatwootUser? user,
    ChatwootSettings? settings,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> setUser(ChatwootUser user) {
    throw UnimplementedError();
  }

  @override
  Future<void> setSettings(ChatwootSettings settings) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeLabel(String label) {
    throw UnimplementedError();
  }

  @override
  Future<void> setLabel(String label) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeCustomAttribute(String attribute) {
    throw UnimplementedError();
  }

  @override
  Future<void> setCustomAttributes(Map<String, dynamic> attributes) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeConversationCustomAttribute(String attribute) {
    throw UnimplementedError();
  }

  @override
  Future<void> setConversationCustomAttributes(
      Map<String, dynamic> attributes) {
    throw UnimplementedError();
  }

  @override
  Future<void> reset() {
    throw UnimplementedError();
  }

  @override
  Future<void> toggle() {
    throw UnimplementedError();
  }

  @override
  Stream<ChatwootEvent> get eventsStream => throw UnimplementedError();

  @override
  bool get isOpen => throw UnimplementedError();
}
