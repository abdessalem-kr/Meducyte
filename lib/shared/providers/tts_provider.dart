import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/services/edge_tts_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum TtsState { playing, stopped, paused, loading }

enum TtsSource { edge, openai, native }

class TtsStatus {
  final TtsState state;
  final int? currentParagraphIndex;
  final double speechRate;
  final TtsSource source;

  TtsStatus({
    this.state = TtsState.stopped,
    this.currentParagraphIndex,
    this.speechRate = 1.0,
    this.source = TtsSource.native,
  });

  TtsStatus copyWith({
    TtsState? state,
    int? Function()? currentParagraphIndex,
    double? speechRate,
    TtsSource? source,
  }) {
    return TtsStatus(
      state: state ?? this.state,
      currentParagraphIndex: currentParagraphIndex != null
          ? currentParagraphIndex()
          : this.currentParagraphIndex,
      speechRate: speechRate ?? this.speechRate,
      source: source ?? this.source,
    );
  }
}

class TtsNotifier extends StateNotifier<TtsStatus> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  final EdgeTtsService _edgeTts = EdgeTtsService();
  final Dio _dio = Dio();

  //Using the same API key as ChatRepository for consistency in this demo
  static const String _apiKey =
      "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";

  static const String _openAiUrl = "https://api.openai.com/v1/audio/speech";

  List<String> _paragraphs = [];
  int _currentIndex = -1;

  TtsNotifier() : super(TtsStatus()) {
    _initPlayers();
  }

  void _initPlayers() async {
    //OpenAI/Edge Player Init
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _handleCompletion();
      }
    });

    //Native TTS Init
    await _flutterTts.setLanguage("fr-FR");

    _flutterTts.setStartHandler(() {
      state = state.copyWith(state: TtsState.playing, source: TtsSource.native);
    });

    _flutterTts.setCompletionHandler(() {
      _handleCompletion();
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("Native TTS Error: $msg");
      stop();
    });

    _prepareBestNativeVoice();
  }

  Future<void> _prepareBestNativeVoice() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null) {
        List<Map<String, String>> frVoices = [];
        for (dynamic voice in voices) {
          if (voice is Map) {
            final locale = voice["locale"] as String?;
            final name = voice["name"] as String?;
            if (locale != null && locale.startsWith("fr-") && name != null) {
              frVoices.add({"name": name, "locale": locale});
            }
          }
        }
        if (frVoices.isNotEmpty) {
          frVoices.sort((a, b) {
            final nameA = a["name"]!.toLowerCase();
            final nameB = b["name"]!.toLowerCase();
            int scoreA = 0;
            int scoreB = 0;
            if (nameA.contains("premium") || nameA.contains("enhanced")) {
              scoreA += 2;
            }
            if (nameB.contains("premium") || nameB.contains("enhanced")) {
              scoreB += 2;
            }
            return scoreB.compareTo(scoreA);
          });
          await _flutterTts.setVoice(frVoices.first);
        }
      }
    } catch (_) {}
  }

  Future<void> startReading(List<String> paragraphs, {int startAt = 0}) async {
    _paragraphs = paragraphs;
    _currentIndex = startAt;
    await _speakCurrent();
  }

  Future<void> _speakCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _paragraphs.length) return;

    state = state.copyWith(
      state: TtsState.loading,
      currentParagraphIndex: () => _currentIndex,
    );

    final text = _paragraphs[_currentIndex];

    //1.Priority:Edge TTS(Free Neural AI)
    try {
      debugPrint(
        "TTS:Attempting Edge TTS for: ${text.substring(0, text.length > 20 ? 20 : text.length)}...",
      );
      final audioBytes = await _edgeTts.generateSpeech(
        text,
        voice: "fr-FR-HenriNeural",
        rate: state.speechRate,
      );

      if (audioBytes.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final file = File("${tempDir.path}/tts_current.mp3");
        await file.writeAsBytes(audioBytes);
        await _audioPlayer.setFilePath(file.path);
        state = state.copyWith(state: TtsState.playing, source: TtsSource.edge);
        await _audioPlayer.play();
        return;
      }
    } catch (e) {
      debugPrint("TTS:Edge TTS failed: $e.Moving to OpenAI.");
    }

    //2.Priority:OpenAI(Paid AI)
    try {
      if (_apiKey.startsWith("sk-")) {
        debugPrint("TTS:Attempting OpenAI API...");
        final response = await _dio.post(
          _openAiUrl,
          options: Options(
            headers: {
              "Authorization": "Bearer$_apiKey",
              "Content-Type": "application/json",
            },
            responseType: ResponseType.bytes,
            validateStatus: (status) => status == 200,
          ),
          data: {
            "model": "tts-1",
            "input": text,
            "voice": "onyx",
            "speed": state.speechRate,
          },
        );
        final tempDir = await getTemporaryDirectory();
        final file = File("${tempDir.path}/tts_current.mp3");
        await file.writeAsBytes(response.data);
        await _audioPlayer.setFilePath(file.path);
        state = state.copyWith(
          state: TtsState.playing,
          source: TtsSource.openai,
        );
        await _audioPlayer.play();
        return;
      }
    } catch (e) {
      debugPrint("TTS:OpenAI failed.Falling back to Native.");
    }

    //3.Fallback:Native Premium Voice
    debugPrint("TTS:Using Native High-Quality Voice Fallback");
    state = state.copyWith(source: TtsSource.native);
    await _flutterTts.setSpeechRate(
      state.speechRate * 0.5,
    ); //Native rate scale differs
    await _flutterTts.speak(text);
  }

  void _handleCompletion() {
    if (state.state == TtsState.stopped) return;

    if (_currentIndex < _paragraphs.length - 1) {
      _currentIndex++;
      _speakCurrent();
    } else {
      stop();
    }
  }

  Future<void> stop() async {
    state = TtsStatus(
      speechRate: state.speechRate,
    ); //Reset everything but preserve speed
    _currentIndex = -1;
    _paragraphs = [];
    await _audioPlayer.stop();
    await _flutterTts.stop();
  }

  Future<void> next() async {
    if (_currentIndex < _paragraphs.length - 1) {
      _currentIndex++;
      await _speakCurrent();
    }
  }

  Future<void> previous() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _speakCurrent();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    await _flutterTts.pause();
    state = state.copyWith(state: TtsState.paused);
  }

  Future<void> resume() async {
    if (state.state == TtsState.paused) {
      if (state.source == TtsSource.edge || state.source == TtsSource.openai) {
        await _audioPlayer.play();
      } else {
        //Native fallback doesn't have a perfect resume on all platforms,
        //we usually just trigger speak again for the current paragraph.
        await _speakCurrent();
      }
      state = state.copyWith(state: TtsState.playing);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.state == TtsState.playing) {
      await pause();
    } else if (state.state == TtsState.paused) {
      await resume();
    }
  }

  Future<void> seekRelative(Duration offset) async {
    if (state.source == TtsSource.edge || state.source == TtsSource.openai) {
      final currentPosition = _audioPlayer.position;
      final targetPosition = currentPosition + offset;
      await _audioPlayer.seek(targetPosition);
    }
    //Note:Native TTS doesn't typically support seeking within a speak call.
  }

  void setRate(double rate) {
    state = state.copyWith(speechRate: rate);
    if (state.source == TtsSource.edge || state.source == TtsSource.openai) {
      _audioPlayer.setSpeed(rate);
    } else {
      _flutterTts.setSpeechRate(rate * 0.5);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}

final ttsProvider = StateNotifierProvider.autoDispose<TtsNotifier, TtsStatus>((
  ref,
) {
  return TtsNotifier();
});
