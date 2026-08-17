import 'package:drift/drift.dart';

/// Cache de LECTURE (jamais de file d'attente ici, contrairement à
/// [EchantillonsLocaux]/[ResultatsLocaux]) : une ligne par analyse connue de
/// cet appareil, qu'elle vienne d'un GET /api/analyses/historique/ réussi
/// (voir HistoriqueRepositoryImpl) ou d'un résultat créé hors ligne sur cet
/// appareil (voir NouvelleAnalyseRepositoryImpl). Alimente le calcul local
/// du tableau de bord et de l'aperçu Historique quand le réseau est absent
/// (voir statistiques_locales_service.dart) — jamais la file de
/// synchronisation, qui reste [ResultatsLocaux].
@DataClassName('AnalyseCacheData')
class AnalysesCache extends Table {
  TextColumn get id => text()();
  TextColumn get numeroEchantillon => text().withDefault(const Constant(''))();
  TextColumn get producteurEchantillon => text().withDefault(const Constant(''))();
  TextColumn get varieteEchantillon => text().withDefault(const Constant(''))();
  TextColumn get regionEchantillon => text().withDefault(const Constant(''))();
  TextColumn get origineEchantillon => text().withDefault(const Constant(''))();
  RealColumn get acidite => real()();
  RealColumn get indicePeroxyde => real().nullable()();
  DateTimeColumn get dateCalcul => dateTime()();
  BoolColumn get conforme => boolean().withDefault(const Constant(true))();
  // Code stable 'evoo'/'voo'/'lampante' — voir core/domain/classification_qualite.dart.
  TextColumn get categorie => text()();
  IntColumn get dureeAnalyseSecondes => integer().nullable()();
  IntColumn get auteurId => integer().withDefault(const Constant(0))();
  TextColumn get auteurNom => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
