import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/product.dart';
import '../widgets/common.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.productKey});
  final String productKey;

  @override
  Widget build(BuildContext context) {
    return ProductLoader(
      productKey: productKey,
      builder: (context, product) => _ProductDetailView(product: product),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView({required this.product});
  final Product product;

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.images;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 320,
          backgroundColor: HC.emerald,
          foregroundColor: Colors.white,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.o(0.4), shape: BoxShape.circle),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => goBack(context, fallback: '/explore'),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              if (images.isEmpty)
                const AppNetworkImage(null)
              else
                PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => AppNetworkImage(images[i]),
                ),
              if (images.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (var i = 0; i < images.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _page ? HC.gold : Colors.white.o(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ]),
                ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              VerificationBadge(status: p.status, large: true),
              const SizedBox(height: 12),
              Text(p.name, style: heading(26, height: 1.2)),
              const SizedBox(height: 6),
              Text(p.price, style: heading(24, color: HC.goldDark)),
              const SizedBox(height: 12),
              Text(p.description, style: TextStyle(fontSize: 14.5, color: Colors.grey.shade800, height: 1.55)),
              const SizedBox(height: 14),
              AppCard(
                child: Column(children: [
                  InfoRow(icon: Icons.person_outline_rounded, label: 'Artisan', value: '${p.artisan.name}\n${p.artisan.experience} experience'),
                  InfoRow(icon: Icons.place_outlined, label: 'Location', value: p.artisan.location),
                  InfoRow(icon: Icons.calendar_today_outlined, label: 'Production Date', value: p.productionDate),
                  InfoRow(icon: Icons.inventory_2_outlined, label: 'Materials', value: p.materials.join(', ')),
                ]),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'View Heritage Passport',
                icon: Icons.description_rounded,
                onPressed: () => context.push('/heritage-passport/${Uri.encodeComponent(p.id)}'),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Verify Product',
                icon: Icons.qr_code_2_rounded,
                style: BtnStyle.gold,
                onPressed: () => context.push('/qr-verify/${Uri.encodeComponent(p.id)}'),
              ),

              // ---- Cerita ----
              const SizedBox(height: 28),
              Text('The Story Behind This Craft', style: heading(21)),
              const SizedBox(height: 10),
              AppCard(
                color: HC.cream,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.culturalSignificance, style: const TextStyle(fontSize: 14.5, height: 1.6, color: HC.teak)),
                  const SizedBox(height: 14),
                  Text('Production Method', style: heading(16, color: HC.emerald)),
                  const SizedBox(height: 4),
                  Text(p.productionMethod, style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade800)),
                ]),
              ),

              // ---- Artisan ----
              const SizedBox(height: 28),
              Text('Meet the Artisan', style: heading(21)),
              const SizedBox(height: 10),
              AppCard(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(gradient: HC.gradient, shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded, color: HC.gold, size: 34),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.artisan.name, style: heading(17)),
                      const SizedBox(height: 4),
                      Text(p.artisan.bio, style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700, height: 1.45)),
                      const SizedBox(height: 10),
                      Wrap(spacing: 14, runSpacing: 6, children: [
                        _tag(Icons.check_circle_rounded, 'Verified Artisan', const Color(0xFF16A34A)),
                        _tag(Icons.schedule_rounded, '${p.artisan.experience} Experience', HC.emerald),
                      ]),
                    ]),
                  ),
                ]),
              ),

              // ---- Provenance ----
              const SizedBox(height: 28),
              Text('Provenance Timeline', style: heading(21)),
              const SizedBox(height: 14),
              for (var i = 0; i < p.provenanceTimeline.length; i++)
                _TimelineTile(event: p.provenanceTimeline[i], isLast: i == p.provenanceTimeline.length - 1),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _tag(IconData icon, String text, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
      ]);
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event, required this.isLast});
  final ProvenanceEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ok = event.verified;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 44,
          child: Column(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: ok ? const Color(0xFFDCFCE7) : Colors.grey.shade200, shape: BoxShape.circle),
              child: Icon(Icons.check_circle_rounded, size: 22, color: ok ? const Color(0xFF22C55E) : Colors.grey.shade400),
            ),
            if (!isLast) Expanded(child: Container(width: 2, color: HC.gold.o(0.45))),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.event, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: HC.emeraldDark)),
              const SizedBox(height: 2),
              Text('${event.date} at ${event.timestamp}', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text.rich(TextSpan(style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700), children: [
                const TextSpan(text: 'Responsible: '),
                TextSpan(text: event.responsible, style: const TextStyle(fontWeight: FontWeight.w600, color: HC.emerald)),
              ])),
            ]),
          ),
        ),
      ]),
    );
  }
}
