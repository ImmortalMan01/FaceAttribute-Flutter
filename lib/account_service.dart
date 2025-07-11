import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'account.dart';

class AccountService {
  static Future<Database> _database() async {
    return openDatabase(
      p.join(await getDatabasesPath(), 'accounts.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE account(username TEXT PRIMARY KEY, password TEXT, isAdmin INTEGER)');
      },
      version: 1,
    );
  }

  static Future<List<Account>> getAccounts() async {
    final db = await _database();
    final List<Map<String, dynamic>> maps = await db.query('account');
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  static Future<void> insertAccount(Account account) async {
    final db = await _database();
    await db.insert('account', account.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
