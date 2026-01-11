import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/order_service.dart';
import '../utils/jwt.dart';

class AdminRoutes {
  Router get router {
    final router = Router();

    // 🔹 Barcha buyurtmalarni olish
    router.get('/admin/orders', (Request req) async {
      try {
        final token = req.headers['Authorization']?.replaceFirst('Bearer ', '');
        if (token == null || JwtUtil.getRole(token) != 'admin') {
          return Response.forbidden(
            jsonEncode({'error': 'Admin role required'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final orders = await OrderService.getAll();
        return Response.ok(
          jsonEncode(orders),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Xato: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 🔹 Statusni yangilash
    router.put('/admin/orders/<id>/status', (Request req, String id) async {
      try {
        final token = req.headers['Authorization']?.replaceFirst('Bearer ', '');
        if (token == null || JwtUtil.getRole(token) != 'admin') {
          return Response.forbidden(
            jsonEncode({'error': 'Admin role required'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final body = await req.readAsString();
        final data = jsonDecode(body);

        final allowed = ['created', 'on_way', 'delivered', 'cancelled'];
        if (data['status'] == null || !allowed.contains(data['status'])) {
          return Response.badRequest(
            body: jsonEncode({
              'error': 'Noto‘g‘ri status. Ruxsat berilgan: $allowed',
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }

        await OrderService.updateStatus(int.parse(id), data['status']);
        return Response.ok(
          jsonEncode({'message': 'Status muvaffaqiyatli yangilandi'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Yangilashda xato: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}
