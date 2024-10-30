import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart';
import 'package:chatwoot/src/chatwoot.dart';

import 'models.dart';

class Chatwoot implements ChatwootBase {
  final _eventsController = StreamController<ChatwootEvent>.broadcast();

  Chatwoot();

  @override
  Future<void> init({
    required String baseUrl,
    required String token,
    ChatwootUser? user,
    ChatwootSettings? settings,
  }) async {
    final completer = Completer();
    if (settings != null) {
      await setSettings(settings);
    }
    window.chatwootSDK.run({'websiteToken': token, 'baseUrl': baseUrl}.toJS);
    _registerEventCallback('chatwoot:ready', () {
      _eventsController.add(ChatwootEvent.ready);
      completer.complete();
    });
    await completer.future;
    _registerEventCallback('chatwoot:on-message',
        () => _eventsController.add(ChatwootEvent.onMessage));
    _registerEventCallback('chatwoot:on-start-conversation',
        () => _eventsController.add(ChatwootEvent.onStartConversation));
    _registerEventCallback(
        'chatwoot:error', () => _eventsController.add(ChatwootEvent.error));
    if (user != null) {
      await setUser(user);
    }
  }

  void _registerEventCallback(String event, VoidCallback callback) {
    window.addEventListener(
      event,
      (Event _) {
        callback();
      }.toJS,
    );
  }

  @override
  Future<void> setUser(ChatwootUser user) async =>
      window.$chatwoot?.setUser(user.identifier, user.toJSObject);

  @override
  Future<void> setSettings(ChatwootSettings settings) async {
    window.chatwootSettings = settings.toJSObject;

    if (settings.locale != null) {
      window.$chatwoot?.setLocale(settings.locale);
    }

    if (settings.position != null) {
      const chatwootElementsQuery = "[class^=\"woot-\"]";
      final chatwootCurrentElementsClass =
          "woot-elements--${window.$chatwoot?.position}";

      void updateElementsPosition(NodeList elements) {
        for (int i = 0; i < elements.length; i++) {
          final node = elements.item(i);
          if (node case final Element element) {
            if (element.classList.contains(chatwootCurrentElementsClass)) {
              element.classList.remove(chatwootCurrentElementsClass);
              element.classList.add("woot-elements--${settings.position}");
            }
            final subElements = element.querySelectorAll(chatwootElementsQuery);
            if (subElements.length > 0) {
              updateElementsPosition(subElements);
            }
          }
        }
      }

      final chatwootElements =
          window.document.querySelectorAll(chatwootElementsQuery);
      updateElementsPosition(chatwootElements);
      window.$chatwoot?.position = settings.position!;
    }
  }

  @override
  Future<void> setLabel(String label) async =>
      window.$chatwoot?.setLabel(label);

  @override
  Future<void> removeLabel(String label) async =>
      window.$chatwoot?.removeLabel(label);

  @override
  Future<void> removeCustomAttribute(String attribute) async =>
      window.$chatwoot?.deleteCustomAttribute(attribute);

  @override
  Future<void> setCustomAttributes(Map<String, dynamic> attributes) async =>
      window.$chatwoot?.setCustomAttributes(attributes.toJS);

  @override
  Future<void> setConversationCustomAttributes(
          Map<String, dynamic> attributes) async =>
      window.$chatwoot?.setConversationCustomAttributes(attributes.toJS);

  @override
  Future<void> removeConversationCustomAttribute(String attribute) async =>
      window.$chatwoot?.deleteConversationCustomAttribute(attribute);

  @override
  Future<void> toggle() async => window.$chatwoot?.toggle();

  @override
  Future<void> reset() async => window.$chatwoot?.reset();

  @override
  Stream<ChatwootEvent> get eventsStream => _eventsController.stream;

  @override
  bool get isOpen => window.$chatwoot?.isOpen ?? false;
}

extension on Window {
  external JSChatwootSDK get chatwootSDK;

  external set chatwootSettings(JSObject value);

  external JSChatwoot? get $chatwoot;
}

@JS('window.chatwootSDK')
extension type JSChatwootSDK(JSObject _) implements JSObject {
  external void run(JSObject value);
}

@JS('window.\$chatwoot')
extension type JSChatwoot(JSObject _) implements JSObject {
  external String position;

  external void setLocale(String? value);

  external void setLabel(String value);

  external void removeLabel(String value);

  external void setUser(String identifier, JSObject data);

  external void setConversationCustomAttributes(JSObject attributes);

  external void deleteConversationCustomAttribute(String attribute);

  external void setCustomAttributes(JSObject attributes);

  external void deleteCustomAttribute(String attribute);

  external void toggle();

  external void reset();

  external bool get isOpen;
}

extension on ChatwootUser {
  JSObject get toJSObject => {
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
        'phone_number': phoneNumber,
        'identifier_hash': identifierHash,
      }.toJS;
}

extension on ChatwootSettings {
  JSObject get toJSObject => {
        if (locale != null) 'locale': locale,
        if (position != null) 'position': position,
        if (baseDomain != null) 'baseDomain': baseDomain,
        if (hideMessageBubble != null) 'hideMessageBubble': hideMessageBubble,
        if (showUnreadMessagesDialog != null)
          'showUnreadMessagesDialog': showUnreadMessagesDialog,
      }.toJS;
}

extension on Map {
  JSObject get toJS => jsify() as JSObject;
}
