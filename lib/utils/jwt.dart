// utils/jwt.dart
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtUtil {
  // Server bilan mos keladigan maxfiy kalitni kiriting
  static const _secret = "Sening_server_secret";

  /// Token yaratish
  static String generateToken(int userId, String role) {
    try {
      final jwt = JWT(
        {
          'user_id': userId,
          'role': role,
        },
        issuer: 'my_api',
      );

      return jwt.sign(SecretKey(_secret), expiresIn: Duration(days: 7));
    } catch (e) {
      // Token yaratishda xatolik bo‘lsa, bo‘sh string qaytaradi
      return "";
    }
  }

  /// Tokenni tekshirish (verify)
  static JWT? verify(String token) {
    try {
      return JWT.verify(token, SecretKey(_secret));
    } catch (e) {
      return null; // Xato bo‘lsa null qaytaradi
    }
  }

  /// Tokendan rolni olish
  static String? getRole(String? token) {
    if (token == null || token.isEmpty) return null;
    final jwt = verify(token);
    if (jwt == null) return null;
    try {
      return jwt.payload['role']?.toString();
    } catch (e) {
      return null;
    }
  }

  /// Tokendan user_id olish
  static int? getUserId(String? token) {
    if (token == null || token.isEmpty) return null;
    final jwt = verify(token);
    if (jwt == null) return null;
    try {
      return int.tryParse(jwt.payload['user_id']?.toString() ?? "");
    } catch (e) {
      return null;
    }
  }
}
