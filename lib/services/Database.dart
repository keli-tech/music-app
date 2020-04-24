import 'dart:async';
import 'dart:io';

import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/ClientModel.dart';
import '../models/MusicInfoModel.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Logger logger = new Logger("");

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "keli_music9.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS music_info ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "path TEXT,"
          "fullpath TEXT,"
          "type TEXT,"
          "syncstatus BIT,"
          "title TEXT,"
          "artist TEXT,"
          "album TEXT,"
          "sort INTEGER,"
          "filesize TEXT,"
          "sourcepath TEXT,"
          "extra TEXT,"
          "updatetime INTEGER"
          ")");

      await db.execute("create table if not exists music_play_list ("
          "id INTEGER primary key autoincrement,"
          "type TEXT,"
          "name TEXT,"
          "artist TEXT,"
          "year TEXT,"
          "sort INTEGER,"
          "imgpath TEXT,"
          "updatetime INTEGER"
          ")");

      await db.execute(
          "create unique index if not exists mid ON music_play_list (name, type, artist)");

      await db.execute(
          "INSERT Into music_play_list (id,artist,name,type,sort,imgpath) VALUES (1, '-', '我喜欢的音乐', 'fav', 1000, '')");

      await db.execute("create table if not exists music_play_list_info("
          "mpl_id INTEGER,"
          "mi_id  INTEGER,"
          "updatetime INTEGER"
          ")");

      await db.execute(
          "create unique index if not exists mid ON music_play_list_info (mpl_id, mi_id)");
    });
  }

  //根据播放列表
  Future<MusicPlayListModel> getMusicPlayListById(int mplID) async {
    final db = await database;

    var res = await db.query("music_play_list", where: "id = ?", whereArgs: [
      mplID,
    ]);

    return res.isNotEmpty ? MusicPlayListModel.fromMap(res.first) : null;
  }

  //根据播放列表
  Future<List<MusicPlayListModel>> getMusicPlayList() async {
    final db = await database;

    var res = await db.query("music_play_list",
        where: "type = ?",
        orderBy: "sort desc",
        whereArgs: [
          MusicPlayListModel.TYPE_PLAY_LIST,
        ]);

    List<MusicPlayListModel> list = res.isNotEmpty
        ? res.map((c) => MusicPlayListModel.fromMap(c)).toList()
        : [];
    return list;
  }

  //根据播放列表
  Future<List<MusicPlayListModel>> getMusicPlayListByType(String type) async {
    final db = await database;

    var res = await db.query("music_play_list",
        where: "type = ?",
        orderBy: "updatetime desc, sort desc",
        whereArgs: [
          type,
          MusicPlayListModel.TYPE_FAV,
        ]);

    List<MusicPlayListModel> list = res.isNotEmpty
        ? res.map((c) => MusicPlayListModel.fromMap(c)).toList()
        : [];
    return list;
  }

  //根据专辑
  Future<List<Map<String, String>>> getArtists() async {
    final db = await database;

    List<Map<String, String>> list = [];
    try {
      var res = await db.rawQuery(
          "select artist, count(1) as nums "
          "from music_info "
          "where type != ? "
          "group by artist "
          "order by nums desc",
          [MusicInfoModel.TYPE_FOLD]);
      list = res.isNotEmpty
          ? res.map((c) {
              return {
                "artist": c["artist"].toString(),
                "nums": c["nums"].toString(),
              };
            }).toList()
          : [];
    } catch (error) {
      print('failed');
      print(error);
    }
    return list;
  }

  //根据专辑
  Future<List<MusicPlayListModel>> getAlbum() async {
    final db = await database;

    var res = await db.query("music_play_list",
        where: "type = ? ",
        orderBy: "sort desc",
        whereArgs: [
          MusicPlayListModel.TYPE_ALBUM,
        ]);

    List<MusicPlayListModel> list = res.isNotEmpty
        ? res.map((c) => MusicPlayListModel.fromMap(c)).toList()
        : [];
    return list;
  }

  //更新数据
  Future<int> updateMusicPlayList(int mplID, updateValue) async {
    final db = await database;

    var res = await db
        .update("music_play_list", updateValue, where: " id = ?", whereArgs: [
      mplID,
    ]);

    print("sdfdsf" + res.toString());

    return res;
  }

  Future<int> newMusicPlayList(MusicPlayListModel newMusicPlayListModel) async {
    final db = await database;
    int retID;

    await db.transaction((txn) async {
      var res = await txn.query("music_play_list",
          where: " name = ? and artist = ? and type = ?",
          orderBy: "sort desc",
          whereArgs: [
            newMusicPlayListModel.name,
            newMusicPlayListModel.artist,
            newMusicPlayListModel.type,
          ]);

      List<MusicInfoModel> list = res.isNotEmpty
          ? res.map((c) => MusicInfoModel.fromMap(c)).toList()
          : [];

      if (list.length > 0) {
        retID = list.first.id;
      } else {
        retID = await txn.rawInsert(
            "INSERT Into music_play_list (name,artist,year,type,sort,imgpath,updatetime)"
            " VALUES (?,?,?,?,?,?,?) ON CONFLICT(name, type, artist) DO UPDATE SET name = name",
            [
              newMusicPlayListModel.name,
              newMusicPlayListModel.artist,
              newMusicPlayListModel.year,
              newMusicPlayListModel.type,
              newMusicPlayListModel.sort,
              newMusicPlayListModel.imgpath,
              newMusicPlayListModel.updatetime,
            ]);
      }
    });
    return retID;
  }

  // 删除 music play list
  // 删除 列表， 删除关系
  deleteMusicPlayList(int id) async {
    try {
      final db = await database;
      logger.info("delete play list id: $id");

      List<MusicInfoModel> musicInfos = await getMusicInfoByPlayListId(id);
      if (musicInfos.length > 0) {
        List<int> ids = musicInfos.map((f) {
          return f.id;
        }).toList();
      }

      var raw = await db.rawDelete(
          "delete from music_play_list_info where  mpl_id = ?", [id]);

      raw =
          await db.delete("music_play_list", where: "id = ?", whereArgs: [id]);

      if (raw > 0) {
        return musicInfos;
      } else {
        return [];
      }
    } catch (error) {
      logger.warning(error);
      return [];
    }
  }

  //我喜欢的音乐文件列表
  Future<List<MusicInfoModel>> getFavMusicInfoList() async {
    final db = await database;

    var res = await db.rawQuery(
        "select t3.* "
        "from music_play_list_info as t1 "
        "join music_play_list as t2 on t1.mpl_id = t2.id "
        "join music_info as t3 on t1.mi_id = t3.id "
        "where t2.id = ? and t2.type = ? order by t1.updatetime desc",
        [
          MusicPlayListModel.FAVOURITE_PLAY_LIST_ID,
          MusicPlayListModel.TYPE_FAV,
        ]);
    List<MusicInfoModel> list = res.isNotEmpty
        ? res.map((c) => MusicInfoModel.fromMap(c)).toList()
        : [];
    return list;
  }

  //根据歌单获取音乐列表
  Future<List<MusicInfoModel>> getMusicInfoByPlayListId(int plid) async {
    final db = await database;

    var res = await db.rawQuery(
        "select t3.* "
        "from music_play_list_info as t1 "
        "join music_play_list as t2 on t1.mpl_id = t2.id "
        "join music_info as t3 on t1.mi_id = t3.id "
        "where t2.id = ? order by t1.updatetime desc",
        [
          plid,
        ]);
    List<MusicInfoModel> list = res.isNotEmpty
        ? res.map((c) => MusicInfoModel.fromMap(c)).toList()
        : [];
    return list;
  }

  Future<int> addMusicToFavPlayList(int mid) async {
    var plid = MusicPlayListModel.FAVOURITE_PLAY_LIST_ID;
    return addMusicToPlayList(plid, mid);
  }

  //从歌单中删除音乐
  Future<int> deleteMusicFromFavPlayList(int mid) async {
    var plid = MusicPlayListModel.FAVOURITE_PLAY_LIST_ID;
    return deleteMusicFromPlayList(plid, mid);
  }

  //添加音乐到歌单
  Future<int> addMusicToPlayList(int plid, int mid) async {
    final db = await database;
    var raw = await db.rawInsert(
        "INSERT Into music_play_list_info (mpl_id,mi_id)"
        " VALUES (?,?)",
        [
          plid,
          mid,
        ]);
    logger.info("insert plid:$plid, mid:$mid");
    return raw;
  }

  //从歌单中删除音乐
  Future<int> deleteMusicFromPlayList(int plid, int mid) async {
    final db = await database;
    var raw = await db.rawDelete(
        "delete from music_play_list_info where mpl_id=? and mi_id=?", [
      plid,
      mid,
    ]);
    logger.info("delete plid:$plid, mid:$mid");
    return raw;
  }

  newMusicInfo(MusicInfoModel newMusicInfo) async {
    final db = await database;
    var raw = await db.rawInsert(
        "INSERT Into music_info (name,path,fullpath,type,syncstatus,title,artist,album,filesize,sourcepath,sort,updatetime)"
        " VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
        [
          newMusicInfo.name,
          newMusicInfo.path,
          newMusicInfo.fullpath,
          newMusicInfo.type,
          newMusicInfo.syncstatus,
          newMusicInfo.title,
          newMusicInfo.artist,
          newMusicInfo.album,
          newMusicInfo.filesize,
          newMusicInfo.sourcepath,
          newMusicInfo.sort,
          newMusicInfo.updatetime,
        ]);
    return raw;
  }

  //根据路径获取音乐列表
  Future<List<MusicInfoModel>> getMusicInfoByPath(String musicPath) async {
    final db = await database;

    var res = await db.query("music_info",
        where: "path = ? ",
        orderBy: " sort asc, updatetime desc ",
        whereArgs: [musicPath]);

    List<MusicInfoModel> list = res.isNotEmpty
        ? res.map((c) => MusicInfoModel.fromMap(c)).toList()
        : [];
    return list;
  }

  Future<MusicInfoModel> getMusic(int id) async {
    final db = await database;
    var res = await db.query(
      "music_info",
      where: "id = ?",
      whereArgs: [id],
    );
    return res.isNotEmpty ? MusicInfoModel.fromMap(res.first) : null;
  }

  Future<MusicInfoModel> getFoldByPathName(String path, String name) async {
    final db = await database;
    var res = await db.query("music_info",
        where: "path =? and name = ?", whereArgs: [path, name]);
    return res.isNotEmpty ? MusicInfoModel.fromMap(res.first) : null;
  }

  deleteMusic(int id) async {
    final db = await database;
    return db.delete("music_info", where: "id = ?", whereArgs: [id]);
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
}
