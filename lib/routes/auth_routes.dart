import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/user_service.dart';
import '../utils/jwt.dart';
import '../utils/password.dart';

class AuthRoutes {
  Router get router {
    final router = Router();

    // 1. REGISTER
    router.post('/user/register', (Request req) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        final exists = await UserService.emailExists(data['email']);
        if (exists) return Response(409, body: 'Email allaqachon mavjud');

        final hashedPassword = PasswordUtil.hash(data['password']);
        final userId = await UserService.create(
          name: data['name'],
          email: data['email'],
          password: hashedPassword,
        );

        final token = JwtUtil.generateToken(userId, 'user');
        return Response.ok(jsonEncode({'token': token, 'message': "Muvaffaqiyatli o'tdingiz"}),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: 'Server xatosi: $e');
      }
    });

    // 2. ADMIN LOGIN
    router.post('/admin/login', (Request req) async {
      // ... (Sizning mavjud admin login kodingiz)
      // Yuqoridagi kodingizni o'zgarishsiz qoldiring
    });

    // 3. ODDIY LOGIN
    router.post('/user/login', (Request req) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);
        final user = await UserService.findByEmail(data['email']);

        if (user == null || !PasswordUtil.verify(data['password'], user['password'])) {
          return Response.forbidden(jsonEncode({'error': 'Email yoki parol xato'}));
        }

        final token = JwtUtil.generateToken(user['id'], user['role']);
        return Response.ok(jsonEncode({'token': token, 'role': user['role']}),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: 'Login xatosi: $e');
      }
    });

    // --- YANGI QO'SHILGAN QISMLAR ---

    // 4. PASSWORD RESET - EMAILNI TEKSHIRISH
    router.post('/user/reset-password/request', (Request req) async {
      try {
        final data = jsonDecode(await req.readAsString());
        final String email = (data['email'] ?? '').toString().trim();

        if (email.isEmpty) {
          return Response.badRequest(body: jsonEncode({'error': 'Email kiritilishi shart'}));
        }

        final user = await UserService.findByEmail(email);

        if (user == null) {
          return Response.notFound(
            jsonEncode({'error': 'Bunday email bilan foydalanuvchi topilmadi'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Bu yerda foydalanuvchiga ruxsat beramiz (Amalda bu yerda emailga kod yuboriladi)
        return Response.ok(
          jsonEncode({'message': 'Email tasdiqlandi. Endi yangi parolni kiriting.'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': 'Xato yuz berdi: $e'}));
      }
    });

    // 5. PASSWORD RESET - YANGI PAROLNI SAQLASH
    router.post('/user/reset-password/confirm', (Request req) async {
      try {
        final data = jsonDecode(await req.readAsString());
        final String email = (data['email'] ?? '').toString().trim();
        final String newPassword = (data['password'] ?? '').toString();
        final String confirmPassword = (data['confirm_password'] ?? '').toString();

        // 1. Ma'lumotlar to'liqligini tekshirish
        if (email.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
          return Response.badRequest(body: jsonEncode({'error': 'Barcha maydonlarni to\'ldiring'}));
        }

        // 2. Parollar mosligini tekshirish
        if (newPassword != confirmPassword) {
          return Response.badRequest(body: jsonEncode({'error': 'Parollar bir-biriga mos kelmadi'}));
        }

        // 3. Foydalanuvchini topish
        final user = await UserService.findByEmail(email);
        if (user == null) {
          return Response.notFound(jsonEncode({'error': 'Foydalanuvchi topilmadi'}));
        }

        // 4. Parolni xesh qilish va bazada yangilash
        final hashedPassword = PasswordUtil.hash(newPassword);
        await UserService.updatePassword(user['id'], hashedPassword);

        return Response.ok(
          jsonEncode({'message': 'Parol muvaffaqiyatli yangilandi. Endi login qilishingiz mumkin.'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': 'Server xatosi: $e'}));
      }
    });

    return router;
  }
}