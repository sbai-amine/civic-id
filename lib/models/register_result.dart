sealed class RegisterResult {
  const RegisterResult();
}

final class RegisterSuccess extends RegisterResult {
  const RegisterSuccess({required this.nationalId});
  final String nationalId;
}

final class RegisterFailure extends RegisterResult {
  const RegisterFailure(this.message);
  final String message;
}
