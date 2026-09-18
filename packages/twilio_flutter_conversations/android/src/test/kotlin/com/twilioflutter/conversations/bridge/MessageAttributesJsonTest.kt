package com.twilioflutter.conversations.bridge

import kotlin.test.Test
import kotlin.test.assertFailsWith

class MessageAttributesJsonTest {
  @Test
  fun requireNonEmptyJsonObject_acceptsNonEmptyObject() {
    MessageAttributesJson.requireNonEmptyJsonObject("""{"orderId":"123"}""")
  }

  @Test
  fun requireNonEmptyJsonObject_rejectsEmptyObject() {
    assertFailsWith<IllegalArgumentException> {
      MessageAttributesJson.requireNonEmptyJsonObject("{}")
    }
  }

  @Test
  fun requireNonEmptyJsonObject_rejectsWhitespaceOnlyObject() {
    assertFailsWith<IllegalArgumentException> {
      MessageAttributesJson.requireNonEmptyJsonObject("{ }")
    }
  }
}
