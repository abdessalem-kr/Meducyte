import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meducyte_app/core/routes/routes_provider.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(
    baseUrl: 'https://www.meducyte.com/meducyte-api',
    secureStorage: secureStorage,
    onLogout: () {
      ref.read(authProvider.notifier).logOut();
    },
  );
});
