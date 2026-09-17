import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twilio_flutter_conversations/twilio_flutter_conversations.dart';

const _accessToken = String.fromEnvironment('TWILIO_ACCESS_TOKEN');
const _conversationSid = String.fromEnvironment('TWILIO_CONVERSATION_SID');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TwilioConversationsSession _chatSession = TwilioConversationsSession();
  final List<String> _eventLog = <String>[];
  var _isBusy = false;
  String? _statusLine;

  @override
  void initState() {
    super.initState();
    _statusLine =
        _accessToken.isEmpty
            ? 'Set TWILIO_ACCESS_TOKEN via --dart-define to connect.'
            : 'Token configured. Ready to connect.';
  }

  void _onEvent(TwilioConversationsEvent event) {
    setState(() {
      final detail =
          switch (event) {
            ClientSynchronizationStatusUpdated(:final status) => ' → $status',
            ConversationAdded(:final conversation) => ' ${conversation.sid}',
            MessageAdded(:final message) => ' ${message.body}',
            ConversationsError(:final exception) => ' ${exception.message}',
            _ => '',
          };
      _eventLog.insert(0, '${event.runtimeType}$detail');
    });
  }

  Future<void> _connect() async {
    if (_accessToken.isEmpty) {
      setState(() {
        _statusLine = 'Missing TWILIO_ACCESS_TOKEN (--dart-define).';
      });
      return;
    }
    setState(() => _isBusy = true);
    try {
      await _chatSession.start(
        accessToken: _accessToken,
        onEvent: _onEvent,
      );
      setState(() {
        _statusLine =
            'Connected (${_chatSession.client.connectionState.name}).';
      });
    } on TwilioFlutterException catch (error) {
      setState(() {
        _statusLine = 'Connect failed: ${error.message}';
      });
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _sendTestMessage() async {
    if (_conversationSid.isEmpty) {
      setState(() {
        _statusLine = 'Set TWILIO_CONVERSATION_SID to send a test message.';
      });
      return;
    }
    setState(() => _isBusy = true);
    try {
      await _chatSession.client.sendMessage(
        conversationSid: _conversationSid,
        body: 'Hello from twilio_flutter_conversations example',
        attributes: {'source': 'example_app'},
      );
      setState(() {
        _statusLine = 'Message sent.';
      });
    } on TwilioFlutterException catch (error) {
      setState(() {
        _statusLine = 'Send failed: ${error.message}';
      });
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _isBusy = true);
    try {
      await _chatSession.stop();
      setState(() {
        _statusLine = 'Disconnected.';
      });
    } on TwilioFlutterException catch (error) {
      setState(() {
        _statusLine = 'Disconnect failed: ${error.message}';
      });
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    unawaited(_chatSession.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Twilio Conversations'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_statusLine ?? ''),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _isBusy ? null : _connect,
                child: const Text('Connect'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _isBusy ? null : _sendTestMessage,
                child: const Text('Send test message'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _isBusy ? null : _disconnect,
                child: const Text('Disconnect'),
              ),
              const SizedBox(height: 16),
              Text('State: ${_chatSession.client.connectionState.name}'),
              const SizedBox(height: 8),
              const Text('Recent events'),
              Expanded(
                child: ListView.builder(
                  itemCount: _eventLog.length,
                  itemBuilder: (context, index) => Text(_eventLog[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
