class CraftCategory {
  const CraftCategory(this.id, this.name, this.icon);
  final String id;
  final String name;
  final String icon;

  /// Nilai kategori yang disimpan pada produk (cth. "Pottery"); sepadan dengan penapis Explore (id huruf kecil).
  String get value => id[0].toUpperCase() + id.substring(1);
}

const List<CraftCategory> craftCategories = [
  CraftCategory('songket', 'Songket', '🧵'),
  CraftCategory('batik', 'Batik', '🎨'),
  CraftCategory('keris', 'Keris', '⚔️'),
  CraftCategory('pottery', 'Labu Sayong', '🏺'),
  CraftCategory('tenun', 'Tenun', '🧶'),
  CraftCategory('wau', 'Wau', '🪁'),
  CraftCategory('carving', 'Wood Carving', '🪵'),
  CraftCategory('other', 'Other Crafts', '✨'),
];

class HeritageLocation {
  const HeritageLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.state,
    required this.description,
    required this.crafts,
    required this.artisans,
  });
  final String id;
  final String name;
  final String type;
  final double lat;
  final double lng;
  final String state;
  final String description;
  final List<String> crafts;
  final int artisans;
}

const List<HeritageLocation> heritageLocations = [
  HeritageLocation(
    id: 'LOC001',
    name: 'Terengganu Songket Weaving Village',
    type: 'Artisan Workshop',
    lat: 5.3302,
    lng: 103.1408,
    state: 'Terengganu',
    description: 'Traditional songket weaving center preserving centuries-old techniques',
    crafts: ['Songket'],
    artisans: 15,
  ),
  HeritageLocation(
    id: 'LOC002',
    name: 'Kota Bharu Batik Centre',
    type: 'Cultural Site',
    lat: 6.1248,
    lng: 102.2386,
    state: 'Kelantan',
    description: 'Hub of traditional batik artisans and batik-making workshops',
    crafts: ['Batik'],
    artisans: 25,
  ),
  HeritageLocation(
    id: 'LOC003',
    name: 'Alor Setar Keris Heritage Museum',
    type: 'Heritage Site',
    lat: 6.1248,
    lng: 100.3673,
    state: 'Kedah',
    description: 'Museum and workshop dedicated to the art of keris-making',
    crafts: ['Keris'],
    artisans: 5,
  ),
  HeritageLocation(
    id: 'LOC004',
    name: 'Sayong Pottery Village',
    type: 'Artisan Village',
    lat: 4.8479,
    lng: 100.7414,
    state: 'Perak',
    description: 'Famous village where Labu Sayong pottery has been made for generations',
    crafts: ['Labu Sayong'],
    artisans: 12,
  ),
  HeritageLocation(
    id: 'LOC005',
    name: 'Kuala Lumpur Craft Cultural Complex',
    type: 'Tourism Location',
    lat: 3.1390,
    lng: 101.6869,
    state: 'Kuala Lumpur',
    description: 'National showcase for Malaysian heritage crafts',
    crafts: ['Various'],
    artisans: 40,
  ),
];

/// Statistik admin (data contoh statik, sama seperti versi web).
class AdminStats {
  const AdminStats._();
  static const totalProducts = 247;
  static const registeredArtisans = 89;
  static const verificationRequests = 15;
  static const fraudAlerts = 2;
  static const heritageCategories = 8;
  static const provenanceRecords = 1834;
  static const monthlyScans = 3456;
  static const activeListings = 156;
}
