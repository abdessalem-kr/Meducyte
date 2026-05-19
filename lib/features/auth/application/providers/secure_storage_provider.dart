import 'dart:convert';
import 'dart:typed_data';
import 'package:meducyte_app/export.dart';

// =====================AES Encryption Helpers=====================

Uint8List generateIV() {
  final rnd = SecureRandom("Fortuna")
    ..seed(
      KeyParameter(
        Uint8List.fromList(
          List.generate(32, (_) => DateTime.now().millisecond),
        ),
      ),
    );
  return rnd.nextBytes(16);
}

Uint8List _getKey(String keyString) {
  return Uint8List.fromList(utf8.encode(keyString.padRight(32))); //AES-256
}

Future<void> writeEncrypted(
  FlutterSecureStorage storage,
  String key,
  String value,
  String secretKey,
) async {
  final iv = generateIV();
  final cipher = PaddedBlockCipher("AES/CBC/PKCS7")
    ..init(
      true,
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV(KeyParameter(_getKey(secretKey)), iv),
        null,
      ),
    );
  final encrypted = cipher.process(Uint8List.fromList(utf8.encode(value)));

  final payload = jsonEncode({
    'iv': base64Encode(iv),
    'token': base64Encode(encrypted),
  });

  await storage.write(key: key, value: payload);
}

Future<String?> readEncrypted(
  FlutterSecureStorage storage,
  String key,
  String secretKey,
) async {
  final payloadString = await storage.read(key: key);
  if (payloadString == null) return null;

  final payload = jsonDecode(payloadString);
  final iv = base64Decode(payload['iv']);
  final encrypted = base64Decode(payload['token']);

  final cipher = PaddedBlockCipher("AES/CBC/PKCS7")
    ..init(
      false,
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV(KeyParameter(_getKey(secretKey)), iv),
        null,
      ),
    );

  final decrypted = cipher.process(encrypted);
  return utf8.decode(decrypted);
}

// =====================Provider Integration=====================

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secretKeyProvider = Provider<String>((ref) {
  //Put your secret key here(should be 32 chars ideally)
  return 'my_super_secret_32_char_key_here';
});
