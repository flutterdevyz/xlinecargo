// middleware/auth_middleware.dart
import 'package:shelf/shelf.dart';
import '../utils/jwt.dart';

Middleware authMiddleware({bool adminOnly = false}) {
  return (handler) {
    return (request) async {
      final authHeader = request.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(
          'Token required',
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);

      // Token bo'sh yoki noto'g'ri bo'lsa null qaytaradi
      final jwt = JwtUtil.verify(token);
      if (jwt == null) {
        return Response.forbidden(
          'Invalid token',
          headers: {'Content-Type': 'application/json'},
        );
      }

      // userId va role olish
      int? userId;
      String role = 'user'; // default
      try {
        userId = JwtUtil.getUserId(token);
        role = JwtUtil.getRole(token) ?? 'user';
      } catch (_) {
        // Xato bo'lsa ham null/ default
        userId = null;
        role = 'user';
      }

      if (userId == null) {
        return Response.forbidden(
          'User ID not found in token',
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (adminOnly && role != 'admin') {
        return Response.forbidden(
          'Admin only (Middleware level)',
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Request context ga qo'shish
      return handler(
        request.change(context: {
          'userId': userId,
          'role': role,
          'token': token,
        }),
      );
    };
  };
}
