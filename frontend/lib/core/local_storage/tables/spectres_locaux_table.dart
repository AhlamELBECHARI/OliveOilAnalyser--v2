import 'package:drift/drift.dart';

import 'echantillons_locaux_table.dart';

/// Miroir local de backend.spectres.models.Spectre. Les valeurs du spectre
/// sont stockées en JSON (comme côté backend, où valeurs_x/valeurs_y sont
/// des JSONField) plutôt que dans des tables séparées par point : un
/// spectre à 1024 points n'a pas besoin d'être normalisé pour un usage
/// exclusivement lecture/écriture en bloc.
class SpectresLocaux extends Table {
  TextColumn get id => text()();
  TextColumn get echantillonId => text().references(EchantillonsLocaux, #id)();
  TextColumn get valeursXJson => text()();
  TextColumn get valeursYJson => text()();
  IntColumn get nombreSeries => integer()();
  DateTimeColumn get dateAcquisition => dateTime()();
  TextColumn get checksum => text().withDefault(const Constant(''))();
  IntColumn get tailleDonnees => integer().nullable()();
  DateTimeColumn get dateCreationLocale => dateTime().withDefault(currentDateAndTime)();
  TextColumn get statutSync => text().withDefault(const Constant('enAttente'))();
  TextColumn get messageErreurSync => text().nullable()();
  IntColumn get nombreTentativesSync => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
