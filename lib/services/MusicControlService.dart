import 'package:flutter/cupertino.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/services/EventBus.dart';
import 'package:provider/provider.dart';

class MusicControlService {
  static play(
      BuildContext context, List<MusicInfoModel> musicInfoModels, int index) {
    if (musicInfoModels.length <= 0) {
      return;
    }

    // 播放列表
    List<MusicInfoModel> mims =
        musicInfoModels.getRange(0, musicInfoModels.length).toList();

    // 过滤文件夹
    mims.removeWhere((music) {
      return music.type == MusicInfoModel.TYPE_FOLD;
    });
    // 文件夹数量
    int offset = musicInfoModels.length - mims.length;

    var playIndex = index - offset;

    // 设置播放列表
    Provider.of<MusicInfoData>(context, listen: false).setMusicInfoList(mims);
    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(playIndex);

    // fire
    eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
  }
}
