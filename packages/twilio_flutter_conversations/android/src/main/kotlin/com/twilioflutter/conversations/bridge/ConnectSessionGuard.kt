package com.twilioflutter.conversations.bridge

/** Result of completing an asynchronous native [connect] callback. */
enum class ConnectCompletion {
  /** Connect result applied; client may be stored. */
  APPLIED,

  /** Connect was superseded; caller must shut down the SDK client and ignore storage. */
  STALE,
}

/**
 * Guards overlapping and stale Twilio client creation callbacks.
 *
 * Used by [ConversationsBridge] so disconnect/dispose during an in-flight connect
 * cannot leak a native client.
 */
class ConnectSessionGuard {
  private var generation: Int = 0
  private var isConnectInFlight: Boolean = false

  /** Returns the generation token when connect starts, or null if connect is already in flight. */
  fun beginConnect(): Int? {
    if (isConnectInFlight) {
      return null
    }
    isConnectInFlight = true
    return generation
  }

  /** Invalidates in-flight connect attempts (disconnect, dispose). */
  fun invalidatePendingConnect() {
    generation += 1
    isConnectInFlight = false
  }

  /** Completes a connect callback for [requestGeneration]. */
  fun completeConnect(requestGeneration: Int): ConnectCompletion {
    if (requestGeneration != generation) {
      return ConnectCompletion.STALE
    }
    isConnectInFlight = false
    return ConnectCompletion.APPLIED
  }

  /** Whether a connect call is currently in flight. */
  fun isConnectInFlight(): Boolean = isConnectInFlight
}
