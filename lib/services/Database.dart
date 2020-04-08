import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/ClientModel.dart';
import '../models/MusicInfoModel.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "keli_music.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS MusicInfoModel ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "path TEXT,"
          "fullpath TEXT,"
          "type TEXT,"
          "syncstatus BIT"
          ")");
      await db.execute("CREATE TABLE IF NOT EXISTS Client ("
          "id INTEGER PRIMARY KEY,"
          "first_name TEXT,"
          "last_name TEXT,"
          "blocked BIT"
          ")");
    });
  }

  newMusicInfo(MusicInfoModel newMusicInfo) async {
    final db = await database;
    var raw = await db.rawInsert(
        "INSERT Into MusicInfoModel (name,path,fullpath,type,syncstatus)"
        " VALUES (?,?,?,?,?)",
        [
          newMusicInfo.name,
          newMusicInfo.path,
          newMusicInfo.fullpath,
          newMusicInfo.type,
          newMusicInfo.syncstatus
        ]);
    return raw;
  }

  Future<List<MusicInfoModel>> getMusicInfoByPath(String musicPath) async {
    final db = await database;

    var res = await db
        .query("MusicInfoModel", where: "path = ? ", whereArgs: [musicPath]);

    List<MusicInfoModel> list = res.isNotEmpty
        ? res.map((c) => MusicInfoModel.fromMap(c)).toList()
        : [];
    return list;
  }

  Future<MusicInfoModel> getMusic(int id) async {
    final db = await database;
    var res =
        await db.query("MusicInfoModel", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? MusicInfoModel.fromMap(res.first) : null;
  }

  Future<MusicInfoModel> getFoldByPathName(String path, String name) async {
    final db = await database;
    var res =
    await db.query("MusicInfoModel", where: "path =? and name = ?", whereArgs: [path, name]);
    return res.isNotEmpty ? MusicInfoModel.fromMap(res.first) : null;
  }

  deleteMusic(int id) async {
    final db = await database;
    return db.delete("MusicInfoModel", where: "id = ?", whereArgs: [id]);
  }

  syncOrNot(MusicInfoModel musicInfoModel) async {
    final db = await database;
    MusicInfoModel blocked = MusicInfoModel(
        id: musicInfoModel.id,
        name: musicInfoModel.name,
        path: musicInfoModel.path,
        fullpath: musicInfoModel.fullpath,
        type: musicInfoModel.type,
        syncstatus: !musicInfoModel.syncstatus);
    var res = await db.update("Client", blocked.toMap(),
        where: "id = ?", whereArgs: [musicInfoModel.id]);
    return res;
  }

  newClient(Client newClient) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Client");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Client (id,first_name,last_name,blocked)"
        " VALUES (?,?,?,?)",
        [id, newClient.firstName, newClient.lastName, newClient.blocked]);
    return raw;
  }

  blockOrUnblock(Client client) async {
    final db = await database;
    Client blocked = Client(
        id: client.id,
        firstName: client.firstName,
        lastName: client.lastName,
        blocked: !client.blocked);
    var res = await db.update("Client", blocked.toMap(),
        where: "id = ?", whereArgs: [client.id]);
    return res;
  }

  updateClient(Client newClient) async {
    final db = await database;
    var res = await db.update("Client", newClient.toMap(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  getClient(int id) async {
    final db = await database;
    var res = await db.query("Client", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Client.fromMap(res.first) : null;
  }

  Future<List<Client>> getBlockedClients() async {
    final db = await database;

    // var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    var res = await db.query("Client", where: "blocked = ? ", whereArgs: [1]);

    List<Client> list =
        res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    var res = await db.query("Client");
    List<Client> list =
        res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  deleteClient(int id) async {
    final db = await database;
    return db.delete("Client", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Client");
  }
}