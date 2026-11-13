import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AppState>().products;
    return Scaffold(
      body: GradientBackground(
        songket: 0.06,
        islamic: 0.04,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: HC.gold, borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.shield_outlined, size: 34, color: HC.emeraldDark),
              ),
              const SizedBox(height: 14),
              Text('HAFA', style: heading(42, color: HC.gold, letterSpacing: 3)),
              const SizedBox(height: 22),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Welcome to ', style: heading(30, color: Colors.white)),
                  TextSpan(text: 'HAFA', style: heading(30, color: HC.gold)),
                ]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              for (final line in const ['Verify authenticity.', 'Protect artisans.', 'Preserve culture.'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(line, style: TextStyle(color: HC.cream, fontSize: 16)),
                ),
              const SizedBox(height: 28),
              Text('FEATURED HERITAGE CRAFTS',
                  style: TextStyle(color: HC.cream.o(0.7), fontSize: 11, letterSpacing: 2.5)),
              const SizedBox(height: 12),
              SizedBox(
                height: 132,
                child: products.isEmpty
                    ? Center(
                        child: Text('Connecting to HAFA server...', style: TextStyle(color: HC.cream.o(0.6), fontSize: 12)),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final p = products[i];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 128,
                              decoration: BoxDecoration(
                                border: Border.all(color: HC.gold.o(0.4), width: 2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Stack(fit: StackFit.expand, children: [
                                AppNetworkImage(p.images.isNotEmpty ? p.images.first : null),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.center,
                                      colors: [Colors.black.o(0.75), Colors.transparent],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 8,
                                  right: 8,
                                  bottom: 6,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                    Text(p.category.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: HC.gold, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                    Text(p.name.split(' ').take(2).join(' '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ]),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(children: [
                  AppButton(label: 'Login', style: BtnStyle.gold, onPressed: () => context.push('/login')),
                  const SizedBox(height: 12),
                  AppButton(label: 'Register', style: BtnStyle.ghostLight, onPressed: () => context.push('/register')),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => context.push('/role-selection?guest=true'),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Explore as Guest', style: TextStyle(color: HC.cream, fontSize: 15)),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: HC.cream),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.auto_awesome, size: 12, color: HC.gold.o(0.6)),
                const SizedBox(width: 8),
                Text("MALAYSIA'S HERITAGE PLATFORM",
                    style: TextStyle(color: HC.cream.o(0.6), fontSize: 10, letterSpacing: 2)),
                const SizedBox(width: 8),
                Icon(Icons.auto_awesome, size: 12, color: HC.gold.o(0.6)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
