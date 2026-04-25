import 'dart:convert';

/// Returns seconds since epoch for JWT [exp] claim, or `null` if not parseable.
int? parseJwtExpSeconds(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    var b = parts[1];
    switch (b.length % 4) {
      case 1:
        b += '===';
        break;
      case 2:
        b += '==';
        break;
      case 3:
        b += '=';
        break;
    }
    final json = jsonDecode(utf8.decode(base64Url.decode(b)));
    if (json is! Map) return null;
    final e = json['exp'];
    if (e is int) return e;
    if (e is num) return e.toInt();
  } catch (_) {}
  return null;
}

bool isJwtExpiredOrNearExpiry(String token, {int leewaySeconds = 60}) {
  final exp = parseJwtExpSeconds(token);
  if (exp == null) return true;
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return now >= exp - leewaySeconds;
}
