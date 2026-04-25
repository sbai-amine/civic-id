/// Agent API base URL and authentication.
///
/// Prefer `AGENT_API_KEY` (full key from server `npm run migrate` / admin).
/// Optional legacy sync secret; sent only when `AGENT_API_KEY` is not configured.
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
