import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/heritage_card.dart';
import '../widgets/patterns.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<StatCard> _stats(AppState app) {
    final products = app.products;
    final verified = products.where((p) => p.isVerified).length;
    final scans = products.fold<int>(0, (s, p) => s + p.touristScans);
    final verifs = products.fold<int>(0, (s, p) => s + p.verificationRequests);

    switch (app.role) {
      case UserRole.artisan:
        return [
          StatCard(label: 'Registered Products', value: '${products.length}', icon: Icons.inventory_2_rounded, color: HC.emerald),
          StatCard(label: 'Verified Products', value: '$verified', icon: Icons.check_circle_rounded, color: const Color(0xFF16A34A)),
          StatCard(label: 'Tourist Scans', value: '$scans', icon: Icons.qr_code_2_rounded, color: HC.goldDark),
          StatCard(label: 'Verifications', value: '$verifs', icon: Icons.shield_rounded, color: HC.bronze),
        ];
      case UserRole.administrator:
        return [
          StatCard(label: 'Pending Reviews', value: '${AdminStats.verificationRequests}', icon: Icons.description_rounded, color: const Color(0xFFEAB308)),
          StatCard(label: 'Approved Today', value: '8', icon: Icons.check_circle_rounded, color: const Color(0xFF16A34A)),
          StatCard(label: 'Heritage Certificates', value: '${AdminStats.totalProducts}', icon: Icons.workspace_premium_rounded, color: HC.goldDark),
          StatCard(label: 'Provenance Records', value: '${AdminStats.provenanceRecords}', icon: Icons.timeline_rounded, color: HC.emerald),
        ];
      case UserRole.consumer:
        return [
          StatCard(label: 'Authentic Products', value: '${products.length}', icon: Icons.check_circle_rounded, color: const Color(0xFF16A34A)),
          StatCard(label: 'Verified Artisans', value: '${AdminStats.registeredArtisans}', icon: Icons.groups_rounded, color: HC.goldDark),
          StatCard(label: 'Heritage Categories', value: '${AdminStats.heritageCategories}', icon: Icons.workspace_premium_rounded, color: HC.bronze),
          StatCard(label: 'Heritage Records', value: '${AdminStats.provenanceRecords}', icon: Icons.description_rounded, color: HC.emerald),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final products = app.products;

    return Scaffold(
      body: RefreshIndicator(
        color: HC.emerald,
        onRefresh: app.loadProducts,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // ---- Hero ----
            GradientHeader(
              patternOpacity: 0.08,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 30),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${greeting()},', style: TextStyle(color: HC.cream.o(0.85), fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        app.user?.name.isNotEmpty == true ? app.user!.name : 'Welcome',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: heading(26, color: Colors.white),
                      ),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.o(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: HC.gold.o(0.5)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.shield_outlined, size: 14, color: HC.gold),
                      const SizedBox(width: 6),
                      Text(app.role.label, style: const TextStyle(color: HC.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 22),
                Text('HERITAGE AUTHENTICATION PLATFORM',
                    style: TextStyle(color: HC.cream.o(0.7), fontSize: 11, letterSpacing: 2)),
                const SizedBox(height: 6),
                Text.rich(TextSpan(children: [
                  TextSpan(text: 'Preserving ', style: heading(24, color: Colors.white, weight: FontWeight.w600)),
                  TextSpan(text: 'Malaysian Heritage', style: heading(24, color: HC.gold)),
                ])),
              ]),
            ),

            if (app.usingCache)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.cloud_off_rounded, size: 18, color: Color(0xFF854D0E)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Offline - showing saved data. Pull down to refresh.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF854D0E))),
                  ),
                ]),
              ),

            // ---- Statistik ----
            Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: TwoColumn(children: _stats(app))),

            // ---- Quick actions ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Quick Actions', style: heading(20)),
                const SizedBox(height: 12),
                TwoColumn(children: [
                  _Action(icon: Icons.qr_code_scanner_rounded, title: 'Verify', sub: 'Scan QR / NFC', color: HC.emerald, onTap: () => context.push('/verify')),
                  _Action(icon: Icons.description_rounded, title: 'Passports', sub: 'View certificates', color: HC.bronze, onTap: () => context.push('/passport')),
                  _Action(icon: Icons.map_rounded, title: 'Heritage Map', sub: 'Explore locations', color: HC.forest, onTap: () => context.push('/map')),
                  if (app.role == UserRole.artisan)
                    _Action(icon: Icons.add_box_rounded, title: 'Register', sub: 'Add product', color: HC.goldDark, onTap: () => context.push('/register-product'))
                  else
                    _Action(icon: Icons.auto_awesome, title: 'Explore', sub: 'Browse crafts', color: HC.goldDark, onTap: () => context.push('/explore')),
                ]),
              ]),
            ),

            // ---- Featured ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
              child: SectionTitle(
                'Featured Heritage',
                trailing: TextButton(
                  onPressed: () => context.push('/explore'),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('See all', style: TextStyle(color: HC.emerald, fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right_rounded, color: HC.emerald, size: 20),
                  ]),
                ),
              ),
            ),
            if (app.productsLoading && products.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: LoadingView())
            else if (products.isEmpty)
              SizedBox(height: 260, child: ErrorView(message: app.productsError ?? 'No products yet.', onRetry: app.loadProducts))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final p in products.take(4))
                    Padding(padding: const EdgeInsets.only(right: 12), child: SizedBox(width: 290, child: HeritageCard(product: p))),
                ]),
              ),

            // ---- Peranan khusus ----
            if (app.role == UserRole.administrator)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [HC.navy, HC.emeraldDark]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Admin Tools', style: heading(18, color: Colors.white)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _AdminTool(icon: Icons.insights_rounded, label: 'Analytics', onTap: () => context.push('/admin-dashboard'))),
                      const SizedBox(width: 12),
                      Expanded(child: _AdminTool(icon: Icons.shield_rounded, label: 'Security', onTap: () => context.push('/cybersecurity'))),
                    ]),
                  ]),
                ),
              ),
            if (app.role == UserRole.artisan)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
                child: AppButton(
                  label: 'Open My Artisan Dashboard',
                  icon: Icons.dashboard_customize_rounded,
                  style: BtnStyle.outline,
                  onPressed: () => context.push('/artisan-dashboard'),
                ),
              ),

            // ---- Cerita warisan ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 28),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: HC.gradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(children: [
                    SongketPattern(opacity: 0.1),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: HC.gold, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.auto_awesome, color: HC.emeraldDark),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Heritage Story', style: heading(18, color: HC.gold)),
                          const SizedBox(height: 6),
                          Text(
                            'Every product on HAFA carries a story. Each piece is a testament to generations of Malaysian craftsmanship, preserved forever on the blockchain.',
                            style: TextStyle(color: HC.cream, fontSize: 13, height: 1.5),
                          ),
                        ]),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.title, required this.sub, required this.color, required this.onTap});
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: HC.emeraldDark, fontSize: 15)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ]),
      );
}

class _AdminTool extends StatelessWidget {
  const _AdminTool({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.o(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HC.gold.o(0.4)),
          ),
          child: Column(children: [
            Icon(icon, color: HC.gold, size: 26),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}
