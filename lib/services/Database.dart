import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/MusicInfoModel.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Logger _logger = new Logger("");

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

// 初始化数据库
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "keli_music.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      // 文件和文件夹信息表
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

      // 文件和文件夹信息表索引：类型 + name + type +path + artist + title;
      await db.execute(
          "create unique index if not exists mi_index ON music_info (name, type, artist, title, path)");

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

      // 云服务 Service
      await db.execute("create table if not exists cloud_service("
          "id INTEGER primary key autoincrement,"
          "name TEXT," // 云服务名称
          "assetspath TEXT," // 图标地址
          "type TEXT," // webdav 留着待定
          "url TEXT," // url webdav url
          "host TEXT," // host 其他服务器 host, 包括 http / https
          "port TEXT," // port 端口
          "account TEXT," // 账号
          "password TEXT," // 密码， 明文存储
          "signedin bit," // true: 登录， false: 登出, 登出保留账号，清除密码;
          "updatetime INT" // 更新日期；
          ")");

      await db.execute(
          "INSERT Into cloud_service (id,name,assetspath,signedin) VALUES "
          "(1, '坚果云', 'assets/images/cloudicon/jianguoyun.png', false),"
          "(2, 'NextCloud', 'assets/images/cloudicon/nextcloud.png', false),"
          "(3, 'WebDav', 'assets/images/cloudicon/webdav.png', false)"
//          "(4, '百度网盘', 'assets/images/cloudicon/baidu.png', false),"
//          "(5, 'OneDrive', 'assets/images/cloudicon/onedrive.png', false)"
          );

      _logger.info("数据初始化成功");
    });
  }

  //根据播放列表
  Future<MusicPlayListModel> getMusicPlayListById(int mplID) async {
    final db = await database;

    return db.query("music_play_list", where: "id = ?", whereArgs: [
      mplID,
    ]).then((value) => MusicPlayListModel.fromMap(value.first));
    // return res.isNotEmpty ? MusicPlayListModel.fromMap(res.first) : null;
  }

  // 查询艺术家获取列表
  Future<MusicPlayListModel> getMusicPlayListByArtistName(
      String artist, String name) async {
    final db = await database;

    return db
        .query("music_play_list", where: "artist = ? and name = ?", whereArgs: [
      artist,
      name,
    ]).then((value) => MusicPlayListModel.fromMap(value.first));
    // return res.isNotEmpty ? MusicPlayListModel.fromMap(res.first) : null;
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
    List<MusicPlayListModel> list = [];
    try {
      var res2 = await db.rawQuery(
          "select t2.id as id, count(1) as musiccount from music_play_list_info as t1 "
                  "inner join music_play_list as t2 on t1.mpl_id = t2.id "
                  "where t2.type = '" +
              MusicPlayListModel.TYPE_PLAY_LIST +
              "' group by t2.id ");

      Map<int, int> rr = new HashMap();
      if (res2.isNotEmpty) {
        res2.forEach((f) {
          if (f["id"] != null) {
            int fid = int.parse(f["id"].toString());
            rr[fid] = int.parse(f["musiccount"].toString());
          }
        });
      }
      if (res.isNotEmpty) {
        res.forEach((f) {
          var cc = MusicPlayListModel.fromMap(f);
          if (rr.containsKey(f["id"])) {
            cc.musiccount = rr[f["id"]];
          } else {
            cc.musiccount = 0;
          }
          list.add(cc);
        });
      }
    } catch (error) {
      print(error);
    }
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
        ]);

    List<MusicPlayListModel> list = res.isNotEmpty
        ? res.map((c) => MusicPlayListModel.fromMap(c)).toList()
        : [];
    return list;
  }

  // 根据专辑
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
      print(error);
    }
    return list;
  }

  // 获取所有专辑列表
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

    return res;
  }

