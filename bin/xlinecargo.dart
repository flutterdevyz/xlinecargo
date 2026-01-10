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

void main() async {
  await Database.connect();

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
  final server = await serve(app, '0.0.0.0', 8080);

  print('✅ Server ishga tushdi: http://localhost:8080');
  print('🚀 Siz so\'ragan Order API manzillari:');
  print('   - GET  /orders/user/all-order');
  print('   - POST /orders/user/create');
  print('   - GET  /orders/user/track/<code>');
  print('   - GET  /orders/admin/order/all');
}