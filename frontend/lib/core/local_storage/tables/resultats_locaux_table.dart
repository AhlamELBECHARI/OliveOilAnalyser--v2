import 'package:drift/drift.dart';

import 'echantillons_locaux_table.dart';

/// Miroir local de backend.resultats.models.Resultat. Alimentée par
/// l'écran Nouvelle Analyse à l'issue d'un scan (voir
/// nouvelle_analyse_provider.dart) : les prédictions par modèle associées
/// vivent dans [PredictionsLocales] (voir predictions_locales_table.dart).
/// Avec l'analyseur Bluetooth réel, le pipeline de scoring n'est pas encore
/// câblé côté protocole (même limite assumée que la carte "Paramètres
/// d'Acquisition") — voir AnalyseurRepository.flusResultat.
class ResultatsLocaux extends Table {
  TextColumn get id => text()();
  TextColumn get echantillonId => text().references(EchantillonsLocaux, #id)();
  IntColumn get modeleUtiliseId => integer().nullable()();
  RealColumn get acidite => real().nullable()();
  RealColumn get indicePeroxyde => real().nullable()();
  DateTimeColumn get dateCalcul => dateTime().nullable()();
  IntColumn get dureeAnalyseSecondes => integer().nullable()();
  BoolColumn get conforme => boolean().nullable()();
  TextColumn get commentaire => text().withDefault(const Constant(''))();
  DateTimeColumn get dateCreationLocale => dateTime().withDefault(currentDateAndTime)();
  TextColumn get statutSync => text().withDefault(const Constant('enAttente'))();
  TextColumn get messageErreurSync => text().nullable()();
  IntColumn get nombreTentativesSync => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
