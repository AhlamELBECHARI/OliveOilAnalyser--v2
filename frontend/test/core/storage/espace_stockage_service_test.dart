import 'package:flutter_test/flutter_test.dart';
import 'package:olive_iq_app/core/storage/espace_stockage_service.dart';

void main() {
  group('formaterTailleOctets', () {
    test('affiche les octets tels quels sous 1024', () {
      expect(formaterTailleOctets(512), '512 o');
    });

    test('convertit en Ko/Mo/Go en choisissant la plus grande unité pertinente', () {
      expect(formaterTailleOctets(2048), '2 Ko');
      expect(formaterTailleOctets(5 * 1024 * 1024), '5 Mo');
      expect(formaterTailleOctets(3 * 1024 * 1024 * 1024), '3 Go');
    });

    test('affiche une décimale sous 10 unités, aucune au-delà', () {
      expect(formaterTailleOctets((1.5 * 1024 * 1024).round()), '1.5 Mo');
      expect(formaterTailleOctets(12 * 1024 * 1024), '12 Mo');
    });
  });
}
