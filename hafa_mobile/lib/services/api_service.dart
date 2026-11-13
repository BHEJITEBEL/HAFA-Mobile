import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/product.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

/// Klien REST untuk backend HAFA (Express + MongoDB).
class ApiService {
  ApiService(String serverUrl) : _serverUrl = normalize(serverUrl);

  String _serverUrl;
  String get serverUrl => _serverUrl;

  void setServerUrl(String url) => _serverUrl = normalize(url);

  /// "192.168.1.10:8001/" -> "http://192.168.1.10:8001"
  static String normalize(String url) {
    var u = url.trim();
    if (u.isEmpty) return ApiConfig.defaultServerUrl;
    if (!u.startsWith('http://') && !u.startsWith('https://')) u = 'http://$u';
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    if (u.endsWith('/api')) u = u.substring(0, u.length - 4);
    return u;
  }

  /// Gambar produk disimpan sebagai laluan relatif (/uploads/x.jpg) atau URL penuh.
  String resolveUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$_serverUrl${path.startsWith('/') ? '' : '/'}$path';
  }

  Uri _uri(String path) => Uri.parse('$_serverUrl/api$path');

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException('The server did not respond in time ($_serverUrl). Check that Docker is running.');
    } on SocketException {
      throw ApiException(
          'Cannot reach the HAFA server at $_serverUrl. Make sure "docker compose up" is running and the Server URL is correct.');
    } on http.ClientException {
      throw ApiException('Cannot reach the HAFA server at $_serverUrl.');
    } on HandshakeException {
      throw ApiException('Secure connection to $_serverUrl failed.');
    }
  }

  dynamic _decode(http.Response res) {
    dynamic body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      body = null;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = body is Map && body['error'] != null ? body['error'].toString() : 'Server error (${res.statusCode})';
    throw ApiException(msg, statusCode: res.statusCode);
  }

  Future<bool> ping() async {
    try {
      final res = await _send(() => http.get(_uri('/health')));
      return res.statusCode == 200;
    } on ApiException {
      return false;
    }
  }

  Future<List<Product>> getProducts() async {
    final res = await _send(() => http.get(_uri('/products')));
    final data = _decode(res);
    if (data is! List) throw ApiException('Unexpected response from server');
    return data.map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// [key] = id (HP001) atau verificationId. Melempar [ApiException] (404) jika tiada.
  Future<Product> getProduct(String key) async {
    final res = await _send(() => http.get(_uri('/products/${Uri.encodeComponent(key)}')));
    final data = _decode(res);
    if (data is! Map) throw ApiException('Unexpected response from server');
    return Product.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Product> createProduct(Map<String, dynamic> body) async {
    final res = await _send(() => http.post(
          _uri('/products'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ));
    final data = _decode(res);
    if (data is! Map) throw ApiException('Unexpected response from server');
    return Product.fromJson(Map<String, dynamic>.from(data));
  }

  /// Muat naik imej mentah; pulangkan laluan (/uploads/...).
  Future<String> uploadImage(Uint8List bytes, String contentType) async {
    final res = await _send(() => http.post(
          _uri('/uploads'),
          headers: {'Content-Type': contentType},
          body: bytes,
        ));
    final data = _decode(res);
    if (data is Map && data['path'] is String) return data['path'] as String;
    throw ApiException('Upload failed');
  }

  /// Rekod imbasan (method: qr | nfc | manual). Gagal senyap-senyap — tidak kritikal.
  Future<void> recordScan(String key, String method) async {
    try {
      await _send(() => http.post(
            _uri('/products/${Uri.encodeComponent(key)}/scan'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'method': method}),
          ));
    } catch (_) {}
  }
}
