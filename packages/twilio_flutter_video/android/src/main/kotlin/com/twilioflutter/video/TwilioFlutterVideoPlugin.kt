package com.twilioflutter.video

import com.twilioflutter.video.bridge.VideoBridge
import com.twilioflutter.video.pigeon.TwilioVideoHostApi
import io.flutter.embedding.engine.plugins.FlutterPlugin

class TwilioFlutterVideoPlugin : FlutterPlugin {
  private var videoBridge: VideoBridge? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    videoBridge = VideoBridge(binding.applicationContext, binding.binaryMessenger)
    TwilioVideoHostApi.setUp(binding.binaryMessenger, videoBridge)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    TwilioVideoHostApi.setUp(binding.binaryMessenger, null)
    videoBridge = null
  }
}
