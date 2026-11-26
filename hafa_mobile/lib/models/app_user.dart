import '../core/utils.dart';

enum UserRole { consumer, artisan, administrator }

extension UserRoleX on UserRole {
  String get value => name;
  String get label {
    switch (this) {
      case UserRole.consumer:
        return 'Consumer';
      case UserRole.artisan:
        return 'Artisan';
      case UserRole.administrator:
        return 'Administrator';
    }
  }
}

UserRole parseRole(String? v) =>
    UserRole.values.firstWhere((r) => r.name == v, orElse: () => UserRole.consumer);

/// "2026-11-26T07:05:00.760Z" (dari server) -> "2026-11-26". Teks lain dikekalkan.
String _displayDate(Object? v) {
  final s = (v ?? '').toString();
  final d = DateTime.tryParse(s);
  return d == null ? s : formatDate(d.toLocal());
}

class AppUser {
  const AppUser({
    this.id = '',
    required this.name,
    required this.email,
    required this.joinedDate,
    this.role = UserRole.consumer,
    this.isGuest = false,
  });

  /// ID akaun di server (kosong untuk tetamu).
  final String id;
  final String name;
  final String email;
  final String joinedDate;

  /// Peranan yang ditetapkan oleh server. Untuk tetamu, peranan dipilih dalam aplikasi.
  final UserRole role;
  final bool isGuest;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        joinedDate: _displayDate(j['joinedDate'] ?? j['createdAt']),
        role: parseRole(j['role']?.toString()),
        isGuest: j['isGuest'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'joinedDate': joinedDate,
        'role': role.value,
        'isGuest': isGuest,
      };
}
