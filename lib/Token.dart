class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  String? _token;

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  String? get token => _token;

  set token(String? newToken) {
    _token = newToken;
  }
}