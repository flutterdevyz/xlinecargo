import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/order_service.dart';

class OrderRoutes {
  Router get router {
    final router = Router();

    // 1. Foydalanuvchining barcha buyurtmalarini olish
    router.get('/user/all-order', (Request req) async {
      try {
        final userIdRaw = req.context['userId'] ?? req.context['user_id'];

        if (userIdRaw == null) {
          return Response.forbidden(jsonEncode({'error': 'User ID topilmadi'}));
        }

        final parsedId = int.tryParse(userIdRaw.toString());
        if (parsedId == null) {
          return Response.internalServerError(body: jsonEncode({'error': 'ID formati xato'}));
        }

        final orders = await OrderService.getByUserId(parsedId);
        return Response.ok(
          jsonEncode(orders),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    // 2. Yangi buyurtma yaratish
    router.post('/user/create', (Request req) async {
      try {
        final userIdRaw = req.context['userId'] ?? req.context['user_id'];
        if (userIdRaw == null) {
          return Response.forbidden(jsonEncode({'error': 'Avtorizatsiyadan o\'ting'}));
        }

        final int userId = int.parse(userIdRaw.toString());
        final payload = await req.readAsString();
        final data = jsonDecode(payload);

        // Ma'lumotlarni xavfsiz o'qish
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
        print("CREATE ERROR: $e");
        return Response.internalServerError(
          body: jsonEncode({'error': 'Serverda xatolik: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 3. Admin barcha buyurtmalarni ko'rishi
    router.get('/admin/order/all', (Request req) async {
      final role = req.context['role']?.toString();

      if (role != 'admin') {
        return Response.forbidden(jsonEncode({'error': 'Admin huquqi kerak!'}));
      }

      final orders = await OrderService.getAll();
      return Response.ok(
        jsonEncode(orders),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // 4. Buyurtma statusini yangilash (Admin uchun)
    router.put('/admin/update-status/<id>', (Request req, String id) async {
      try {
        final role = req.context['role']?.toString();
        if (role != 'admin') {
          return Response.forbidden(jsonEncode({'error': 'Faqat admin statusni o\'zgartira oladi'}));
        }

        final payload = await req.readAsString();
        final data = jsonDecode(payload);

        if (data['status'] == null) {
          return Response.badRequest(body: jsonEncode({'error': 'Status yuborilmadi'}));
        }

        // Statusni yangilash kodi
        await OrderService.updateStatus(int.parse(id), data['status']);

        return Response.ok(
          jsonEncode({'success': true, 'message': 'Status yangilandi'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print("UPDATE ERROR: $e");
        return Response.internalServerError(body: jsonEncode({'error': 'Xatolik: $e'}));
      }
    });

    // 5. Track kodi orqali qidirish (Hamma uchun)
    router.get('/user/track/<code>', (Request req, String code) async {
      final order = await OrderService.track(code);
      if (order == null) return Response.notFound(jsonEncode({'error': 'Topilmadi'}));
      return Response.ok(
          jsonEncode(order),
          headers: {'Content-Type': 'application/json'}
      );
    });

    return router;
  }
}