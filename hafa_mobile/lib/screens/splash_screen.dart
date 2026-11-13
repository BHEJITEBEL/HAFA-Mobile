import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/patterns.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final authed = context.read<AppState>().isAuthenticated;
      context.go(authed ? '/home' : '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        songket: 0.12,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: HC.gold,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: HC.gold.o(0.45), blurRadius: 40, spreadRadius: 4)],
                      ),
                      child: const Icon(Icons.shield_outlined, size: 58, color: HC.emeraldDark),
                    ),
                    const Positioned(top: -6, right: -6, child: Icon(Icons.auto_awesome, size: 24, color: HC.gold)),
                    const Positioned(bottom: -4, left: -4, child: Icon(Icons.auto_awesome, size: 18, color: HC.gold)),
                  ]),
                  const SizedBox(height: 32),
                  Text('HAFA', style: heading(60, color: HC.gold, letterSpacing: 8)),
                  const SizedBox(height: 8),
                  Text('HERITAGE ARTISAN',
                      style: TextStyle(color: HC.cream, fontSize: 13, letterSpacing: 4)),
                  const SizedBox(height: 4),
                  Text('FAIR-TRADE AUTHENTICATOR',
                      style: TextStyle(color: HC.cream, fontSize: 13, letterSpacing: 4)),
                  const SizedBox(height: 28),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 48, height: 1, color: HC.gold.o(0.5)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.auto_awesome, size: 16, color: HC.gold),
                    ),
                    Container(width: 48, height: 1, color: HC.gold.o(0.5)),
                  ]),
                  const SizedBox(height: 22),
                  Text(
                    '"Preserving Malaysian Heritage Through Blockchain Authentication"',
                    textAlign: TextAlign.center,
                    style: heading(16, color: HC.cream, weight: FontWeight.w400, style: FontStyle.italic, height: 1.4),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 128,
                    height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 2500),
                        curve: Curves.easeOut,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          backgroundColor: HC.gold.o(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(HC.gold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('LOADING...', style: TextStyle(color: HC.cream.o(0.6), fontSize: 11, letterSpacing: 2)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
