import 'package:postgres/postgres.dart';

class Database {
  static late PostgreSQLConnection connection;

  static Future<void> connect() async {
    connection = PostgreSQLConnection(
      'localhost',      // Docker konteyner hosti
      5432,             // Port
      'app_db',         // Bazaning nomi
      username: 'postgres',  // Docker run’da belgilangan user
      password: 'postgres123', // Docker run’da belgilangan parol
    );
    await connection.open();
    print('✅ PostgreSQL connected (Docker)');
  }
}
