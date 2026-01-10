import '../config/database.dart';

class OrderService {
  // 1. Yangi buyurtma yaratish
  static Future<void> create({
    required int userId,
    required String product,
    required int quantity,
    required String trackCode,
  }) async {
    await Database.connection.query(
      '''
      INSERT INTO orders (user_id, product_name, quantity, track_code)
      VALUES (@userId, @product, @quantity, @track)
      ''',
      substitutionValues: {
        'userId': userId,
        'product': product,
        'quantity': quantity,
        'track': trackCode,
      },
    );
  }

  // 2. Ma'lum bir foydalanuvchining buyurtmalarini olish
  static Future<List<Map<String, dynamic>>> getByUserId(int userId) async {
    final result = await Database.connection.query(
      'SELECT id, product_name, quantity, track_code, status, created_at FROM orders WHERE user_id = @userId ORDER BY created_at DESC',
      substitutionValues: {'userId': userId},
    );

    return result.map((e) => {
      'id': e[0],
      'product': e[1],
      'quantity': e[2],
      'track_code': e[3],
      'status': e[4],
      'created_at': e[5].toString(),
    }).toList();
  }

  // 3. Admin uchun barcha buyurtmalarni olish
  static Future<List<Map<String, dynamic>>> getAll() async {
    final result = await Database.connection.query(
      'SELECT id, product_name, quantity, track_code, status, created_at, user_id FROM orders ORDER BY created_at DESC',
    );

    return result.map((e) => {
      'id': e[0],
      'product': e[1],
      'quantity': e[2],
      'track_code': e[3],
      'status': e[4],
      'created_at': e[5].toString(),
      'user_id': e[6],
    }).toList();
  }

  // 4. Track kodi orqali qidirish
  static Future<Map<String, dynamic>?> track(String code) async {
    final result = await Database.connection.query(
      'SELECT product_name, quantity, status FROM orders WHERE track_code = @code',
      substitutionValues: {'code': code},
    );

    if (result.isEmpty) return null;

    return {
      'product': result.first[0],
      'quantity': result.first[1],
      'status': result.first[2],
    };
  }

  // 5. Statusni yangilash
  static Future<void> updateStatus(int orderId, String status) async {
    await Database.connection.query(
      'UPDATE orders SET status = @status WHERE id = @id',
      substitutionValues: {'status': status, 'id': orderId},
    );
  }
}