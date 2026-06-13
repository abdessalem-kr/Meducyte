/// Compile-time configuration injected via --dart-define.
///
/// Build with:
///   flutter run --dart-define=GROQ_API_KEY=gsk_...
///   flutter build apk --dart-define=GROQ_API_KEY=gsk_...
///
/// Never hardcode secrets in source: anything compiled into the app can be
/// extracted from the binary. Long term, AI calls should be proxied through
/// the Meducyte backend so no key ships to devices at all.
abstract final class Env {
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  static bool get hasGroqApiKey => groqApiKey.isNotEmpty;
}
