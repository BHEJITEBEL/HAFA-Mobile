import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

/// Peta warisan (OpenStreetMap) — ganti Leaflet pada versi web.
class HeritageMapScreen extends StatefulWidget {
  const HeritageMapScreen({super.key});

  @override
  State<HeritageMapScreen> createState() => _HeritageMapScreenState();
}

class _HeritageMapScreenState extends State<HeritageMapScreen> {
  final MapController _map = MapController();
  HeritageLocation? _selected;

  void _select(HeritageLocation l) {
    setState(() => _selected = l);
    _map.move(LatLng(l.lat, l.lng), 9);
  }

  @override
  Widget build(BuildContext context) {
    final sel = _selected;
    return Scaffold(
      appBar: AppBar(title: const Text('Heritage Map')),
      body: Column(children: [
        SizedBox(
          height: 320,
          child: Stack(children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: const LatLng(4.6, 102.0),
                initialZoom: 6.2,
                minZoom: 4,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'my.hafa.hafa_mobile',
                ),
                MarkerLayer(markers: [
                  for (final l in heritageLocations)
                    Marker(
                      point: LatLng(l.lat, l.lng),
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => _select(l),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: sel?.id == l.id ? 46 : 36,
                          color: sel?.id == l.id ? HC.gold : HC.emerald,
                          shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
                        ),
                      ),
                    ),
                ]),
              ],
            ),
            Positioned(
              right: 6,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.white.o(0.8),
                child: const Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10, color: Colors.black87)),
              ),
            ),
          ]),
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            if (sel != null) ...[
              AppCard(
                color: HC.cream,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(sel.name, style: heading(18))),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        setState(() => _selected = null);
                        _map.move(const LatLng(4.6, 102.0), 6.2);
                      },
                    ),
                  ]),
                  Text('${sel.type}  -  ${sel.state}', style: const TextStyle(color: HC.goldDark, fontWeight: FontWeight.w700, fontSize: 12.5)),
                  const SizedBox(height: 8),
                  Text(sel.description, style: TextStyle(color: Colors.grey.shade800, height: 1.45)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    for (final c in sel.crafts)
                      Chip(
                        label: Text(c, style: const TextStyle(fontSize: 12, color: HC.emerald, fontWeight: FontWeight.w600)),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: HC.emerald.o(0.3)),
                        visualDensity: VisualDensity.compact,
                      ),
                    Chip(
                      avatar: const Icon(Icons.groups_rounded, size: 16, color: HC.goldDark),
                      label: Text('${sel.artisans} artisans', style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
            ],
            Text('Heritage Locations', style: heading(19)),
            const SizedBox(height: 10),
            for (final l in heritageLocations)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () => _select(l),
                  child: Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: sel?.id == l.id ? HC.gold : HC.emerald, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.place_rounded, color: sel?.id == l.id ? HC.emeraldDark : Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: HC.emeraldDark)),
                        const SizedBox(height: 2),
                        Text('${l.state}  -  ${l.crafts.join(', ')}', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
                      ]),
                    ),
                  ]),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}
