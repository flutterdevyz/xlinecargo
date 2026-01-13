import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/order_service.dart';

class OrderRoutes {
  Router get router {
    final router = Router();

    // /orders/orders-all
    router.get('/user/all-order', (Request req) async {
      // Middleware-dan ID olishni har xil nomlar bilan tekshiramiz
      final userId = req.context['userId'] ?? req.context['user_id'];

      if (userId == null) {
        print("XATO: Context-da userId topilmadi. Mavjud context: ${req.context}");
        return Response.forbidden(jsonEncode({'error': 'User ID topilmadi'}));
      }

      // ID int ekanligiga ishonch hosil qilamiz (ba'zida String kelishi mumkin)
      final parsedId = int.tryParse(userId.toString());

      if (parsedId == null) {
        return Response.internalServerError(body: 'User ID formati noto\'g\'ri');
      }

      final orders = await OrderService.getByUserId(parsedId);

      return Response.ok(
          jsonEncode(orders),
          headers: {'Content-Type': 'application/json'}
      );
    });
    router.post('/user/create', (Request req) async {
      try {
        // 1. Contextdan IDni ikkala ehtimoliy nom bilan tekshirib olamiz
        final userIdRaw = req.context['userId'] ?? req.context['user_id'];

        if (userIdRaw == null) {
          return Response.forbidden(jsonEncode({'error': 'User ID topilmadi, iltimos qayta kiring'}));
        }

        // 2. IDni int turiga o'tkazamiz
        final int userId = int.parse(userIdRaw.toString());

        // 3. Body ma'lumotlarini o'qiymiz
        final payload = await req.readAsString();
        final data = jsonDecode(payload);

        // 4. Bazaga saqlaymiz
        await OrderService.create(
          userId: userId,
          product: data['product'] ?? 'Noma\'lum mahsulot',
          quantity: data['quantity'] ?? 0,
          trackCode: data['track_code'] ?? '',
        );

        return Response.ok(
          jsonEncode({'message': 'Order created successfully'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print("CREATE ERROR: $e"); // Server logida xatoni ko'rish uchun
        return Response.internalServerError(
          body: jsonEncode({'error': 'Serverda xatolik yuz berdi'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
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