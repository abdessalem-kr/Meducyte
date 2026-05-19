import 'package:just_audio/just_audio.dart';
import 'package:meducyte_app/export.dart';

class AmbientSoundNotifier extends StateNotifier<String?> {
  AmbientSoundNotifier() : super(null) {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();

  void _init() {
    _player.playerStateStream.listen((state) {
      debugPrint(
        "AmbientSound: PlayerState changed to ${state.processingState}, playing=${state.playing}",
      );
    });
    _player.playbackEventStream.listen(
      (event) {
        debugPrint("AmbientSound: PlaybackEvent: $event");
      },
      onError: (e, stack) {
        debugPrint("AmbientSound: PlaybackEvent ERROR: $e");
      },
    );
  }

  final Map<String, String> _soundUrls = {
    'Forest': 'https://www.soundjay.com/nature/forest-1.mp3',
    'Rain': 'https://www.soundjay.com/nature/rain-01.mp3',
    'Waves': 'https://www.soundjay.com/nature/ocean-wave-1.mp3',
    'Wind': 'https://www.soundjay.com/nature/wind-1.mp3',
    'Cafe': 'https://www.soundjay.com/ambient/coffee-shop-1.mp3',
    'Library': 'https://www.soundjay.com/ambient/library-ambience-1.mp3',
    'Brown Noise': 'https://www.soundjay.com/mechanical/brownian-noise-01.mp3',
  };

  Future<void> playSound(String? soundName) async {
    debugPrint("AmbientSound: User requested sound: $soundName");

    // Always stop first for a clean state
    await _player.stop();

    if (soundName == null || soundName == 'None') {
      debugPrint("AmbientSound: Resetting to None");
      state = null;
      return;
    }

    final url = _soundUrls[soundName];
    if (url != null) {
      try {
        debugPrint("AmbientSound: Attempting to play $soundName from $url");
        state = soundName; // Update state immediately for UI feedback

        final duration = await _player.setUrl(url);
        debugPrint("AmbientSound: Successfully set URL. Duration: $duration");

        await _player.setLoopMode(LoopMode.one);
        await _player.setVolume(1.0);

        debugPrint("AmbientSound: Calling play()");
        _player.play();
      } catch (e, stack) {
        debugPrint("AmbientSound ERROR: Failed to play $soundName: $e");
        debugPrint(stack.toString());
        state = null;
      }
    } else {
      debugPrint("AmbientSound WARNING: No URL found for $soundName");
    }
  }

  @override
  void dispose() {
    debugPrint("AmbientSound: Disposing provider");
    _player.dispose();
    super.dispose();
  }
}

final ambientSoundProvider =
    StateNotifierProvider<AmbientSoundNotifier, String?>((ref) {
      return AmbientSoundNotifier();
    });
