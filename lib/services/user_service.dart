import '../config/database.dart';

class UserService {
  // 1. Email mavjudligini tekshirish
  static Future<bool> emailExists(String email) async {
    final result = await Database.connection.query(
      'SELECT id FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );
    return result.isNotEmpty;
  }
  static Future<Map<String, dynamic>?> getById(int id) async {
    final result = await Database.connection.query(
      'SELECT id, name, email, role FROM users WHERE id = @id',
      substitutionValues: {'id': id},
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return {
      'id': row[0],
      'name': row[1],
      'email': row[2],
      'role': row[3],
    };
  }
  // 2. Yangi foydalanuvchi yaratish
  static Future<int> create({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await Database.connection.query(
      '''
      INSERT INTO users (name, email, password, role)
      VALUES (@name, @email, @password, 'user')
      RETURNING id
      ''',
      substitutionValues: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    return result.first[0] as int;
  }

  // 3. Email orqali foydalanuvchini topish
  static Future<Map<String, dynamic>?> findByEmail(String email) async {
    final result = await Database.connection.query(
      'SELECT id, name, email, password, role FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return {
      'id': row[0],
      'name': row[1],
      'email': row[2],
      'password': row[3],
      'role': row[4],
    };
  }

  // 4. Ismni yangilash
  static Future<void> updateName(int userId, String name) async {
    await Database.connection.query(
      'UPDATE users SET name = @name WHERE id = @id',
      substitutionValues: {
        'name': name,
        'id': userId,
      },
    );
  }

  // 5. Parolni yangilash
  static Future<void> updatePassword(int userId, String hashedPassword) async {
    await Database.connection.query(
      'UPDATE users SET password = @password WHERE id = @id',
      substitutionValues: {
        'password': hashedPassword,
        'id': userId,
      },
    );
  }

  // 6. Barcha foydalanuvchilarni olish
  static Future<List<Map<String, dynamic>>> getAll() async {
    final result = await Database.connection.query(
        'SELECT id, name, email, role FROM users'
    );

    return result.map((row) => {
      'id': row[0],
      'name': row[1],
      'email': row[2],
      'role': row[3],
    }).toList();
  }
}