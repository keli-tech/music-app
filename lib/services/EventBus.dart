//EventBus.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class AudioPlayerEvent {
  AudioPlayerState audioPlayerState;

  AudioPlayerEvent(this.audioPlayerState);
}

enum MusicPlayerEvent {
  play,
  stop,
  last,
  next,
}

class MusicPlayerEventBus {
  MusicPlayerEvent musicPlayerEvent;

  MusicPlayerEventBus(this.musicPlayerEvent);
}
