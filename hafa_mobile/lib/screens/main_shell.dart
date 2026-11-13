import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

class _NavItem {
  const _NavItem(this.path, this.label, this.icon, {this.primary = false});
  final String path;
  final String label;
  final IconData icon;
  final bool primary;
}

/// Ganti BottomNavigation.js + AppLayout (App.js).
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  static const _items = [
    _NavItem('/home', 'Home', Icons.home_rounded),
    _NavItem('/passport', 'Passport', Icons.description_rounded),
    _NavItem('/verify', 'Verify', Icons.verified_user_rounded, primary: true),
    _NavItem('/map', 'Map', Icons.map_rounded),
    _NavItem('/profile', 'Profile', Icons.person_rounded),
  ];

  bool _active(String path) => location == path || location.startsWith('$path/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: HC.gold, width: 1.5)),
          boxShadow: [BoxShadow(color: Colors.black.o(0.08), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [for (final item in _items) Expanded(child: _buildItem(context, item))],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _NavItem item) {
    final active = _active(item.path);
    final onTap = () => context.go(item.path);

    if (item.primary) {
      return InkWell(
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 50 : 46,
            height: active ? 50 : 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? HC.gold : HC.emerald,
              boxShadow: [BoxShadow(color: Colors.black.o(0.25), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Icon(item.icon, size: 26, color: active ? HC.emeraldDark : HC.gold),
          ),
          const SizedBox(height: 2),
          Text(item.label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? HC.emerald : Colors.grey.shade600)),
        ]),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(item.icon, size: 24, color: active ? HC.emerald : Colors.grey.shade500),
        const SizedBox(height: 3),
        Text(item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? HC.emerald : Colors.grey.shade600,
            )),
        const SizedBox(height: 3),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: active ? 18 : 0,
          height: 3,
          decoration: BoxDecoration(color: HC.gold, borderRadius: BorderRadius.circular(2)),
        ),
      ]),
    );
  }
}
