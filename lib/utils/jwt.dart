// utils/jwt.dart
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtUtil {
  static const _secret = 'mUPCcNlIAPqcgWnyG3bN49cbapXDWFgEegFm1CMQ7tfGuquSQj6TPymicnLJucB6';

  static String generateToken(int userId, String role) {
    final jwt = JWT(
      {
        'user_id': userId,
        'role': role,
      },
      issuer: 'my_api',
    );

    return jwt.sign(SecretKey(_secret), expiresIn: Duration(days: 7));
  }

  static JWT verify(String token) {
    return JWT.verify(token, SecretKey(_secret));
  }
}
