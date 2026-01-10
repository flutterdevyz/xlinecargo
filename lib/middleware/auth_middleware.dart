// middleware/auth_middleware.dart
import 'package:shelf/shelf.dart';
import '../utils/jwt.dart';

// middleware/auth_middleware.dart
Middleware authMiddleware({bool adminOnly = false}) {
  return (handler) {
    return (request) async {
      final authHeader = request.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Token required');
      }

      final token = authHeader.substring(7);

      try {
        final jwt = JwtUtil.verify(token);

        // Payload'dan userId ni int qilib olish (ba'zan JSON'da String kelishi mumkin)
        final rawUserId = jwt.payload['userId'] ?? jwt.payload['user_id'];
        final userId = int.parse(rawUserId.toString());
        final String role = jwt.payload['role'] ?? 'user';

        if (adminOnly && role != 'admin') {
          return Response.forbidden('Admin only (Middleware level)');
        }

        return handler(
          request.change(context: {
            'userId': userId,
            'role': role,
          }),
        );
      } catch (e) {
        return Response.forbidden('Invalid token or access denied');
      }
    };
  };
}