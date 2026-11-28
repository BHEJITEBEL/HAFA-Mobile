/// Alamat server HAFA.
///
/// Lalai: PC sendiri melalui Cloudflare Tunnel (api.hafamobilefyp.site) — berfungsi pada mana-mana peranti.
///
/// Untuk pembangunan dengan Docker tempatan:
/// - Emulator Android  -> http://10.0.2.2:8001   (10.0.2.2 = "localhost" PC anda)
/// - Telefon fizikal   -> http://<IP-PC-anda>:8001  (contoh http://192.168.1.10:8001)
///
/// Boleh ditukar semasa build:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001
/// atau terus dalam aplikasi: Profile > Server Settings.
class ApiConfig {
  ApiConfig._();
  /// PC sendiri melalui Cloudflare Tunnel (perkhidmatan Windows "Cloudflared").
  /// Sandaran: https://hafa-api.onrender.com
  static const String onlineServerUrl = 'https://api.hafamobilefyp.site';
  static const String defaultServerUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: onlineServerUrl,
  );
}
