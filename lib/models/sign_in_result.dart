/// Result of a sign-in attempt (API or local).
sealed class SignInResult {
  const SignInResult();
}

/// Server issued tokens; persist [accessToken] and [refreshToken] (if any) securely.
final class SignInSuccess extends SignInResult {
  const SignInSuccess({
    required this.accessToken,
    this.refreshToken,
    this.qrHmacKey,
    this.fullName,
  });

  final String accessToken;
  final String? refreshToken;

  /// Per-user HMAC key for signed service QRs (v2). Stored in secure storage.
  final String? qrHmacKey;

  /// Full name as recorded at issuance. Empty/null means the column was not
  /// populated for this user (legacy accounts before [register] added it).
  final String? fullName;
}

/// Expected failure (validation, wrong credentials, network, etc.).
final class SignInFailure extends SignInResult {
  const SignInFailure(this.message);

  final String message;
}
