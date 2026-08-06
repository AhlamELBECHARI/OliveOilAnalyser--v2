import 'package:drift/drift.dart';

import 'echantillons_locaux_table.dart';

/// Miroir local de backend.resultats.models.Resultat. Réservée pour quand
/// un pipeline de scoring (modèle NIR) sera disponible : ce jalon ne
/// l'alimente pas encore côté écran Nouvelle Analyse (même limite assumée
/// que la carte "Paramètres d'Acquisition", non implémentée faute de
/// matériel documenté) — mais le schéma complet est posé dès maintenant
/// pour qu'aucune migration Drift ne soit nécessaire plus tard.
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
