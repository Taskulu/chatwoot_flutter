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
    final runFunction = chatwootSDKRun as _DartFunctionChatwootSDKRun?;
    runFunction?.call(websiteToken: token, baseUrl: baseUrl);
    if (chatwoot == null) {
      _registerEventCallback('chatwoot:ready', () {
        _eventsController.add(ChatwootEvent.ready);
        completer.complete();
      });
      await completer.future;
    }
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
      chatwoot?.setUser(user.identifier, user.toJSObject);

  @override
  Future<void> setSettings(ChatwootSettings settings) async {
    chatwootSettings = settings.toJSObject;

    if (settings.locale != null) {
      chatwoot?.setLocale(settings.locale);
    }

    if (settings.position != null) {
      const chatwootElementsQuery = "[class^=\"woot-\"]";
      final chatwootCurrentElementsClass =
          "woot-elements--${chatwoot?.position}";

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
      chatwoot?.position = settings.position!;
    }
  }

  @override
  Future<void> setLabel(String label) async => chatwoot?.setLabel(label);

  @override
  Future<void> removeLabel(String label) async => chatwoot?.removeLabel(label);

  @override
  Future<void> removeCustomAttribute(String attribute) async =>
      chatwoot?.deleteCustomAttribute(attribute);

  @override
  Future<void> setCustomAttributes(Map<String, dynamic> attributes) async =>
      chatwoot?.setCustomAttributes(attributes.jsify() as JSObject);

  @override
  Future<void> setConversationCustomAttributes(
          Map<String, dynamic> attributes) async =>
      chatwoot?.setConversationCustomAttributes(attributes.jsify() as JSObject);

  @override
  Future<void> removeConversationCustomAttribute(String attribute) async =>
      chatwoot?.deleteConversationCustomAttribute(attribute);

  @override
  Future<void> toggle() async => chatwoot?.toggle();

  @override
  Future<void> reset() async => chatwoot?.reset();

  @override
  Stream<ChatwootEvent> get eventsStream => _eventsController.stream;

  @override
  bool get isOpen => chatwoot?.isOpen ?? false;
}

typedef _DartFunctionChatwootSDKRun = void Function(
    {String websiteToken, String baseUrl});

@JS('window.chatwootSDK.run')
external JSFunction? chatwootSDKRun;

@JS('window.chatwootSettings')
external JSObject? chatwootSettings;

@JS('window.\$chatwoot')
external JSChatwoot? chatwoot;

@JS()
@staticInterop
abstract class JSChatwoot {}

extension on JSChatwoot {
  @JS()
  external String position;

  @JS()
  external void setLocale(String? value);

  @JS()
  external void setLabel(String value);

  @JS()
  external void removeLabel(String value);

  @JS()
  external void setUser(String identifier, JSObject? data);

  @JS()
  external void setConversationCustomAttributes(JSObject attributes);

  @JS()
  external void deleteConversationCustomAttribute(String attribute);

  @JS()
  external void setCustomAttributes(JSObject attributes);

  @JS()
  external void deleteCustomAttribute(String attribute);

  @JS()
  external void toggle();

  @JS()
  external void reset();

  @JS()
  external bool get isOpen;
}

extension on ChatwootUser {
  JSObject? get toJSObject => {
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
        'phone_number': phoneNumber,
        'identifier_hash': identifierHash,
      }.jsify() as JSObject?;
}

extension on ChatwootSettings {
  JSObject? get toJSObject => {
        if (locale != null) 'locale': locale,
        if (position != null) 'position': position,
        if (baseDomain != null) 'baseDomain': baseDomain,
        if (hideMessageBubble != null) 'hideMessageBubble': hideMessageBubble,
        if (showUnreadMessagesDialog != null)
          'showUnreadMessagesDialog': showUnreadMessagesDialog,
      }.jsify() as JSObject?;
}
