import 'dart:io';
import 'package:postgres/postgres.dart';

class Database {
  static late PostgreSQLConnection connection;

  static Future<void> connect() async {
    // Environment o'zgaruvchilarni o'qish yoki default qiymatlarni ishlatish
    final dbHost = Platform.environment['DB_HOST'] ?? 'localhost';
    final dbPort = int.parse(Platform.environment['DB_PORT'] ?? '5432');
    final dbName = Platform.environment['DB_NAME'] ?? 'app_db';
    final dbUser = Platform.environment['DB_USER'] ?? 'postgres';
    final dbPassword = Platform.environment['DB_PASSWORD'] ?? 'postgres123';

    connection = PostgreSQLConnection(
      dbHost,
      dbPort,
      dbName,
      username: dbUser,
      password: dbPassword,
    );
    await connection.open();
    print('✅ PostgreSQL connected ($dbHost)');
  }
}
