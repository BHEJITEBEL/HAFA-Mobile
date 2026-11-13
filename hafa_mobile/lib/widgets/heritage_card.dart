import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/product.dart';
import 'common.dart';

class HeritageCard extends StatelessWidget {
  const HeritageCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => context.push('/product/${Uri.encodeComponent(p.id)}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HC.creamDark),
            boxShadow: [BoxShadow(color: Colors.black.o(0.05), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(fit: StackFit.expand, children: [
                AppNetworkImage(p.images.isNotEmpty ? p.images.first : null),
                Positioned(top: 10, right: 10, child: VerificationBadge(status: p.status)),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: HC.emerald.o(0.92), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.auto_awesome, size: 12, color: HC.gold),
                      const SizedBox(width: 5),
                      Text(p.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: heading(17, height: 1.25)),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 36),
                  child: Text(
                    p.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
                  ),
                ),
                const SizedBox(height: 8),
                _meta(Icons.person_outline_rounded, p.artisan.name),
                const SizedBox(height: 4),
                _meta(Icons.place_outlined, p.artisan.location),
                const SizedBox(height: 10),
                Container(height: 1, color: HC.creamDark),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: Text(p.price, maxLines: 1, overflow: TextOverflow.ellipsis, style: heading(17, color: HC.goldDark)),
                  ),
                  Text('ID: ${p.id}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(children: [
        Icon(icon, size: 15, color: HC.emerald),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
        ),
      ]);
}
