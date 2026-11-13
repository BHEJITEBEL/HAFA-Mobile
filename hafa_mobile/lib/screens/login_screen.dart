import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

/// Input bertema gelap untuk skrin auth (di atas latar hijau).
InputDecoration authDecoration({required String hint, required IconData icon, Widget? suffix}) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: HC.cream.o(0.5)),
      prefixIcon: Icon(icon, color: HC.gold),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.o(0.1),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: HC.gold.o(0.3), width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HC.gold, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFCA5A5), width: 2)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFCA5A5), width: 2)),
      errorStyle: const TextStyle(color: Color(0xFFFCA5A5)),
    );

class AuthLabel extends StatelessWidget {
  const AuthLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text.toUpperCase(), style: TextStyle(color: HC.cream, fontSize: 11, letterSpacing: 1.5)),
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _show = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn({required bool demo}) async {
    setState(() => _loading = true);
    // Log masuk ini simulasi (prototaip FYP) — tiada pengesahan di server.
    await Future.delayed(Duration(milliseconds: demo ? 500 : 800));
    final email = demo ? '' : _email.text.trim();
    final derived = email.contains('@') ? email.split('@').first.replaceAll(RegExp(r'[._]'), ' ') : '';
    final name = demo ? 'Demo User' : (derived.isEmpty ? 'Demo User' : derived);
    final user = AppUser(
      name: name,
      email: email.isEmpty ? 'demo@hafa.my' : email,
      joinedDate: formatDate(DateTime.now()),
    );
    if (!mounted) return;
    await context.read<AppState>().login(user);
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => goBack(context, fallback: '/welcome'),
                icon: Icon(Icons.arrow_back_rounded, color: HC.cream, size: 20),
                label: Text('Back', style: TextStyle(color: HC.cream)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: HC.gold, borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.shield_outlined, size: 34, color: HC.emeraldDark),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Welcome Back', textAlign: TextAlign.center, style: heading(30, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text('Sign in to access your heritage account',
                          textAlign: TextAlign.center, style: TextStyle(color: HC.cream, fontSize: 14)),
                      const SizedBox(height: 28),
                      const AuthLabel('Email'),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: HC.gold,
                        decoration: authDecoration(hint: 'your@email.com', icon: Icons.mail_outline_rounded),
                      ),
                      const SizedBox(height: 16),
                      const AuthLabel('Password'),
                      TextField(
                        controller: _password,
                        obscureText: !_show,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: HC.gold,
                        decoration: authDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          suffix: IconButton(
                            icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: HC.gold),
                            onPressed: () => setState(() => _show = !_show),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => showMsg(context, 'Password reset is not available in this prototype.'),
                          child: const Text('Forgot Password?', style: TextStyle(color: HC.gold)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppButton(label: 'Login', style: BtnStyle.gold, loading: _loading, onPressed: () => _signIn(demo: false)),
                      const SizedBox(height: 12),
                      AppButton(label: 'Quick Demo Login', style: BtnStyle.ghostLight, onPressed: _loading ? null : () => _signIn(demo: true)),
                      const SizedBox(height: 22),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Don't have an account? ", style: TextStyle(color: HC.cream, fontSize: 14)),
                        GestureDetector(
                          onTap: () => context.pushReplacement('/register'),
                          child: const Text('Register', style: TextStyle(color: HC.gold, fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
