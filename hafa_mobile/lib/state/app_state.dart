import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config.dart';
import '../models/app_user.dart';
import '../models/product.dart';
import '../services/api_service.dart';

const _kUser = 'hafa-user';
const _kRole = 'hafa-role';
const _kServer = 'hafa-server-url';
const _kCache = 'hafa-products-cache';

/// Ganti AppContext.js (React). Menyimpan pengguna, peranan dan senarai produk.
class AppState extends ChangeNotifier {
  AppState(SharedPreferences prefs)
      : _prefs = prefs,
        api = ApiService(prefs.getString(_kServer) ?? ApiConfig.defaultServerUrl);

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
    role = parseRole(_prefs.getString(_kRole));
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

  Future<void> login(AppUser u) async {
    user = u;
    await _prefs.setString(_kUser, jsonEncode(u.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    user = null;
    role = UserRole.consumer;
    await _prefs.remove(_kUser);
    await _prefs.setString(_kRole, role.value);
    notifyListeners();
  }

  Future<void> setRole(UserRole r) async {
    role = r;
    await _prefs.setString(_kRole, r.value);
    notifyListeners();
  }

  Future<void> setServerUrl(String url) async {
    api.setServerUrl(url);
    await _prefs.setString(_kServer, api.serverUrl);
    notifyListeners();
    unawaited(loadProducts());
  }
}
