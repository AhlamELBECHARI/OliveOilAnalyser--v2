import 'package:drift/drift.dart';

import 'resultats_locaux_table.dart';

/// Miroir local de backend.resultats.models.PredictionModele : une ligne
/// par modèle appliqué au scan d'un [ResultatsLocaux]. `modeleId` référence
/// un Modele existant côté backend (jamais créé côté mobile) — voir
/// nouvelle_analyse, qui répartit le résultat de scoring sur les modèles
/// actifs correspondants avant l'écriture locale.
///
/// `@DataClassName` force le nom de la classe générée à
/// `PredictionsLocalesData` (au lieu du `PredictionsLocale` singularisé
/// automatiquement par Drift), pour rester cohérent avec les tables sœurs
/// (EchantillonsLocauxData, SpectresLocauxData, ResultatsLocauxData).
@DataClassName('PredictionsLocalesData')
class PredictionsLocales extends Table {
  TextColumn get id => text()();
  TextColumn get resultatId => text().references(ResultatsLocaux, #id)();
  IntColumn get modeleId => integer()();
  RealColumn get valeurNumerique => real().nullable()();
  TextColumn get classePredite => text().withDefault(const Constant(''))();
  RealColumn get scoreConfiance => real().nullable()();
  DateTimeColumn get dateCreationLocale => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
