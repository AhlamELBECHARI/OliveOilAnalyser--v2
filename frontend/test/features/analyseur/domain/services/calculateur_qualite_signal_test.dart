import 'package:flutter_test/flutter_test.dart';
import 'package:olive_iq_app/features/analyseur/domain/entities/spectre_entity.dart';
import 'package:olive_iq_app/features/analyseur/domain/services/calculateur_qualite_signal.dart';

SpectreBrutEntity _spectre(List<double> absorbances) {
  return SpectreBrutEntity(
    dateAcquisition: DateTime(2026, 1, 1),
    points: [
      for (var i = 0; i < absorbances.length; i++)
        PointSpectreEntity(longueurOndeNm: 400.0 + i, absorbance: absorbances[i]),
    ],
  );
}

void main() {
  group('calculerQualiteSignal', () {
    test('renvoie des indicateurs à zéro pour un spectre vide', () {
      final qualite = calculerQualiteSignal(_spectre(const []));

      expect(qualite.snrDb, 0);
      expect(qualite.intensitePourcentage, 0);
      expect(qualite.bruit, 0);
      expect(qualite.qualiteGlobalePourcentage, 0);
    });

    test('un signal parfaitement plat (sans bruit) donne un bruit nul et un SNR au plafond', () {
      final qualite = calculerQualiteSignal(_spectre(List.filled(50, 0.5)));

      expect(qualite.bruit, 0);
      expect(qualite.snrDb, 60.0);
    });

    test('un signal plus bruité produit un indicateur de bruit plus élevé', () {
      final calme = calculerQualiteSignal(
        _spectre([for (var i = 0; i < 100; i++) 0.5 + (i.isEven ? 0.001 : -0.001)]),
      );
      final bruyant = calculerQualiteSignal(
        _spectre([for (var i = 0; i < 100; i++) 0.5 + (i.isEven ? 0.3 : -0.3)]),
      );

      expect(bruyant.bruit, greaterThan(calme.bruit));
    });

    test('intensité et qualité globale restent bornées entre 0 et 100', () {
      final qualite = calculerQualiteSignal(_spectre([for (var i = 0; i < 100; i++) i * 10.0]));

      expect(qualite.intensitePourcentage, inInclusiveRange(0, 100));
      expect(qualite.qualiteGlobalePourcentage, inInclusiveRange(0, 100));
    });

    test('un pic plus haut au-dessus de la moyenne augmente l\'intensité mesurée', () {
      final base = List<double>.filled(50, 0.1);
      final faible = calculerQualiteSignal(_spectre([...base]));

      final avecPic = List<double>.from(base);
      avecPic[25] = 1.4;
      final fort = calculerQualiteSignal(_spectre(avecPic));

      expect(fort.intensitePourcentage, greaterThan(faible.intensitePourcentage));
    });
  });
}
