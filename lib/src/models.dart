enum ProviderId {
  github,
  google;
  
  String get value {
    switch (this) {
      case ProviderId.github:
        return 'github';
      case ProviderId.google:
        return 'google';
    }
  }
  
  static ProviderId fromString(String value) {
    switch (value.toLowerCase()) {
      case 'github':
        return ProviderId.github;
      case 'google':
        return ProviderId.google;
      default:
        throw ArgumentError('Unknown provider: $value');
    }
  }
}

class OAuthProfile {
  final ProviderId providerId;
  final String email;
  final String? name;
  final String? avatar;
  final String? provider;
  final Map<String, dynamic> raw;

  OAuthProfile({
    required this.providerId,
    required this.email,
    this.name,
    this.avatar,
    this.provider,
    required this.raw,
  });
}


/// OAuth authentication exception
class DartAuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  DartAuthException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('DartAuthException');
    if (code != null) {
      buffer.write('[$code]');
    }
    buffer.write(': $message');
    if (originalError != null) {
      buffer.write(' (original error: $originalError)');
    }
    return buffer.toString();
  }
}
