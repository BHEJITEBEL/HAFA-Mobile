import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config.dart';
import '../core/utils.dart';
import '../models/app_user.dart';
import '../models/product.dart';
import '../services/api_service.dart';

const _kUser = 'hafa-user';
const _kToken = 'hafa-token';
const _kRole = 'hafa-role';
const _kServer = 'hafa-server-url';
const _kCache = 'hafa-products-cache';

/// Ganti AppContext.js (React). Menyimpan pengguna, peranan dan senarai produk.
class AppState extends ChangeNotifier {
  AppState(SharedPreferences prefs)
      : _prefs = prefs,
        api = ApiService(prefs.getString(_kServer) ?? ApiConfig.defaultServerUrl) {
    api.onUnauthorized = _expireSession;
  }

  final SharedPreferences _prefs;
  final ApiService api;

  AppUser? user;
  UserRole role = UserRole.consumer;

  List<Product> products = [];
  bool productsLoading = true;
  String? productsError;

  /// true jika senarai dipaparkan daripada cache kerana server tidak dapat dicapai.
  bool usingCache = false;

  bool get isAuthenticated => user != null;

  /// true = akaun sebenar di server (bukan tetamu).
  bool get hasAccount => user != null && !user!.isGuest;

  /// Peranan akaun sebenar ditetapkan oleh server; hanya tetamu boleh menukar (mod demo).
  bool get canSwitchRole => !hasAccount;
  String get serverUrl => api.serverUrl;

  Future<void> init() async {
    final savedUser = _prefs.getString(_kUser);
    if (savedUser != null) {
      try {
        user = AppUser.fromJson(Map<String, dynamic>.from(jsonDecode(savedUser) as Map));
      } catch (_) {
        user = null;
      }
    }
    final savedToken = _prefs.getString(_kToken);

    if (user != null && !user!.isGuest) {
      if (savedToken == null) {
        // Sesi lama daripada versi prototaip (tiada akaun sebenar) -> buang
        await _clearSession();
      } else {
        api.token = savedToken;
        role = user!.role;
        unawaited(refreshSession());
      }
    } else {
      role = parseRole(_prefs.getString(_kRole));
    }
    unawaited(loadProducts());
  }

  // ---------- Produk ----------

  Future<void> loadProducts() async {
    productsLoading = true;
    productsError = null;
    notifyListeners();
    try {
      final list = await api.getProducts();
      products = list;
      usingCache = false;
      await _prefs.setString(_kCache, jsonEncode(list.map((p) => p.toJson()).toList()));
    } on ApiException catch (e) {
      productsError = e.message;
      _loadCache();
    } catch (e) {
      productsError = e.toString();
      _loadCache();
    }
    productsLoading = false;
    notifyListeners();
  }

  void _loadCache() {
    final cached = _prefs.getString(_kCache);
    if (cached == null) return;
    try {
      final list = jsonDecode(cached) as List;
      products = list.map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      usingCache = products.isNotEmpty;
    } catch (_) {}
  }

  Product? findProduct(String key) {
    final k = key.trim().toLowerCase();
    if (k.isEmpty) return null;
    for (final p in products) {
      if (p.id.toLowerCase() == k || p.verificationId.toLowerCase() == k) return p;
    }
    return null;
  }

  /// Cari tempatan dahulu, kemudian tanya server. null = tidak wujud (404).
  Future<Product?> resolveProduct(String key) async {
    final local = findProduct(key);
    if (local != null) return local;
    try {
      return await api.getProduct(key);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  /// Carian longgar (nama / ID / nombor passport) untuk "Manual Lookup".
  Product? searchProduct(String q) {
    final k = q.trim().toLowerCase();
    if (k.isEmpty) return null;
    final exact = findProduct(k);
    if (exact != null) return exact;
    for (final p in products) {
      if (p.heritagePassportNumber.toLowerCase() == k ||
          p.id.toLowerCase().contains(k) ||
          p.verificationId.toLowerCase().contains(k) ||
          p.heritagePassportNumber.toLowerCase().contains(k) ||
          p.name.toLowerCase().contains(k)) {
        return p;
      }
    }
    return null;
  }

  /// Muat naik gambar, daftar produk di server, kemudian masukkan ke senarai tempatan.
  Future<Product> registerProduct(Map<String, dynamic> body) async {
    final created = await api.createProduct(body);
    products = [...products, created];
    notifyListeners();
    return created;
  }

  // ---------- Sesi ----------

  /// Log masuk dengan akaun sebenar. Melempar [ApiException] (cth. kata laluan salah).
  Future<void> signIn(String email, String password) async {
    final s = await api.login(email, password);
    await _startSession(s.token, s.user);
  }

  /// Daftar akaun baharu di server dan terus log masuk.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final s = await api.register(name: name, email: email, password: password, role: role);
    await _startSession(s.token, s.user);
  }

  /// Mod tetamu / demo: tiada akaun, peranan dipilih sendiri untuk meninjau aplikasi.
  Future<void> continueAsGuest(UserRole r) async {
    await _clearSession(notify: false);
    user = AppUser(
      name: 'Guest User',
      email: 'guest@hafa.my',
      joinedDate: formatDate(DateTime.now()),
      role: r,
      isGuest: true,
    );
    role = r;
    await _prefs.setString(_kUser, jsonEncode(user!.toJson()));
    await _prefs.setString(_kRole, r.value);
    notifyListeners();
  }

  /// Semak semula sesi dengan server (nama / peranan terkini).
  /// Jika server tidak dapat dicapai, kekalkan sesi tersimpan (boleh guna luar talian).
  Future<void> refreshSession() async {
    if (api.token == null) return;
    try {
      final u = await api.me();
      user = u;
      role = u.role;
      await _prefs.setString(_kUser, jsonEncode(u.toJson()));
      notifyListeners();
    } on ApiException {
      // 401 sudah dikendalikan oleh onUnauthorized; ralat rangkaian diabaikan
    }
  }

  Future<void> logout() => _clearSession();

  /// Tetamu sahaja. Peranan akaun sebenar ditetapkan oleh server.
  Future<void> setRole(UserRole r) async {
    if (!canSwitchRole) return;
    role = r;
    await _prefs.setString(_kRole, r.value);
    notifyListeners();
  }

  Future<void> _startSession(String token, AppUser u) async {
    api.token = token;
    user = u;
    role = u.role;
    await _prefs.setString(_kToken, token);
    await _prefs.setString(_kUser, jsonEncode(u.toJson()));
    await _prefs.setString(_kRole, u.role.value);
    notifyListeners();
  }

  Future<void> _clearSession({bool notify = true}) async {
    api.token = null;
    user = null;
    role = UserRole.consumer;
    await _prefs.remove(_kToken);
    await _prefs.remove(_kUser);
    await _prefs.setString(_kRole, role.value);
    if (notify) notifyListeners();
  }

  /// Token ditolak oleh server -> log keluar (router akan bawa ke /welcome).
  void _expireSession() {
    if (!hasAccount) return;
    unawaited(_clearSession());
  }

  Future<void> setServerUrl(String url) async {
    api.setServerUrl(url);
    await _prefs.setString(_kServer, api.serverUrl);
    notifyListeners();
    unawaited(loadProducts());
  }
}
