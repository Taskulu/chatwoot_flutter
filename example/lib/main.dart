import 'package:flutter/material.dart';
import 'package:chatwoot/chatwoot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _chatwootPlugin = Chatwoot();

  @override
  void initState() {
    super.initState();
    initChatwoot();
  }

  Future<void> initChatwoot() async {
    await _chatwootPlugin.init(
      baseUrl: 'BASE_URL',
      token: 'TOKEN',
      settings: const ChatwootSettings(locale: 'en'),
    );
    await _chatwootPlugin
        .setUser(const ChatwootUser(identifier: 'identifier', email: 'email'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
      ),
    );
  }
}
