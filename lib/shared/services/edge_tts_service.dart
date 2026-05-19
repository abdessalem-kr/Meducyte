import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

class EdgeTtsService {
  static const String _wsUrl =
      "wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1"
      "?TrustedClientToken=6A5AA1D4EAFF4E9FB37E23D68491D6F4"
      "&ConnectionId=";

  final _uuid = const Uuid();

  Future<Uint8List> generateSpeech(
    String text, {
    String voice = "fr-FR-HenriNeural",
    double rate = 1.0,
  }) async {
    final requestId = _uuid.v4().replaceAll('-', '');
    final connectionId = _uuid.v4().replaceAll('-', '');
    final channel = WebSocketChannel.connect(Uri.parse(_wsUrl + connectionId));

    final completer = Completer<Uint8List>();
    final List<int> audioData = [];

    //Protocol requires sending config first
    final timestamp = DateTime.now().toUtc().toIso8601String();

    //1.Send Speech Config
    final configHeader =
        "X-Timestamp:$timestamp\r\n"
        "Content-Type:application/json;charset=utf-8\r\n"
        "Path:speech.config\r\n\r\n";
    final configBody = jsonEncode({
      "context": {
        "synthesis": {
          "audio": {
            "metadataoptions": {
              "sentenceBoundaryEnabled": "false",
              "wordBoundaryEnabled": "false",
            },
            "outputFormat": "audio-24khz-48kbitrate-mono-mp3",
          },
        },
      },
    });
    channel.sink.add(configHeader + configBody);

    //2.Send SSML
    final ssmlHeader =
        "X-RequestId:$requestId\r\n"
        "X-Timestamp:$timestamp\r\n"
        "Content-Type:application/ssml+xml\r\n"
        "Path:ssml\r\n\r\n";

    //Rate formatting:Edge expects percentage offset like+10%or-10%
    String rateStr = "0%";
    if (rate != 1.0) {
      int percent = ((rate - 1.0) * 100).toInt();
      rateStr = "${percent >= 0 ? "+" : ""}$percent%";
    }

    final ssmlBody =
        "<speak version='1.0'xmlns='http://www.w3.org/2001/10/synthesis'xml:lang='fr-FR'>"
        "<voice name='$voice'>"
        "<prosody rate='$rateStr'>$text</prosody>"
        "</voice></speak>";

    channel.sink.add(ssmlHeader + ssmlBody);

    channel.stream.listen(
      (message) {
        if (message is List<int>) {
          //Binary message:Find the start of audio(after the header)
          //Edge binary messages have a 2-byte header(length of the text header that follows)
          int headerLength = (message[0] << 8) | message[1];
          //After the text header(which starts at index 2),the audio data begins
          audioData.addAll(message.sublist(2 + headerLength));
        } else if (message is String) {
          if (message.contains("Path:turn.end")) {
            channel.sink.close();
            completer.complete(Uint8List.fromList(audioData));
          }
        }
      },
      onError: (err) {
        completer.completeError(err);
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(Uint8List.fromList(audioData));
        }
      },
    );

    return completer.future;
  }
}
