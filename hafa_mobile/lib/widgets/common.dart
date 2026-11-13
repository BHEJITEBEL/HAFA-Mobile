import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/product.dart';
import '../state/app_state.dart';

/// Gambar rangkaian dengan cache + pemegang tempat apabila tiada/ralat.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(this.url, {super.key, this.fit = BoxFit.cover, this.width, this.height});
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;

  Widget _placeholder({bool loading = false}) => Container(
        width: width,
        height: height,
        color: HC.creamDark,
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: HC.gold),
              )
            : Icon(Icons.image_outlined, color: HC.teak.o(0.35), size: 34),
      );

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) return _placeholder();
    final resolved = context.read<AppState>().api.resolveUrl(u);
    return CachedNetworkImage(
      imageUrl: resolved,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) => _placeholder(loading: true),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }
}

class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, required this.status, this.large = false});
  final String status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    final Color bg;
    switch (status) {
      case 'Pending':
      case 'Pending Verification':
        icon = Icons.schedule_rounded;
        color = const Color(0xFFCA8A04);
        bg = const Color(0xFFFEFCE8);
        break;
      case 'Rejected':
        icon = Icons.cancel_rounded;
        color = const Color(0xFFDC2626);
        bg = const Color(0xFFFEF2F2);
        break;
      default:
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF16A34A);
        bg = const Color(0xFFF0FDF4);
    }
    final size = large ? 18.0 : 14.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 12 : 8, vertical: large ? 6 : 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.o(0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: size, color: color),
        const SizedBox(width: 4),
        Text(status, style: TextStyle(fontSize: large ? 13 : 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HC.creamDark),
            boxShadow: [BoxShadow(color: Colors.black.o(0.04), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: child,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(text, style: heading(20))),
        if (trailing != null) trailing!,
      ]);
}

/// Baris: ikon emas + label kecil + nilai.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.label, required this.value, this.mono = false});
  final IconData icon;
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: HC.gold.o(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 19, color: HC.goldDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, letterSpacing: 0.4)),
            const SizedBox(height: 2),
            Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: HC.teak,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

enum BtnStyle { gold, emerald, outline, ghostLight }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = BtnStyle.emerald,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final BtnStyle style;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;
    switch (style) {
      case BtnStyle.gold:
        bg = HC.gold;
        fg = HC.emeraldDark;
        break;
      case BtnStyle.outline:
        bg = Colors.transparent;
        fg = HC.emerald;
        side = const BorderSide(color: HC.emerald, width: 1.5);
        break;
      case BtnStyle.ghostLight:
        bg = Colors.white.o(0.1);
        fg = HC.gold;
        side = const BorderSide(color: HC.gold, width: 1.5);
        break;
      case BtnStyle.emerald:
        bg = HC.emerald;
        fg = Colors.white;
        break;
    }
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.o(0.6),
          disabledForegroundColor: fg.o(0.6),
          elevation: style == BtnStyle.gold ? 3 : 0,
          side: side,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: loading
            ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
            : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ]),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: HC.emerald),
          if (message != null) ...[const SizedBox(height: 14), Text(message!, style: const TextStyle(color: HC.teak))],
        ]),
      );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: HC.teak.o(0.4)),
            const SizedBox(height: 14),
            Text('Something went wrong', style: heading(20)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              SizedBox(width: 180, child: AppButton(label: 'Try again', icon: Icons.refresh_rounded, onPressed: onRetry)),
            ],
          ]),
        ),
      );
}

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key, this.title = 'Product Not Found'});
  final String title;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.search_off_rounded, size: 56, color: HC.teak.o(0.4)),
            const SizedBox(height: 14),
            Text(title, style: heading(22)),
            const SizedBox(height: 18),
            SizedBox(
              width: 220,
              child: AppButton(label: 'Back to Explore', icon: Icons.arrow_back_rounded, onPressed: () => context.go('/explore')),
            ),
          ]),
        ),
      );
}

/// Muatkan produk mengikut id / verificationId (tempatan dahulu, kemudian server).
class ProductLoader extends StatefulWidget {
  const ProductLoader({
    super.key,
    required this.productKey,
    required this.builder,
    this.notFoundTitle = 'Product Not Found',
  });
  final String productKey;
  final Widget Function(BuildContext context, Product product) builder;
  final String notFoundTitle;

  @override
  State<ProductLoader> createState() => _ProductLoaderState();
}

class _ProductLoaderState extends State<ProductLoader> {
  Future<Product?>? _future;
  Product? _local;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final app = context.read<AppState>();
    _local = app.findProduct(widget.productKey);
    _future = _local != null ? Future<Product?>.value(_local) : app.resolveProduct(widget.productKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: _future,
      initialData: _local,
      builder: (context, snap) {
        final p = snap.data;
        if (p != null) return widget.builder(context, p);
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: LoadingView());
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('HAFA')),
            body: ErrorView(message: snap.error.toString(), onRetry: () => setState(_load)),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('HAFA')),
          body: NotFoundView(title: widget.notFoundTitle),
        );
      },
    );
  }
}

/// Susun [children] dalam grid 2 lajur tanpa shrinkWrap GridView.
class TwoColumn extends StatelessWidget {
  const TwoColumn({super.key, required this.children, this.spacing = 12});
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: children[i]),
            SizedBox(width: spacing),
            Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox.shrink()),
          ]),
        ),
      );
      if (i + 2 < children.length) rows.add(SizedBox(height: spacing));
    }
    return Column(children: rows);
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color, this.sub});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value, style: heading(24)),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(sub!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ]),
    );
  }
}

/// Ruang tajuk halaman dalam kepala bergradien (ikon + tajuk + sub).
class HeaderTitle extends StatelessWidget {
  const HeaderTitle({super.key, required this.icon, required this.title, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: HC.gold, borderRadius: BorderRadius.circular(18)),
          child: Icon(icon, size: 32, color: HC.emeraldDark),
        ),
        const SizedBox(height: 14),
        Text(title, textAlign: TextAlign.center, style: heading(26, color: Colors.white)),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(color: HC.cream.o(0.9), fontSize: 14, height: 1.4)),
        ],
      ]);
}
