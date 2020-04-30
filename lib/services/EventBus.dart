//EventBus.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class AudioPlayerEvent {
  AudioPlayerState audioPlayerState;

  AudioPlayerEvent(this.audioPlayerState);
}

enum MusicPlayerEvent {
  show_player,
  // 底部滑动播放栏控制上下
  scroll_play,
  // 其他播放
  play,
  stop,
  last,
  next,
}

class MusicPlayerEventBus {
  MusicPlayerEvent musicPlayerEvent;

  MusicPlayerEventBus(this.musicPlayerEvent);
}
