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

class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.joinedDate,
    this.isGuest = false,
  });

  final String name;
  final String email;
  final String joinedDate;
  final bool isGuest;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        joinedDate: (j['joinedDate'] ?? '').toString(),
        isGuest: j['isGuest'] == true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'joinedDate': joinedDate,
        'isGuest': isGuest,
      };
}
