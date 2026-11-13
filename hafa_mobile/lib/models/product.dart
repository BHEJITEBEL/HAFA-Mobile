String _s(dynamic v) => v == null ? '' : v.toString();
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse(_s(v)) ?? 0;
List<T> _list<T>(dynamic v, T Function(dynamic) f) => v is List ? v.map(f).toList() : <T>[];
Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

class Artisan {
  const Artisan({
    this.name = '',
    this.location = '',
    this.experience = '',
    this.verified = false,
    this.bio = '',
  });

  final String name;
  final String location;
  final String experience;
  final bool verified;
  final String bio;

  factory Artisan.fromJson(dynamic raw) {
    final j = _map(raw);
    return Artisan(
      name: _s(j['name']),
      location: _s(j['location']),
      experience: _s(j['experience']),
      verified: j['verified'] == true,
      bio: _s(j['bio']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'experience': experience,
        'verified': verified,
        'bio': bio,
      };
}

class OwnershipRecord {
  const OwnershipRecord({
    this.owner = '',
    this.date = '',
    this.type = '',
    this.verificationBadge = false,
  });

  final String owner;
  final String date;
  final String type;
  final bool verificationBadge;

  factory OwnershipRecord.fromJson(dynamic raw) {
    final j = _map(raw);
    return OwnershipRecord(
      owner: _s(j['owner']),
      date: _s(j['date']),
      type: _s(j['type']),
      verificationBadge: j['verificationBadge'] == true,
    );
  }

  Map<String, dynamic> toJson() =>
      {'owner': owner, 'date': date, 'type': type, 'verificationBadge': verificationBadge};
}

class ProvenanceEvent {
  const ProvenanceEvent({
    this.event = '',
    this.date = '',
    this.timestamp = '',
    this.responsible = '',
    this.verified = false,
  });

  final String event;
  final String date;
  final String timestamp;
  final String responsible;
  final bool verified;

  factory ProvenanceEvent.fromJson(dynamic raw) {
    final j = _map(raw);
    return ProvenanceEvent(
      event: _s(j['event']),
      date: _s(j['date']),
      timestamp: _s(j['timestamp']),
      responsible: _s(j['responsible']),
      verified: j['verified'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'event': event,
        'date': date,
        'timestamp': timestamp,
        'responsible': responsible,
        'verified': verified,
      };
}

class Product {
  const Product({
    required this.id,
    required this.name,
    this.category = '',
    this.description = '',
    this.culturalSignificance = '',
    this.artisan = const Artisan(),
    this.materials = const [],
    this.productionDate = '',
    this.productionMethod = '',
    this.price = '',
    this.images = const [],
    this.verificationId = '',
    this.blockchainHash = '',
    this.ipfsCid = '',
    this.heritagePassportNumber = '',
    this.status = 'Pending Verification',
    this.ownershipHistory = const [],
    this.provenanceTimeline = const [],
    this.touristScans = 0,
    this.verificationRequests = 0,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String culturalSignificance;
  final Artisan artisan;
  final List<String> materials;
  final String productionDate;
  final String productionMethod;
  final String price;
  final List<String> images;
  final String verificationId;
  final String blockchainHash;
  final String ipfsCid;
  final String heritagePassportNumber;
  final String status;
  final List<OwnershipRecord> ownershipHistory;
  final List<ProvenanceEvent> provenanceTimeline;
  final int touristScans;
  final int verificationRequests;

  bool get isVerified => status == 'Verified';
  bool get isPending => status == 'Pending' || status == 'Pending Verification';

  /// Kunci yang dikodkan dalam QR / NFC (verificationId, jika tiada guna id).
  String get verifyKey => verificationId.isNotEmpty ? verificationId : id;

  /// Kandungan QR / NFC: hafa://verify/<kunci>
  String get verifyUri => 'hafa://verify/$verifyKey';

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: _s(j['id']),
        name: _s(j['name']),
        category: _s(j['category']),
        description: _s(j['description']),
        culturalSignificance: _s(j['culturalSignificance']),
        artisan: Artisan.fromJson(j['artisan']),
        materials: _list<String>(j['materials'], _s),
        productionDate: _s(j['productionDate']),
        productionMethod: _s(j['productionMethod']),
        price: _s(j['price']),
        images: _list<String>(j['images'], _s),
        verificationId: _s(j['verificationId']),
        blockchainHash: _s(j['blockchainHash']),
        ipfsCid: _s(j['ipfsCid']),
        heritagePassportNumber: _s(j['heritagePassportNumber']),
        status: _s(j['status']).isEmpty ? 'Pending Verification' : _s(j['status']),
        ownershipHistory: _list<OwnershipRecord>(j['ownershipHistory'], OwnershipRecord.fromJson),
        provenanceTimeline: _list<ProvenanceEvent>(j['provenanceTimeline'], ProvenanceEvent.fromJson),
        touristScans: _i(j['touristScans']),
        verificationRequests: _i(j['verificationRequests']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'culturalSignificance': culturalSignificance,
        'artisan': artisan.toJson(),
        'materials': materials,
        'productionDate': productionDate,
        'productionMethod': productionMethod,
        'price': price,
        'images': images,
        'verificationId': verificationId,
        'blockchainHash': blockchainHash,
        'ipfsCid': ipfsCid,
        'heritagePassportNumber': heritagePassportNumber,
        'status': status,
        'ownershipHistory': ownershipHistory.map((e) => e.toJson()).toList(),
        'provenanceTimeline': provenanceTimeline.map((e) => e.toJson()).toList(),
        'touristScans': touristScans,
        'verificationRequests': verificationRequests,
      };
}
