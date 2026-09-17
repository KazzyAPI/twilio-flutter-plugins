package com.twilioflutter.conversations.bridge

import com.twilioflutter.conversations.pigeon.ConversationsNativeEvent
import com.twilioflutter.conversations.pigeon.TwilioConversationsFlutterApi
import io.flutter.plugin.common.BinaryMessenger

/** Sends canonical conversation events from Android to Dart. */
class ConversationsEventEmitter(binaryMessenger: BinaryMessenger) {
  private val flutterApi = TwilioConversationsFlutterApi(binaryMessenger)

  /** Emits [event] to the Flutter side. */
  fun emit(event: ConversationsNativeEvent) {
    flutterApi.onNativeEvent(event) {}
  }
}
