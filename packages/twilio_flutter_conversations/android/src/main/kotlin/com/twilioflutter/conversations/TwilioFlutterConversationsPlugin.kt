package com.twilioflutter.conversations

import com.twilioflutter.conversations.bridge.ConversationsBridge
import com.twilioflutter.conversations.bridge.ConversationsBridgeHostAdapter
import com.twilioflutter.conversations.pigeon.TwilioConversationsHostApi
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Flutter plugin entry point for Twilio Conversations. */
class TwilioFlutterConversationsPlugin : FlutterPlugin {
  private var bridge: ConversationsBridge? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    val conversationsBridge =
      ConversationsBridge(
        context = binding.applicationContext,
        binaryMessenger = binding.binaryMessenger,
      )
    bridge = conversationsBridge
    TwilioConversationsHostApi.setUp(
      binding.binaryMessenger,
      ConversationsBridgeHostAdapter(conversationsBridge),
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    bridge?.dispose()
    bridge = null
    TwilioConversationsHostApi.setUp(binding.binaryMessenger, null)
  }
}
