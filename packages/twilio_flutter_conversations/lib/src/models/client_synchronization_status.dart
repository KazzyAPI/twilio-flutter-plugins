/// Synchronization state of the Twilio Conversations client.
enum TwilioClientSynchronizationStatus {
  /// Initial state before synchronization begins.
  unknown,

  /// SDK is connecting and fetching metadata.
  started,

  /// Conversations list has been synchronized.
  conversationsListCompleted,

  /// All local state is synchronized and the client is ready.
  completed,

  /// Synchronization failed.
  failed,
}
