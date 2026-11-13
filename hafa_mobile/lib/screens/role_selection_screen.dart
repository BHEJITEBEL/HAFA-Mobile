import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../widgets/patterns.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, this.isGuest = false});
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final roles = <({UserRole role, String description, IconData icon, List<Color> colors, List<String> features})>[
      (
        role: UserRole.consumer,
        description: 'Browse and verify authentic heritage products',
        icon: Icons.person_rounded,
        colors: [HC.emerald, HC.forest],
        features: ['Browse crafts', 'Scan QR codes', 'Save favorites'],
      ),
      (
        role: UserRole.artisan,
        description: 'Register and manage your heritage crafts',
        icon: Icons.work_rounded,
        colors: [HC.bronze, HC.maroon],
        features: ['Register products', 'Manage portfolio', 'Track analytics'],
      ),
      (
        role: UserRole.administrator,
        description: 'System-wide monitoring and analytics',
        icon: Icons.settings_rounded,
        colors: [HC.navy, HC.emeraldDark],
        features: ['Analytics', 'User management', 'Security monitoring'],
      ),
    ];

    Future<void> select(UserRole role) async {
      await app.setRole(role);
      if (isGuest && !app.isAuthenticated) {
        await app.login(AppUser(
          name: 'Guest User',
          email: 'guest@hafa.my',
          joinedDate: formatDate(DateTime.now()),
          isGuest: true,
        ));
      }
      if (context.mounted) context.go('/home');
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 48,
                child: app.isAuthenticated
                    ? TextButton.icon(
                        onPressed: () => goBack(context, fallback: '/home'),
                        icon: Icon(Icons.arrow_back_rounded, color: HC.cream, size: 20),
                        label: Text('Back', style: TextStyle(color: HC.cream)),
                      )
                    : null,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: HC.gold, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.shield_outlined, size: 34, color: HC.emeraldDark),
                  ),
                  const SizedBox(height: 16),
                  Text('Choose Your Role', style: heading(30, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Select how you want to use HAFA', style: TextStyle(color: HC.cream, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('You can change this later in your profile', style: TextStyle(color: HC.cream.o(0.6), fontSize: 12)),
                  const SizedBox(height: 24),
                  for (final r in roles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => select(r.role),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: r.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: HC.gold.o(0.4), width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.o(0.25), blurRadius: 12, offset: const Offset(0, 5))],
                          ),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(color: HC.gold, borderRadius: BorderRadius.circular(14)),
                              child: Icon(r.icon, color: HC.emeraldDark, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Expanded(child: Text(r.role.label, style: heading(20, color: Colors.white))),
                                  const Icon(Icons.chevron_right_rounded, color: HC.gold),
                                ]),
                                const SizedBox(height: 4),
                                Text(r.description, style: TextStyle(color: HC.cream.o(0.9), fontSize: 13, height: 1.35)),
                                const SizedBox(height: 10),
                                Wrap(spacing: 6, runSpacing: 6, children: [
                                  for (final f in r.features)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.white.o(0.15), borderRadius: BorderRadius.circular(20)),
                                      child: Text(f, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                ]),
                              ]),
                            ),
                          ]),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
