class MusicInfoModel {
  final int id;
  final String name;
  final String path;
  final String fullpath;
  final String type;
  final bool syncstatus;

  MusicInfoModel(
      {this.id,
      this.name,
      this.path,
      this.fullpath,
      this.type,
      this.syncstatus});

  factory MusicInfoModel.fromMap(Map<String, dynamic> json) =>
      new MusicInfoModel(
        id: json["id"],
        name: json["name"],
        path: json["path"],
        fullpath: json["fullpath"],
        type: json["type"],
        syncstatus: json["syncstatus"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "path": path,
        "fullpath": fullpath,
        "type": type,
        "syncstatus": syncstatus,
      };

  Map toJson() {
    Map map = new Map();
    map["id"] = this.id;
    map["name"] = this.name;
    map["path"] = this.path;
    map["fullpath"] = this.fullpath;
    map["type"] = this.type;
    map["syncstatus"] = this.syncstatus;
    return map;
  }
}
