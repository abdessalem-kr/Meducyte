import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_media.freezed.dart';
part 'clinical_media.g.dart';

enum MediaType { audio, image, ecg }

@freezed
class ClinicalMedia with _$ClinicalMedia {
  const factory ClinicalMedia({
    required String url,
    required MediaType type,
    String? title,
  }) = _ClinicalMedia;

  /// Resilient factory that handles case-insensitive types and alternative
  /// field names the backend might send (media_url, image_url, media_type).
  factory ClinicalMedia.fromJson(Map<String, dynamic> json) {
    // Normalize: accept url / media_url / image_url
    final url = (json['url'] ?? json['media_url'] ?? json['image_url'] ?? '') as String;

    // Normalize: accept type / media_type, case-insensitive
    final rawType = ((json['type'] ?? json['media_type'] ?? '') as String).toLowerCase().trim();
    MediaType type;
    switch (rawType) {
      case 'ecg':
        type = MediaType.ecg;
        break;
      case 'audio':
      case 'sound':
      case 'auscultation':
        type = MediaType.audio;
        break;
      case 'image':
      case 'xray':
      case 'x-ray':
      case 'radiograph':
        type = MediaType.image;
        break;
      default:
        // Best-effort: infer from URL
        if (url.contains('.mp3') || url.contains('.wav') || url.contains('.m4a')) {
          type = MediaType.audio;
        } else {
          type = MediaType.image;
        }
    }

    final title = json['title'] as String?;

    return ClinicalMedia(url: url, type: type, title: title);
  }
}
