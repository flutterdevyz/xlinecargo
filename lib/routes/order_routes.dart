import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/order_service.dart';

class OrderRoutes {
  Router get router {
    final router = Router();

    // 1. Foydalanuvchining barcha buyurtmalarini olish
    router.get('/user/all-order', (Request req) async {
      final userIdRaw = req.context['userId'] ?? req.context['user_id'];

      if (userIdRaw == null) {
        return Response.forbidden(jsonEncode({'error': 'User ID topilmadi'}));
      }

      final parsedId = int.tryParse(userIdRaw.toString());
      if (parsedId == null) {
        return Response.internalServerError(body: jsonEncode({'error': 'ID formati xato'}));
      }

      try {
        final orders = await OrderService.getByUserId(parsedId);
        return Response.ok(jsonEncode(orders), headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    // 2. Yangi buyurtma yaratish (POST xatosi shu yerda tuzatildi)
    router.post('/user/create', (Request req) async {
      try {
        final userIdRaw = req.context['userId'] ?? req.context['user_id'];
        if (userIdRaw == null) {
          return Response.forbidden(jsonEncode({'error': 'Avtorizatsiyadan o\'ting'}));
        }

        final int userId = int.parse(userIdRaw.toString());

        // Body-ni o'qish
        final payload = await req.readAsString();
        final data = jsonDecode(payload);

        // Ma'lumot turlarini xavfsiz o'girish
        final String product = data['product']?.toString() ?? 'Noma\'lum';
        final int quantity = int.tryParse(data['quantity'].toString()) ?? 0;
        final String trackCode = data['track_code']?.toString() ?? '';

        await OrderService.create(
          userId: userId,
          product: product,
          quantity: quantity,
          trackCode: trackCode,
        );

        return Response.ok(
          jsonEncode({'message': 'Order muvaffaqiyatli yaratildi'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print("CREATE ERROR: $e"); // Debug uchun
        return Response.internalServerError(
          body: jsonEncode({'error': 'Serverda xatolik: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 3. Admin barcha buyurtmalarni ko'rishi
    router.get('/admin/order/all', (Request req) async {
      final role = req.context['role'] as String?;

      if (role != 'admin') {
        return Response.forbidden(jsonEncode({'error': 'Admin huquqi kerak!'}));
      }

      final orders = await OrderService.getAll();
      return Response.ok(jsonEncode(orders), headers: {'Content-Type': 'application/json'});
    });

    // 4. Track kod orqali qidirish
    router.get('/user/track/<code>', (Request req, String code) async {
      final order = await OrderService.track(code);
      if (order == null) return Response.notFound(jsonEncode({'error': 'Buyurtma topilmadi'}));
      return Response.ok(jsonEncode(order), headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}