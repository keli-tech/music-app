import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class MusicInfo {
  static const TABLE = 'music_info';
  static const COL_KEY = 'key';
  static const COL_VAL = 'value';

  Future _onDatabaseCreate(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS `$TABLE` (
        `$COL_KEY` VARCHAR(1024) PRIMARY KEY,
        `$COL_VAL` TEXT NOT NULL
      )
      ''');
  }

  Future<Database> _initDatabase() async {
    var docDir = await getApplicationDocumentsDirectory();
    var path = join(docDir.path, _dbName);
    return await openDatabase(
      path,
      onOpen: _onDatabaseCreate,
    );
  }

  MusicInfo(String dbName) {
    if (dbName == null) {
      _dbName = 'cookie.db';
    } else {
      _dbName = dbName;
    }
    _initDatabase().then((db) {
      _database = db;
    });
  }

  Future<bool> init() async {
    _database = await _initDatabase();
    if (_database != null) {
      return true;
    }
    return false;
  }

  // SQLite database instance
  Database _database;

  // SQLite database name
  String _dbName;

  String get dbName {
    return _dbName;
  }

  Future<int> put(String key, String value) async {
    return await _database.rawInsert(
        'REPLACE INTO `$TABLE`(`$COL_KEY`, `$COL_VAL`) VALUES(?, ?)',
        [key, value]);
  }

  Future<int> putAll(Map<String, String> rows) async {
    return await _database.transaction((txn) async {
      rows.forEach((key, value) {
        txn.rawInsert(
            'REPLACE INTO `$TABLE`(`$COL_KEY`, `$COL_VAL`) VALUES(?, ?)',
            [key, value]);
      });
    });
  }

  Future<int> erase(String key) async {
    return await _database
        .delete(TABLE, where: '`$COL_KEY` = ?', whereArgs: [key]);
  }

  Future<int> eraseAll(List<String> keys) async {
    return await _database.transaction((txn) async {
      for (var key in keys) {
        txn.delete(TABLE, where: '`$COL_KEY` = ?', whereArgs: [key]);
      }
    });
  }

  Future<int> queryRowCount() async {
    return Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM `$TABLE`'));
  }

  Future<String> query(String key) async {
    var maps = await _database.query(TABLE,
        columns: [COL_VAL], where: '`$COL_KEY` = ?', whereArgs: [key]);
    if (maps.length > 0 && maps[0].containsKey(COL_VAL)) {
      return maps[0][COL_VAL];
    }
    return null;
  }

  Future<Map<String, String>> queryAll(List<String> keys) async {
    var size = keys.length;
    var sql = 'SELECT * FROM `$TABLE` WHERE `$COL_KEY` IN (';
    for (var i = 0; i < size; i++) {
      sql += '?,';
    }
    sql = sql.substring(0, sql.length - 1);
    sql += ')';

    var maps = await _database.rawQuery(sql, keys);

    if (maps.length > 0) {
      var map = Map();
      for (var mp in maps) {
        if (mp.containsKey(COL_KEY) && map.containsKey(COL_VAL)) {
          map[mp[COL_KEY]] = mp[COL_VAL];
        }
      }
      return map;
    }
    return null;
  }
}
