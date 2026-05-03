class AuthSession {
  final String apiKey;
  final String provider;
  final String baseUrl;

  const AuthSession({
    required this.apiKey,
    required this.provider,
    required this.baseUrl,
  });
}
