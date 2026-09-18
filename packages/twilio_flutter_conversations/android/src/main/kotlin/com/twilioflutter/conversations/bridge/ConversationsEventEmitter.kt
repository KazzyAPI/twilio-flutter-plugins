package com.twilioflutter.conversations.bridge

import com.twilioflutter.conversations.pigeon.ConversationsNativeEvent
import com.twilioflutter.conversations.pigeon.TwilioConversationsFlutterApi
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/** Sends canonical conversation events from Android to Dart. */
class ConversationsEventEmitter(binaryMessenger: BinaryMessenger) {
  private val flutterApi = TwilioConversationsFlutterApi(binaryMessenger)
  private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

  /** Emits [event] to the Flutter side. */
  fun emit(event: ConversationsNativeEvent) {
    scope.launch {
      flutterApi.onNativeEvent(event)
    }
  }
}
