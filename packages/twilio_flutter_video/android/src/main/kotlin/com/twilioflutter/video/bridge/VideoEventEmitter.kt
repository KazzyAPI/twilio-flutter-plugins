package com.twilioflutter.video.bridge

import com.twilioflutter.video.pigeon.TwilioVideoFlutterApi
import com.twilioflutter.video.pigeon.VideoNativeEvent
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class VideoEventEmitter(binaryMessenger: BinaryMessenger) {
  private val flutterApi = TwilioVideoFlutterApi(binaryMessenger)
  private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

  fun emit(event: VideoNativeEvent) {
    scope.launch {
      flutterApi.onNativeEvent(event)
    }
  }
}
