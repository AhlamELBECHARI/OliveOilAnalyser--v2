import 'package:drift/drift.dart';

/// Cache générique clé/valeur (JSON) pour tout ce qui n'a pas besoin d'une
/// vraie table relationnelle : dernière Configuration, dernier profil,
/// dernière liste de modèles actifs, dernier nombre d'alertes... Voir
/// core/local_storage/cache_local_service.dart pour la sérialisation. Une
/// seule ligne par clé (`insertOnConflictUpdate`), jamais d'historique.
class CacheGenerique extends Table {
  TextColumn get cle => text()();
  TextColumn get valeurJson => text()();
  DateTimeColumn get dateEcriture => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {cle};
}
