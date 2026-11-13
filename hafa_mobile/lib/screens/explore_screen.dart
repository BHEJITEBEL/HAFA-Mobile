import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/heritage_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  String _query = '';
  String _category = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final q = _query.toLowerCase();
    final filtered = app.products.where((p) {
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.artisan.name.toLowerCase().contains(q);
      final matchesCat = _category == 'all' || p.category.toLowerCase() == _category;
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Crafts'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => goBack(context)),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Discover Heritage Crafts', style: heading(22)),
            const SizedBox(height: 4),
            Text('Authentic Malaysian artisan products verified on the blockchain',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search by product, artisan or description',
                prefixIcon: const Icon(Icons.search_rounded, color: HC.emerald),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HC.creamDark)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HC.creamDark)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HC.emerald, width: 2)),
              ),
            ),
          ]),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip('All Crafts', 'all'),
              for (final c in craftCategories) _chip('${c.icon} ${c.name}', c.id),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(TextSpan(style: TextStyle(color: Colors.grey.shade700, fontSize: 13), children: [
              const TextSpan(text: 'Found '),
              TextSpan(text: '${filtered.length}', style: const TextStyle(color: HC.emerald, fontWeight: FontWeight.w700)),
              TextSpan(text: ' heritage craft${filtered.length == 1 ? '' : 's'}'),
            ])),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: HC.emerald,
            onRefresh: app.loadProducts,
            child: _body(app, filtered),
          ),
        ),
      ]),
    );
  }

  Widget _body(AppState app, List<Product> filtered) {
    if (app.productsLoading && app.products.isEmpty) return const LoadingView();
    if (app.products.isEmpty) {
      return ListView(children: [
        SizedBox(height: 320, child: ErrorView(message: app.productsError ?? 'No products yet.', onRetry: app.loadProducts)),
      ]);
    }
    if (filtered.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 60),
        Icon(Icons.auto_awesome, size: 48, color: HC.teak.o(0.35)),
        const SizedBox(height: 12),
        Center(child: Text('No crafts found', style: heading(20))),
        const SizedBox(height: 6),
        Center(child: Text('Try adjusting your search or filter criteria', style: TextStyle(color: Colors.grey.shade600))),
      ]);
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => HeritageCard(product: filtered[i]),
    );
  }

  Widget _chip(String label, String id) {
    final selected = _category == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => setState(() => _category = id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? HC.emerald : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? HC.emerald : HC.emerald.o(0.25), width: 1.5),
          ),
          child: Text(label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: selected ? Colors.white : HC.emerald)),
        ),
      ),
    );
  }
}
