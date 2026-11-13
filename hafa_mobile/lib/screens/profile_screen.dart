import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;

  Future<void> _serverDialog() async {
    final app = context.read<AppState>();
    final controller = TextEditingController(text: app.serverUrl);
    String status = '';
    bool testing = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Server Settings', style: heading(19)),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Android emulator: http://10.0.2.2:8001\nReal phone: http://<your-PC-IP>:8001',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.45),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Server URL',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (status.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(status, style: TextStyle(fontSize: 13, color: status.startsWith('Connected') ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
            ],
          ]),
          actions: [
            TextButton(
              onPressed: testing
                  ? null
                  : () async {
                      setLocal(() {
                        testing = true;
                        status = 'Testing...';
                      });
                      final ok = await ApiService(controller.text).ping();
                      setLocal(() {
                        testing = false;
                        status = ok ? 'Connected to the HAFA server.' : 'Cannot reach the server at that address.';
                      });
                    },
              child: const Text('Test'),
            ),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                await app.setServerUrl(controller.text);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) showMsg(context, 'Server set to ${app.serverUrl}');
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text('You will return to the welcome screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Log out', style: TextStyle(color: Color(0xFFDC2626)))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AppState>().logout(); // router akan redirect ke /welcome
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.user;
    final name = user?.name ?? 'Guest';

    final roles = <(UserRole, IconData, String)>[
      (UserRole.consumer, Icons.person_rounded, 'Browse and verify products'),
      (UserRole.artisan, Icons.work_rounded, 'Register and manage crafts'),
      (UserRole.administrator, Icons.settings_rounded, 'Analytics and security'),
    ];

    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        GradientHeader(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 24, 20, 28),
          child: Column(children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: HC.gold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: heading(36, color: HC.emeraldDark)),
            ),
            const SizedBox(height: 12),
            Text(name, style: heading(24, color: Colors.white)),
            const SizedBox(height: 2),
            Text(user?.email ?? '', style: TextStyle(color: HC.cream, fontSize: 13.5)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.o(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: HC.gold.o(0.6))),
              child: Text(app.role.label, style: const TextStyle(color: HC.gold, fontWeight: FontWeight.w700, fontSize: 12.5)),
            ),
            if (user != null && user.joinedDate.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Member since ${user.joinedDate}', style: TextStyle(color: HC.cream.o(0.75), fontSize: 12)),
            ],
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Switch Role', style: heading(19)),
            const SizedBox(height: 10),
            for (final r in roles)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => app.setRole(r.$1),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: app.role == r.$1 ? HC.emerald : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: app.role == r.$1 ? HC.emerald : HC.creamDark, width: 1.5),
                    ),
                    child: Row(children: [
                      Icon(r.$2, color: app.role == r.$1 ? HC.gold : HC.emerald),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.$1.label, style: TextStyle(fontWeight: FontWeight.w700, color: app.role == r.$1 ? Colors.white : HC.emeraldDark)),
                          Text(r.$3, style: TextStyle(fontSize: 12, color: app.role == r.$1 ? HC.cream : Colors.grey.shade600)),
                        ]),
                      ),
                      if (app.role == r.$1) const Icon(Icons.check_circle_rounded, color: HC.gold),
                    ]),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Text('Shortcuts', style: heading(19)),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _tile(Icons.auto_awesome, 'Explore Crafts', () => context.push('/explore')),
                if (app.role == UserRole.artisan) ...[
                  _divider(),
                  _tile(Icons.dashboard_customize_rounded, 'Artisan Dashboard', () => context.push('/artisan-dashboard')),
                  _divider(),
                  _tile(Icons.add_box_rounded, 'Register a Product', () => context.push('/register-product')),
                ],
                if (app.role == UserRole.administrator) ...[
                  _divider(),
                  _tile(Icons.insights_rounded, 'Admin Dashboard', () => context.push('/admin-dashboard')),
                  _divider(),
                  _tile(Icons.shield_rounded, 'Cybersecurity', () => context.push('/cybersecurity')),
                ],
              ]),
            ),
            const SizedBox(height: 18),
            Text('Settings', style: heading(19)),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                SwitchListTile(
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                  secondary: const Icon(Icons.notifications_none_rounded, color: HC.emerald),
                  title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                _divider(),
                ListTile(
                  leading: const Icon(Icons.dns_rounded, color: HC.emerald),
                  title: const Text('Server Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(app.serverUrl, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _serverDialog,
                ),
                _divider(),
                ListTile(
                  leading: Icon(app.usingCache ? Icons.cloud_off_rounded : Icons.cloud_done_rounded, color: app.usingCache ? const Color(0xFFCA8A04) : const Color(0xFF16A34A)),
                  title: Text(app.usingCache ? 'Offline (saved data)' : 'Server connection', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(app.productsError ?? '${app.products.length} products loaded', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(icon: const Icon(Icons.refresh_rounded, color: HC.emerald), onPressed: app.loadProducts),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            AppCard(
              color: HC.cream,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, color: HC.emerald),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('HAFA v1.0.0', style: heading(16)),
                    const SizedBox(height: 4),
                    Text(
                      'Heritage Artisan Fair-Trade Authenticator - preserving Malaysian heritage through blockchain authentication.',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.45),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            AppButton(label: 'Log Out', icon: Icons.logout_rounded, style: BtnStyle.outline, onPressed: _logout),
            const SizedBox(height: 12),
          ]),
        ),
      ]),
    );
  }

  Widget _divider() => Divider(height: 1, color: HC.creamDark);

  Widget _tile(IconData icon, String title, VoidCallback onTap) => ListTile(
        leading: Icon(icon, color: HC.emerald),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      );
}
