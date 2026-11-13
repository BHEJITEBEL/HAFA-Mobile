import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';
import 'login_screen.dart' show authDecoration, AuthLabel;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  UserRole _role = UserRole.consumer;
  bool _show = false;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _error = '');
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() => _loading = true);
    // Pendaftaran simulasi (prototaip FYP) — tiada akaun disimpan di server.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final app = context.read<AppState>();
    await app.login(AppUser(
      name: _name.text.trim().isEmpty ? 'New User' : _name.text.trim(),
      email: _email.text.trim(),
      joinedDate: formatDate(DateTime.now()),
    ));
    await app.setRole(_role);
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  String? _required(String? v, String what) => (v == null || v.trim().isEmpty) ? '$what is required' : null;

  @override
  Widget build(BuildContext context) {
    const roles = [
      (UserRole.artisan, 'Artisan', 'I create heritage crafts'),
      (UserRole.consumer, 'Consumer', 'I want to verify products'),
    ];
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
                    child: Form(
                      key: _formKey,
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
                        Text('Create Account', textAlign: TextAlign.center, style: heading(30, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('Join the heritage preservation community',
                            textAlign: TextAlign.center, style: TextStyle(color: HC.cream, fontSize: 14)),
                        const SizedBox(height: 24),
                        const AuthLabel('Full Name'),
                        TextFormField(
                          controller: _name,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: HC.gold,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => _required(v, 'Name'),
                          decoration: authDecoration(hint: 'Your full name', icon: Icons.person_outline_rounded),
                        ),
                        const SizedBox(height: 14),
                        const AuthLabel('Email'),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: HC.gold,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                            return null;
                          },
                          decoration: authDecoration(hint: 'your@email.com', icon: Icons.mail_outline_rounded),
                        ),
                        const SizedBox(height: 14),
                        const AuthLabel('Password'),
                        TextFormField(
                          controller: _password,
                          obscureText: !_show,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: HC.gold,
                          validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                          decoration: authDecoration(
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: HC.gold),
                              onPressed: () => setState(() => _show = !_show),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const AuthLabel('Confirm Password'),
                        TextFormField(
                          controller: _confirm,
                          obscureText: !_show,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: HC.gold,
                          validator: (v) => _required(v, 'Confirmation'),
                          decoration: authDecoration(hint: '••••••••', icon: Icons.lock_outline_rounded),
                        ),
                        const SizedBox(height: 16),
                        const AuthLabel('I am a...'),
                        for (final r in roles)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => setState(() => _role = r.$1),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _role == r.$1 ? HC.gold.o(0.2) : Colors.white.o(0.05),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _role == r.$1 ? HC.gold : HC.gold.o(0.2), width: 2),
                                ),
                                child: Row(children: [
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(r.$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                      Text(r.$3, style: TextStyle(color: HC.cream.o(0.8), fontSize: 12)),
                                    ]),
                                  ),
                                  if (_role == r.$1)
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(color: HC.gold, shape: BoxShape.circle),
                                      child: const Icon(Icons.check_rounded, size: 15, color: HC.emeraldDark),
                                    ),
                                ]),
                              ),
                            ),
                          ),
                        if (_error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: Text(_error, style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13)),
                          ),
                        const SizedBox(height: 12),
                        AppButton(label: 'Create Account', style: BtnStyle.gold, loading: _loading, onPressed: _register),
                        const SizedBox(height: 18),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Already have an account? ', style: TextStyle(color: HC.cream, fontSize: 14)),
                          GestureDetector(
                            onTap: () => context.pushReplacement('/login'),
                            child: const Text('Login', style: TextStyle(color: HC.gold, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ]),
                      ]),
                    ),
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
