package com.twilioflutter.video.bridge

import com.twilioflutter.video.pigeon.TwilioVideoFlutterApi
import com.twilioflutter.video.pigeon.VideoNativeEvent
import io.flutter.plugin.common.BinaryMessenger

class VideoEventEmitter(binaryMessenger: BinaryMessenger) {
  private val flutterApi = TwilioVideoFlutterApi(binaryMessenger)

  fun emit(event: VideoNativeEvent) {
    flutterApi.onNativeEvent(event) {}
  }
}
