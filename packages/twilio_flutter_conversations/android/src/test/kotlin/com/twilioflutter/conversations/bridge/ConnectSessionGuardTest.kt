package com.twilioflutter.conversations.bridge

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

class ConnectSessionGuardTest {
  @Test
  fun staleConnectCallbackAfterDisconnectIsRejected() {
    val guard = ConnectSessionGuard()
    val generationA = guard.beginConnect()
    require(generationA != null)

    guard.invalidatePendingConnect()

    val generationB = guard.beginConnect()
    require(generationB != null)
    assertTrue(guard.isConnectInFlight())

    assertEquals(ConnectCompletion.STALE, guard.completeConnect(generationA))
    assertTrue(guard.isConnectInFlight())

    assertEquals(ConnectCompletion.APPLIED, guard.completeConnect(generationB))
    assertFalse(guard.isConnectInFlight())
  }

  @Test
  fun secondBeginConnectWhileInFlightReturnsNull() {
    val guard = ConnectSessionGuard()
    assertTrue(guard.beginConnect() != null)
    assertNull(guard.beginConnect())
  }
}
