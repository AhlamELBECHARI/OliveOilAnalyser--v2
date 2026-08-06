import 'package:drift/drift.dart';

/// Miroir local (Drift/SQLite) de backend.echantillons.models.Echantillon.
/// Toute création d'échantillon passe d'abord par cette table (voir
/// SynchronisationService) avant d'être envoyée, si le réseau est
/// disponible, à POST /api/echantillons/ avec le même [id] — un UUID
/// généré ici, côté mobile (voir EchantillonSerializer.id côté backend,
/// qui l'accepte tel quel pour que la synchronisation soit idempotente).
class EchantillonsLocaux extends Table {
  TextColumn get id => text()();
  TextColumn get numero => text()();
  DateTimeColumn get dateAnalyse => dateTime()();
  TextColumn get producteur => text().withDefault(const Constant(''))();
  TextColumn get region => text().withDefault(const Constant(''))();
  DateTimeColumn get dateRecolte => dateTime().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get variete => text().withDefault(const Constant(''))();
  TextColumn get origine => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get dateCreationLocale => dateTime().withDefault(currentDateAndTime)();
  // Voir StatutSynchronisation — stockée comme texte (`.name`).
  TextColumn get statutSync => text().withDefault(const Constant('enAttente'))();
  TextColumn get messageErreurSync => text().nullable()();
  IntColumn get nombreTentativesSync => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
