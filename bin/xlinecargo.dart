import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import 'package:xlinecargo/config/database.dart';
import 'package:xlinecargo/middleware/auth_middleware.dart';
import 'package:xlinecargo/routes/admin_routes.dart';
import 'package:xlinecargo/routes/auth_routes.dart';
import 'package:xlinecargo/routes/order_routes.dart';
import 'package:xlinecargo/routes/profile_routes.dart';
import 'package:xlinecargo/services/user_service.dart';
import 'package:xlinecargo/utils/password.dart';

void main() async {
  await Database.connect();

  // Admin borligini tekshirish va yaratish
  if (!await UserService.emailExists('admin')) {
    print('⚠️ Admin user topilmadi. Yaratilmoqda...');
    final hash = PasswordUtil.hash('admin123');
    await UserService.create(
      name: 'Admin',
      email: 'admin',
      password: hash,
      role: 'admin',
    );
    print('✅ Admin user yaratildi: Login: admin, Parol: admin123');
  }

  final apiRouter = Router();

  // 1. Ochiq yo'llar (Login, Register)
  apiRouter.mount('/auth/', AuthRoutes().router);

  // 2. Buyurtmalar (OrderRoutes ichidagi barcha yo'llar uchun)
  // Eslatma: OrderRoutes ichida /user/... va /admin/... bor
  apiRouter.mount('/orders/', Pipeline()
      .addMiddleware(authMiddleware())
      .addHandler(OrderRoutes().router));

  // 3. Profil
  apiRouter.mount('/profile/', Pipeline()
      .addMiddleware(authMiddleware())
      .addHandler(ProfileRoutes().router));

  // 4. Admin (AdminRoutes uchun maxsus)
  apiRouter.mount('/admin/', Pipeline()
      .addMiddleware(authMiddleware(adminOnly: true))
      .addHandler(AdminRoutes().router));

  // 5. Admin Panel (Web Interface)
  apiRouter.mount('/admin-panel/', createStaticHandler(
    'lib/admin_panel/',
    defaultDocument: 'index.html',
  ));

  // Swagger/Static fayllar
  final staticHandler = createStaticHandler(
    'lib/swagger/',
    defaultDocument: 'index.html',
  );

  final app = Cascade()
      .add(staticHandler)
      .add(apiRouter)
      .handler;

  // Port va Host sozlamalari
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(app, '0.0.0.0', port);

  print('✅ Server ishga tushdi: http://0.0.0.0:$port');
  print('🚀 Siz so\'ragan Order API manzillari:');
  print('   - GET  /orders/user/all-order');
  print('   - POST /orders/user/create');
  print('   - GET  /orders/user/track/<code>');
  print('   - GET  /orders/admin/order/all');
}