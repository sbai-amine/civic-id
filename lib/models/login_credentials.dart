/// Immutable value object for sign-in input.
///
/// Serialized to JSON as `nationalID` and `PIN` for POST `/login`.
class LoginCredentials {
  const LoginCredentials({
    required this.nationalId,
    required this.pin,
  });

  final String nationalId;
  final String pin;
}
