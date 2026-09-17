/// Synchronization state for a single conversation cache.
enum TwilioConversationSynchronizationStatus {
  unknown,
  none,
  identifier,
  metadata,
  syncWindow,
  all,
  failed,
}
