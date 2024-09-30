import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';
import 'package:chatwoot/src/chatwoot.dart';

import 'models.dart';

class Chatwoot implements ChatwootBase {
  const Chatwoot();

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
    window.addEventListener(
      'chatwoot:ready',
      (Event event) {
        Future.wait([
          if (user != null) setUser(user),
        ]).then(completer.complete);
      }.toJS,
    );
    return completer.future;
  }

  @override
  Future<void> setUser(ChatwootUser user) async {
    chatwoot?.setUser(
        user.identifier, {'email': user.email}.jsify() as JSObject?);
  }

  @override
  Future<void> setSettings(ChatwootSettings settings) async {
    chatwootSettings = {
      if (settings.locale != null) 'locale': settings.locale,
    }.jsify() as JSObject?;
    chatwoot?.setLocale(settings.locale);
  }

  @override
  Future<void> setLabel(String label) async {
    chatwoot?.setLabel(label);
  }

  @override
  Future<void> removeLabel(String label) async {
    chatwoot?.removeLabel(label);
  }

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
  Future<void> reset() async => chatwoot?.reset();
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
  external void reset();
}