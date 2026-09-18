package com.twilioflutter.conversations.bridge

import com.twilio.conversations.Attributes
import com.twilio.conversations.Message
import org.json.JSONObject

/** Shared JSON ↔ Twilio [Attributes] conversion for Android. */
object MessageAttributesJson {
  private val EMPTY_JSON_OBJECT = Regex("""^\{\s*\}$""")

  /** Validates JSON object strings without [JSONObject] (safe for JVM unit tests). */
  internal fun requireNonEmptyJsonObject(jsonObject: String) {
    if (EMPTY_JSON_OBJECT.matches(jsonObject.trim())) {
      throw IllegalArgumentException("attributesJson must be a non-empty JSON object.")
    }
  }

  /** Parses and validates a JSON object string (testable without a [Message]). */
  fun parseJsonObject(jsonObject: String): JSONObject {
    requireNonEmptyJsonObject(jsonObject)
    return JSONObject(jsonObject)
  }

  /** Parses a JSON object string into Twilio [Attributes]. */
  fun attributesFromJson(jsonObject: String): Attributes {
    return Attributes(parseJsonObject(jsonObject))
  }

  /** Serializes message attributes to a JSON object string, if present. */
  fun jsonFromMessage(message: Message): String? {
    val attributes = message.attributes ?: return null
    val jsonObject =
      try {
        attributes.jsonObject
      } catch (_: IllegalStateException) {
        return null
      }
    if (jsonObject?.length() == 0) {
      return null
    }
    return jsonObject.toString()
  }
}
