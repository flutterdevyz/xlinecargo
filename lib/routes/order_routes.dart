import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/order_service.dart';

class OrderRoutes {
  Router get router {
    final router = Router();

    // /orders/orders-all
    router.get('/user/all-order', (Request req) async {
      final orders = await OrderService.getAll();
      return Response.ok(jsonEncode(orders), headers: {'Content-Type': 'application/json'});
    });
    router.post('/user/create', (Request req) async {
      // Middleware orqali kelgan context-dan userId olish
      final userId = req.context['userId'] as int?;
      if (userId == null) return Response.forbidden(jsonEncode({'error': 'User ID topilmadi'}));

      final data = jsonDecode(await req.readAsString());
      await OrderService.create(
        userId: userId,
        product: data['product'],
        quantity: data['quantity'],
        trackCode: data['track_code'],
      );
      return Response.ok(jsonEncode({'message': 'Order created'}));
    });
    // 3. Faqat Admin barcha buyurtmalarni ko'rishi
    router.get('/admin/order/all', (Request req) async {
      final role = req.context['role'] as String;

      if (role != 'admin') {
        return Response.forbidden(jsonEncode({'error': 'Admin only!'}));
      }

      final orders = await OrderService.getAll();
      return Response.ok(
        jsonEncode(orders),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // 4. Track kodi orqali qidirish (Hamma uchun)
// /orders/track/<code>
    router.get('/user/track/<code>', (Request req, String code) async {
      final order = await OrderService.track(code);
      if (order == null) return Response.notFound(jsonEncode({'error': 'Topilmadi'}));
      return Response.ok(jsonEncode(order), headers: {'Content-Type': 'application/json'});
    });
    return router;
  }
}