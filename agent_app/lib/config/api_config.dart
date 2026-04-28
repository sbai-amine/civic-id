/// Agent API base URL and (legacy) compile-time auth fallbacks.
///
/// The runtime key issued by the admin web is stored in [AgentKeyStorage]
/// (platform secure store) and entered via the in-app setup screen. The
/// compile-time fields below are kept only as a fallback for developer builds.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  /// Sent as `X-API-Key` (or Bearer) for POST `/sync/scans`.
  static const String agentApiKey = String.fromEnvironment(
    'AGENT_API_KEY',
    defaultValue: '',
  );

  @Deprecated('Use AGENT_API_KEY')
  static const String agentSyncSecret = String.fromEnvironment(
    'AGENT_SYNC_SECRET',
    defaultValue: '',
  );
}
