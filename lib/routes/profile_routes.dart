  import 'dart:convert';
  import 'package:shelf/shelf.dart';
  import 'package:shelf_router/shelf_router.dart';

  import '../services/user_service.dart';
  import '../utils/password.dart';

  class ProfileRoutes {
    Router get router {
      final router = Router();

      // 1. PROFIL MA'LUMOTLARINI OLISH
      router.get('/user/me', (Request req) async {
        try {
          // Middleware'dan kelayotgan userId (yoki user_id)
          final userId = req.context['userId'] as int;

          final user = await UserService.getById(userId);

          if (user == null) {
            return Response.notFound(jsonEncode({'error': 'Foydalanuvchi topilmadi'}));
          }

          return Response.ok(
            jsonEncode(user),
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e) {
          return Response.internalServerError(body: 'Xato: $e');
        }
      });

      // 2. ISMNI YANGILASH
      router.put('/user/name', (Request req) async {
        final userId = req.context['userId'] as int;
        final data = jsonDecode(await req.readAsString());

        await UserService.updateName(userId, data['name']);
        return Response.ok(jsonEncode({'message': 'Name updated'}));
      });

      // 3. PAROLNI YANGILASH
      router.put('/user/password', (Request req) async {
        final userId = req.context['userId'] as int;
        final data = jsonDecode(await req.readAsString());

        final hashed = PasswordUtil.hash(data['new_password']);
        await UserService.updatePassword(userId, hashed);

        return Response.ok(jsonEncode({'message': 'Password updated'}));
      });

      return router;
    }
  }