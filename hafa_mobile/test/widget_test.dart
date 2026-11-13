import 'package:flutter_test/flutter_test.dart';
import 'package:hafa_mobile/core/utils.dart';
import 'package:hafa_mobile/models/product.dart';
import 'package:hafa_mobile/services/api_service.dart';

void main() {
  group('extractVerificationKey', () {
    test('hafa:// deep link', () {
      expect(extractVerificationKey('hafa://verify/HAFA-2024-TRG-001'), 'HAFA-2024-TRG-001');
    });
    test('https URL dengan /verify/<id>', () {
      expect(extractVerificationKey('https://hafa.my/verify/HP001'), 'HP001');
    });
    test('teks biasa', () {
      expect(extractVerificationKey('  HAFA-2024-TRG-001 '), 'HAFA-2024-TRG-001');
    });
    test('URL tanpa ID bukan kod HAFA', () {
      expect(extractVerificationKey('https://example.com'), isNull);
      expect(extractVerificationKey(''), isNull);
    });
  });

  group('ApiService.normalize', () {
    test('tambah http:// dan buang / serta /api', () {
      expect(ApiService.normalize('192.168.1.10:8001/'), 'http://192.168.1.10:8001');
      expect(ApiService.normalize('http://10.0.2.2:8001/api'), 'http://10.0.2.2:8001');
    });
    test('resolveUrl untuk laluan relatif dan URL penuh', () {
      final api = ApiService('http://10.0.2.2:8001');
      expect(api.resolveUrl('/uploads/a.jpg'), 'http://10.0.2.2:8001/uploads/a.jpg');
      expect(api.resolveUrl('https://x.test/a.jpg'), 'https://x.test/a.jpg');
    });
  });

  group('Product', () {
    test('fromJson / toJson dan getter', () {
      final p = Product.fromJson({
        'id': 'HP001',
        'name': 'Songket',
        'verificationId': 'HAFA-2024-TRG-001',
        'status': 'Verified',
        'artisan': {'name': 'Aminah', 'verified': true},
        'images': ['/uploads/a.jpg'],
        'touristScans': 12,
        'provenanceTimeline': [
          {'event': 'Created', 'verified': true}
        ],
      });
      expect(p.isVerified, isTrue);
      expect(p.verifyUri, 'hafa://verify/HAFA-2024-TRG-001');
      expect(p.artisan.name, 'Aminah');
      expect(p.touristScans, 12);
      expect(Product.fromJson(p.toJson()).provenanceTimeline.first.event, 'Created');
    });
    test('data tidak lengkap tidak menyebabkan ralat', () {
      final p = Product.fromJson({'id': 'X'});
      expect(p.status, 'Pending Verification');
      expect(p.images, isEmpty);
      expect(p.verifyKey, 'X');
    });
  });
}
