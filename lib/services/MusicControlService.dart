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
    List<MusicInfoModel> mims =
        musicInfoModels.getRange(0, musicInfoModels.length).toList();
    mims.removeWhere((music) {
      return music.type == MusicInfoModel.TYPE_FOLD;
    });
    int offset = musicInfoModels.length - mims.length;

    print("offset:offset:offset:offset:offset:offset:$offset");

    Provider.of<MusicInfoData>(context, listen: false).setMusicInfoList(mims);
    Provider.of<MusicInfoData>(context, listen: false)
        .setPlayIndex(index - offset);
    eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
  }
}
