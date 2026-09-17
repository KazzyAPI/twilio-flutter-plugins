package com.twilioflutter.conversations.bridge

import com.twilioflutter.conversations.pigeon.PigeonConversationsNativeEvent
import com.twilioflutter.conversations.pigeon.TwilioConversationsFlutterApi
import io.flutter.plugin.common.BinaryMessenger

/** Sends canonical conversation events from Android to Dart. */
class ConversationsEventEmitter(binaryMessenger: BinaryMessenger) {
  private val flutterApi = TwilioConversationsFlutterApi(binaryMessenger)

  /** Emits [event] to the Flutter side. */
  fun emit(event: PigeonConversationsNativeEvent) {
    flutterApi.onNativeEvent(event) {}
  }
}
