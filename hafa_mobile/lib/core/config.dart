/// Alamat server HAFA.
///
/// - Emulator Android  -> http://10.0.2.2:8001   (10.0.2.2 = "localhost" PC anda)
/// - Telefon fizikal   -> http://<IP-PC-anda>:8001  (contoh http://192.168.1.10:8001)
///
/// Boleh ditukar semasa build:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8001
/// atau terus dalam aplikasi: Profile > Server Settings.
class ApiConfig {
  ApiConfig._();
  static const String defaultServerUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8001',
  );
}
