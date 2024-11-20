// cookie_storage.dart

class CookieStorage {
  static final CookieStorage _instance = CookieStorage._internal();

  // Biến lưu cookies
  String? cookies;

  // Singleton Constructor
  CookieStorage._internal();

  // Factory để lấy ra instance duy nhất
  factory CookieStorage() => _instance;

  // Lưu cookies từ response
  void storeCookies(List<String> rawCookies) {
    cookies = rawCookies.join('; ');
    print('Cookies stored: $cookies');
  }

  // Lấy cookies đã lưu
  String? getCookies() {
    return cookies;
  }
}
