package com.twilioflutter.conversations.bridge

import com.twilio.conversations.Attributes
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class MessageAttributesJsonTest {
  @Test
  fun parseJsonObject_acceptsNonEmptyObject() {
    val json = MessageAttributesJson.parseJsonObject("""{"orderId":"123"}""")
    assertEquals("123", json.getString("orderId"))
  }

  @Test
  fun parseJsonObject_rejectsEmptyObject() {
    assertFailsWith<IllegalArgumentException> {
      MessageAttributesJson.parseJsonObject("{}")
    }
  }

  @Test
  fun attributesFromJson_wrapsJSONObject() {
    val attributes = MessageAttributesJson.attributesFromJson("""{"k":"v"}""")
    assertEquals(Attributes.Type.OBJECT, attributes.type)
  }
}
