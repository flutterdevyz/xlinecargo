import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/order_service.dart';

class AdminRoutes {
  Router get router {
    final router = Router();

    // 1. Barcha buyurtmalarni olish
    router.get('/admin/orders', (Request req) async {
      try {
        final orders = await OrderService.getAll();
        return Response.ok(jsonEncode(orders),
            headers: {'Content-Type': 'application/json'});
      } catch (e ) {
        return Response.internalServerError(body: 'Xato: $e');
      }
    });

    // 2. Statusni yangilash
    router.put('/admin/orders/<id>/status', (Request req, String id) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        final allowed = ['created', 'on_way', 'delivered', 'cancelled'];
        if (data['status'] == null || !allowed.contains(data['status'])) {
          return Response.badRequest(body: 'Noto‘g‘ri status. Ruxsat berilgan: $allowed');
        }

        await OrderService.updateStatus(int.parse(id), data['status']);
        return Response.ok(jsonEncode({'message': 'Status muvaffaqiyatli yangilandi'}),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: 'Yangilashda xato: $e');
      }
    });

    return router;
  }
}