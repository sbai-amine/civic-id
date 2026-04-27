class RegisterRequest {
  const RegisterRequest({
    required this.nationalId,
    required this.fullName,
    required this.pin,
  });

  final String nationalId;
  final String fullName;
  final String pin;
}