// 新建播放列表
  Future<int> newMusicPlayList(MusicPlayListModel newMusicPlayListModel) async {
    final db = await database;

    return db.transaction((txn) async {
      var res = await txn.query("music_play_list",
          where: " name = ? and artist = ? and type = ?",
          orderBy: "sort desc",
          whereArgs: [
            newMusicPlayListModel.getName(),
            newMusicPlayListModel.getArtist(),
            newMusicPlayListModel.getType(),
          ]);

      List<MusicInfoModel> list = res.isNotEmpty
          ? res.map((c) => MusicInfoModel.fromMap(c)).toList()
          : [];

      if (list.length > 0) {
        return list.first.id;
      } else {
        return txn.rawInsert(
            "INSERT Into music_play_list (name,artist,year,type,sort,imgpath,updatetime)"
            " VALUES (?,?,?,?,?,?,?) ON CONFLICT(name, type, artist) DO UPDATE SET name = name",
            [
              newMusicPlayListModel.getName(),
              newMusicPlayListModel.getArtist(),
              newMusicPlayListModel.getYear(),
              newMusicPlayListModel.getType(),
              newMusicPlayListModel.getSort(),
              newMusicPlayListModel.getImgPath(),
              newMusicPlayListModel.getUpdateTime(),
            ]);
      }
    });
  }

  // 删除 music play list
  // 删除 列表， 删除关系
  deleteMusicPlayList(int id) async {
    try {
      final db = await database;
      _logger.info("delete play list id: $id");

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
      _logger.warning(error);
      return [];
    }
  }

  // 我喜欢的音乐文件列表
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
        "INSERT Into music_play_list_info (mpl_id,mi_id,updatetime)"
        " VALUES (?,?,?)",
        [
          plid,
          mid,
          new DateTime.now().millisecondsSinceEpoch,
        ]);
    _logger.info("insert plid:$plid, mid:$mid");
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
    _logger.info("delete plid:$plid, mid:$mid");
    return raw;
  }

  Future<int> newMusicInfo(MusicInfoModel newMusicInfo) async {
    final db = await database;

    var res = await db.rawQuery(
        "select count(1) as cc from music_info where name = '${newMusicInfo.name}' and path = '${newMusicInfo.path}'");
    if (res != null && res.length > 0 && res[0]['cc'].toString() != "0") {
      return 0;
    } else {
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
  }

  //根据路径获取音乐列表
  Future<List<MusicInfoModel>> getMusicInfoByArtist(String artist) async {
    final db = await database;

    var res = await db.query("music_info",
        where: "artist = ? ",
        orderBy: " sort asc, updatetime desc ",
        whereArgs: [artist]);

    List<MusicInfoModel> list = res.isNotEmpty
        ? res.map((c) => MusicInfoModel.fromMap(c)).toList()
        : [];
    return list;
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
    return await db.query(
      "music_info",
      where: "id = ?",
      whereArgs: [id],
    ).then((value) => MusicInfoModel.fromMap(value.first));
    // return res.isNotEmpty ? MusicInfoModel.fromMap(res.first) : null;
  }

  getFoldByPathName(String path, String name) async {
    final db = await database;

    var res = await db.query("music_info",
        where: "path =? and name = ?", whereArgs: [path, name]);
    return res.isNotEmpty ? MusicInfoModel.fromMap(res.first) : null;
  }

  Future<int> deleteMusic(int id) async {
    final db = await database;

    var musicInfo = await getMusic(id);

    var albumCountRes = await db.rawQuery(
        "select t1.mpl_id as mpl_id, count(*) as count from music_play_list_info as t1 "
                "join music_play_list as t2 on t1.mpl_id = t2.id "
                "where t1.mi_id = $id and t2.type ='" +
            MusicPlayListModel.TYPE_ALBUM +
            "' limit 1");

    var a = albumCountRes[0]["mpl_id"];
    // 只有一首歌，没有歌，则删除该播放列表
    if (((albumCountRes[0]["count"].toString() == "1" ||
            albumCountRes[0]["count"].toString() == "0")) &&
        albumCountRes[0]["mpl_id"] != null) {
      int mplId = int.parse(albumCountRes[0]["mpl_id"].toString());
      deleteMusicPlayList(mplId);
    }

    var res2 =
        db.delete("music_play_list_info", where: "mi_id = ?", whereArgs: [id]);
    var res = await db.delete("music_info", where: "id = ?", whereArgs: [id]);

    return res;
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
}
