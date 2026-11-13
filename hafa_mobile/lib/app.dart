import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'router.dart';
import 'state/app_state.dart';

class HafaApp extends StatefulWidget {
  const HafaApp({super.key, required this.appState});
  final AppState appState;

  @override
  State<HafaApp> createState() => _HafaAppState();
}

class _HafaAppState extends State<HafaApp> {
  late final GoRouter _router = buildRouter(widget.appState);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HAFA',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
    );
  }
}
