import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

/// Keputusan pengesahan produk (ganti QRVerificationPage). Digunakan oleh QR, NFC, manual & sampel.
class VerificationResultScreen extends StatefulWidget {
  const VerificationResultScreen({super.key, required this.productKey, this.method});
  final String productKey;
  final String? method; // qr | nfc | manual | sample

  @override
  State<VerificationResultScreen> createState() => _VerificationResultScreenState();
}

class _VerificationResultScreenState extends State<VerificationResultScreen> {
  late Future<Product?> _future;

  @override
  void initState() {
    super.initState();
    _future = _verify();
  }

  Future<Product?> _verify() async {
    final app = context.read<AppState>();
    final lookup = app.resolveProduct(widget.productKey);
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 1300));
    final product = await lookup; // ralat rangkaian dilempar -> dipaparkan sebagai ralat, BUKAN "palsu"
    await minDelay;
    final m = widget.method;
    if (product != null && (m == 'qr' || m == 'nfc' || m == 'manual')) {
      app.api.recordScan(product.id, m!);
    }
    return product;
  }

  void _retry() => setState(() => _future = _verify());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const _Verifying();
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Verification'), leading: _back(context)),
            body: ErrorView(message: snap.error.toString(), onRetry: _retry),
          );
        }
        final p = snap.data;
        if (p == null) return _NotRegistered(code: widget.productKey, method: widget.method);
        return _Result(product: p, method: widget.method);
      },
    );
  }

  Widget _back(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => goBack(context, fallback: '/verify'));
}

class _Verifying extends StatelessWidget {
  const _Verifying();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        songket: 0.1,
        child: SafeArea(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: HC.gold,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: HC.gold.o(0.4), blurRadius: 30, spreadRadius: 3)],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(strokeWidth: 4, color: HC.emeraldDark),
                ),
              ),
              const SizedBox(height: 28),
              Text('Verifying...', style: heading(28, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Checking blockchain records', style: TextStyle(color: HC.cream, fontSize: 15)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NotRegistered extends StatelessWidget {
  const _NotRegistered({required this.code, this.method});
  final String code;
  final String? method;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFDC2626);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => goBack(context, fallback: '/verify')),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), shape: BoxShape.circle, border: Border.all(color: red, width: 3)),
            child: const Icon(Icons.gpp_bad_rounded, size: 58, color: red),
          ),
        ),
        const SizedBox(height: 18),
        Text('NOT VERIFIED', textAlign: TextAlign.center, style: heading(30, color: red, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text('This code is not registered in the HAFA system.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade800)),
        const SizedBox(height: 18),
        AppCard(
          color: const Color(0xFFFEF2F2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SCANNED CODE', style: TextStyle(fontSize: 10.5, letterSpacing: 1.4, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            SelectableText(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: HC.teak)),
            const SizedBox(height: 14),
            const Text(
              'The product may be counterfeit, the tag may be damaged, or the code was copied from another item. Do not rely on it as proof of authenticity.',
              style: TextStyle(fontSize: 13.5, height: 1.5, color: HC.teak),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Verify Another Product',
          icon: Icons.qr_code_scanner_rounded,
          onPressed: () => context.go('/verify'),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Browse Authentic Crafts',
          icon: Icons.auto_awesome,
          style: BtnStyle.outline,
          onPressed: () => context.go('/explore'),
        ),
      ]),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.product, this.method});
  final Product product;
  final String? method;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final Color accent;
    final String title;
    final String subtitle;
    final IconData icon;
    if (p.isVerified) {
      accent = const Color(0xFF16A34A);
      title = method == 'nfc' ? 'NFC VERIFIED' : 'HERITAGE AUTHENTIC';
      subtitle = 'This product is genuine and verified';
      icon = Icons.verified_rounded;
    } else if (p.status == 'Rejected') {
      accent = const Color(0xFFDC2626);
      title = 'VERIFICATION REJECTED';
      subtitle = 'The Heritage Authority rejected this registration';
      icon = Icons.gpp_bad_rounded;
    } else {
      accent = const Color(0xFFCA8A04);
      title = 'PENDING VERIFICATION';
      subtitle = 'Registered, but not yet approved by the Heritage Authority';
      icon = Icons.pending_actions_rounded;
    }

    final checks = <(String, bool)>[
      (p.isVerified ? 'Product Verified' : 'Product Awaiting Approval', p.isVerified),
      (p.artisan.verified ? 'Artisan Verified' : 'Artisan Not Yet Verified', p.artisan.verified),
      (p.artisan.location.isNotEmpty ? 'Origin Confirmed' : 'Origin Not Recorded', p.artisan.location.isNotEmpty),
      (p.blockchainHash.isNotEmpty ? 'Blockchain Record Found' : 'No Blockchain Record', p.blockchainHash.isNotEmpty),
    ];

    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [accent, Color.lerp(accent, HC.emeraldDark, 0.55)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            child: Stack(children: [
              SongketPattern(opacity: 0.12),
              Padding(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 28),
                child: SizedBox(width: double.infinity, child: Column(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => goBack(context, fallback: '/verify'),
                    ),
                  ),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(icon, size: 56, color: accent),
                  ),
                  const SizedBox(height: 16),
                  Text(title, textAlign: TextAlign.center, style: heading(28, color: Colors.white, letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.o(0.9), fontSize: 14.5)),
                ])),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: 190, width: double.infinity, child: AppNetworkImage(p.images.isNotEmpty ? p.images.first : null)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: heading(21, height: 1.2)),
                      const SizedBox(height: 4),
                      Text(p.category, style: const TextStyle(color: HC.goldDark, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      for (final c in checks)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Icon(c.$2 ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                                size: 20, color: c.$2 ? const Color(0xFF16A34A) : const Color(0xFFCA8A04)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(c.$1, style: const TextStyle(fontWeight: FontWeight.w600, color: HC.teak))),
                          ]),
                        ),
                    ]),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(children: [
                InfoRow(icon: Icons.person_outline_rounded, label: 'Artisan', value: p.artisan.name),
                InfoRow(icon: Icons.place_outlined, label: 'Origin', value: p.artisan.location),
                InfoRow(icon: Icons.calendar_today_outlined, label: 'Production Date', value: p.productionDate),
                InfoRow(icon: Icons.tag_rounded, label: 'Verification ID', value: p.verificationId, mono: true),
              ]),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'View Full Product Details',
              icon: Icons.visibility_rounded,
              onPressed: () => context.push('/product/${Uri.encodeComponent(p.id)}'),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'View Heritage Passport',
              icon: Icons.description_rounded,
              style: BtnStyle.gold,
              onPressed: () => context.push('/heritage-passport/${Uri.encodeComponent(p.id)}'),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Verify Another Product',
              icon: Icons.qr_code_scanner_rounded,
              style: BtnStyle.outline,
              onPressed: () => context.go('/verify'),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ]),
    );
  }
}
