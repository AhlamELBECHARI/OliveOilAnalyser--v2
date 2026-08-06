import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:olive_iq_app/features/analyseur/data/protocole/protocole_spectrometre.dart';
import 'package:olive_iq_app/features/analyseur/domain/entities/commande_analyseur.dart';

Uint8List _octets(String texte) => Uint8List.fromList(texte.codeUnits);

void main() {
  group('parserLignePoint', () {
    test('parse une ligne SPEC valide en PointSpectreEntity', () {
      final point = parserLignePoint('SPEC,930.5,0.1234');

      expect(point, isNotNull);
      expect(point!.longueurOndeNm, 930.5);
      expect(point.absorbance, 0.1234);
    });

    test("renvoie null pour une ligne qui n'a pas le préfixe SPEC,", () {
      expect(parserLignePoint('SPEC_END'), isNull);
      expect(parserLignePoint('INFO,1234,fw,90'), isNull);
      expect(parserLignePoint(''), isNull);
    });

    test('renvoie null pour une ligne SPEC avec un nombre de champs incorrect', () {
      expect(parserLignePoint('SPEC,930.5'), isNull);
      expect(parserLignePoint('SPEC,930.5,0.1,extra'), isNull);
    });

    test('renvoie null pour une trame corrompue (valeurs non numériques)', () {
      expect(parserLignePoint('SPEC,abc,0.1'), isNull);
      expect(parserLignePoint('SPEC,930.5,xyz'), isNull);
    });
  });

  group('parserLigneInfo', () {
    test('parse une ligne INFO valide', () {
      final info = parserLigneInfo('INFO,UM6P-2026-00123,v2.1.4,87');

      expect(info, isNotNull);
      expect(info!.numeroSerie, 'UM6P-2026-00123');
      expect(info.firmware, 'v2.1.4');
      expect(info.batterie, 87);
    });

    test('renvoie batterie null si le champ n\'est pas un entier valide', () {
      final info = parserLigneInfo('INFO,SN,fw,inconnu');

      expect(info, isNotNull);
      expect(info!.batterie, isNull);
    });

    test("renvoie null pour une ligne qui n'a pas le préfixe INFO,", () {
      expect(parserLigneInfo('SPEC,1,2'), isNull);
    });

    test('renvoie null pour un nombre de champs incorrect', () {
      expect(parserLigneInfo('INFO,SN,fw'), isNull);
      expect(parserLigneInfo('INFO,SN,fw,90,extra'), isNull);
    });
  });

  group('encoderCommande', () {
    test('encode START_SCAN pour demarrerAcquisition, terminé par le suffixe de trame', () {
      final octets = encoderCommande(CommandeAnalyseur.demarrerAcquisition);
      expect(String.fromCharCodes(octets), 'START_SCAN\r\n');
    });

    test('encode CANCEL pour annulerAcquisition', () {
      final octets = encoderCommande(CommandeAnalyseur.annulerAcquisition);
      expect(String.fromCharCodes(octets), 'CANCEL\r\n');
    });
  });

  group('TamponTrames', () {
    test('renvoie une trame complète reçue en un seul paquet', () {
      final tampon = TamponTrames();
      final lignes = tampon.ajouter(_octets('SPEC,930.5,0.12\r\n'));

      expect(lignes, ['SPEC,930.5,0.12']);
    });

    test('reconstitue une trame reçue découpée sur plusieurs paquets', () {
      final tampon = TamponTrames();

      final premierPaquet = tampon.ajouter(_octets('SPEC,930'));
      expect(premierPaquet, isEmpty);

      final deuxiemePaquet = tampon.ajouter(_octets('.5,0.12\r\n'));
      expect(deuxiemePaquet, ['SPEC,930.5,0.12']);
    });

    test('renvoie plusieurs lignes complètes reçues dans un même paquet', () {
      final tampon = TamponTrames();
      final lignes = tampon.ajouter(_octets('SPEC,930.5,0.12\r\nSPEC,931.0,0.13\r\n'));

      expect(lignes, ['SPEC,930.5,0.12', 'SPEC,931.0,0.13']);
    });

    test('conserve le reste partiel pour le prochain appel sans le renvoyer', () {
      final tampon = TamponTrames();
      final lignes = tampon.ajouter(_octets('SPEC,930.5,0.12\r\nSPEC,931.0'));

      expect(lignes, ['SPEC,930.5,0.12']);

      final suite = tampon.ajouter(_octets(',0.13\r\n'));
      expect(suite, ['SPEC,931.0,0.13']);
    });
  });
}
