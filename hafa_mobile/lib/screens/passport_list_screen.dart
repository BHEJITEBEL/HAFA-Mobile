import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

class PassportListScreen extends StatefulWidget {
  const PassportListScreen({super.key});

  @override
  State<PassportListScreen> createState() => _PassportListScreenState();
}

class _PassportListScreenState extends State<PassportListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final q = _query.toLowerCase();
    final filtered = app.products
        .where((p) =>
            q.isEmpty ||
            p.name.toLowerCase().contains(q) ||
            p.heritagePassportNumber.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();

    return Scaffold(
      body: RefreshIndicator(
        color: HC.emerald,
        onRefresh: app.loadProducts,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            GradientHeader(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 24),
              child: Column(children: [
                const HeaderTitle(
                  icon: Icons.description_rounded,
                  title: 'Heritage Passports',
                  subtitle: 'Browse authenticated heritage certificates',
                ),
                const SizedBox(height: 18),
                TextField(
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search passports...',
                    prefixIcon: const Icon(Icons.search_rounded, color: HC.emerald),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ]),
            ),
            if (app.productsLoading && app.products.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: LoadingView())
            else if (app.products.isEmpty)
              SizedBox(height: 300, child: ErrorView(message: app.productsError ?? 'No passports yet.', onRetry: app.loadProducts))
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(children: [
                  for (final p in filtered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.all(10),
                        onTap: () => context.push('/heritage-passport/${Uri.encodeComponent(p.id)}'),
                        child: Row(children: [
                          SizedBox(
                            width: 92,
                            height: 92,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(fit: StackFit.expand, children: [
                                AppNetworkImage(p.images.isNotEmpty ? p.images.first : null),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: HC.gold, shape: BoxShape.circle),
                                    child: const Icon(Icons.shield_rounded, size: 12, color: HC.emeraldDark),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                const Icon(Icons.auto_awesome, size: 12, color: HC.goldDark),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(p.category.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: HC.goldDark, letterSpacing: 1)),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: HC.emerald),
                              ]),
                              const SizedBox(height: 2),
                              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: heading(15, height: 1.25)),
                              const SizedBox(height: 3),
                              Text(p.heritagePassportNumber, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontFamily: 'monospace')),
                              const SizedBox(height: 6),
                              Row(children: [
                                VerificationBadge(status: p.status),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(p.artisan.location.split(',').first,
                                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                                ),
                              ]),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(children: [
                        Icon(Icons.description_outlined, size: 48, color: HC.teak.o(0.35)),
                        const SizedBox(height: 10),
                        Text('No passports found', style: heading(19)),
                        const SizedBox(height: 4),
                        Text('Try adjusting your search', style: TextStyle(color: Colors.grey.shade600)),
                      ]),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: AppCard(
                  color: HC.cream,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.description_rounded, color: HC.emerald, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('About Heritage Passports', style: TextStyle(fontWeight: FontWeight.w700, color: HC.emeraldDark)),
                        const SizedBox(height: 4),
                        Text(
                          'Each Digital Heritage Passport is a premium blockchain-verified certificate that proves authenticity, traces provenance, and tells the cultural story behind every Malaysian heritage craft.',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.5),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
