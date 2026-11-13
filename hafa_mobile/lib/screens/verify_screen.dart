import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _manual = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    // Buka kamera sebenar; skrin imbas memulangkan teks QR melalui pop().
    final raw = await context.push<String>('/scan');
    if (raw == null || !mounted) return;
    final key = extractVerificationKey(raw);
    if (key == null) {
      showMsg(context, 'That QR code is not a HAFA code.');
      return;
    }
    context.push('/qr-verify/${Uri.encodeComponent(key)}?m=qr');
  }

  Future<void> _manualLookup() async {
    final q = _manual.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final app = context.read<AppState>();
    var found = app.searchProduct(q);
    if (found == null) {
      try {
        found = await app.resolveProduct(q);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (found == null) {
      showMsg(context, 'Product not found. Try: HAFA-2024-TRG-001');
      return;
    }
    context.push('/qr-verify/${Uri.encodeComponent(found.id)}?m=manual');
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AppState>().products;
    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        GradientHeader(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 26),
          child: const HeaderTitle(
            icon: Icons.verified_user_rounded,
            title: 'Verify Heritage Product',
            subtitle: 'Confirm authenticity using QR code, NFC tag, or manual lookup',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ---- QR ----
            _MethodCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan QR Code',
              badge: 'RECOMMENDED',
              subtitle: "Point your camera at the product's QR code",
              dark: false,
              onTap: _scanQr,
            ),
            const SizedBox(height: 12),
            // ---- NFC ----
            _MethodCard(
              icon: Icons.nfc_rounded,
              title: 'Tap NFC Tag',
              badge: 'PREMIUM',
              subtitle: 'Hold your phone near the heritage craft tag',
              dark: true,
              onTap: () => context.push('/nfc-verify'),
            ),
            const SizedBox(height: 12),
            // ---- Manual ----
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: HC.gold.o(0.18), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.search_rounded, color: HC.goldDark),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Manual Product Lookup', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: HC.emeraldDark)),
                      SizedBox(height: 2),
                      Text('Enter verification ID or product name', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _manual,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _manualLookup(),
                      decoration: InputDecoration(
                        hintText: 'HAFA-2024-TRG-001',
                        filled: true,
                        fillColor: HC.cream,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _manualLookup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HC.emerald,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _busy
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.search_rounded),
                    ),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            AppCard(
              color: HC.cream,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.auto_awesome, color: HC.goldDark, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('How verification works', style: TextStyle(fontWeight: FontWeight.w700, color: HC.emeraldDark)),
                    const SizedBox(height: 4),
                    Text(
                      "Each authentic HAFA product carries a unique QR code or NFC tag. When scanned, our blockchain system instantly verifies the product's authenticity, provenance, and ownership history.",
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.5),
                    ),
                  ]),
                ),
              ]),
            ),
            if (products.isNotEmpty) ...[
              const SizedBox(height: 18),
              Center(child: Text('Try a sample verification:', style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
              const SizedBox(height: 8),
              Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
                for (final p in products.take(4))
                  ActionChip(
                    label: Text(p.category),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: HC.emerald.o(0.3)),
                    labelStyle: const TextStyle(color: HC.emerald, fontWeight: FontWeight.w600),
                    onPressed: () => context.push('/qr-verify/${Uri.encodeComponent(p.id)}?m=sample'),
                  ),
              ]),
            ],
            const SizedBox(height: 12),
          ]),
        ),
      ]),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.dark,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String badge;
  final String subtitle;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : HC.emeraldDark;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: dark ? null : Colors.white,
          gradient: dark ? HC.gradient : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: dark ? HC.gold.o(0.5) : HC.emerald.o(0.25), width: 2),
          boxShadow: [BoxShadow(color: Colors.black.o(0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [
            if (dark) SongketPattern(opacity: 0.1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(color: dark ? HC.gold : HC.emerald, borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, size: 30, color: dark ? HC.emeraldDark : HC.gold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(child: Text(title, style: heading(18, color: fg))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: HC.gold, borderRadius: BorderRadius.circular(8)),
                        child: Text(badge, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: HC.emeraldDark, letterSpacing: 0.5)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12.5, color: dark ? HC.cream.o(0.85) : Colors.black54, height: 1.35)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: dark ? HC.gold : HC.emerald),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
