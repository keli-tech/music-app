//EventBus.dart
import 'package:event_bus/event_bus.dart';
import 'package:just_audio/just_audio.dart';

EventBus eventBus = EventBus();

class PlayerStateEvent {
  PlayerState audioPlayerState;

  PlayerStateEvent(this.audioPlayerState);
}

enum MusicPlayerEvent {
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
