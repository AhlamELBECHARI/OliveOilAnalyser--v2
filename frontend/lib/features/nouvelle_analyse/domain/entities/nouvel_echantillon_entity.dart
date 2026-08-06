import 'package:equatable/equatable.dart';

/// Échantillon saisi sur l'écran Nouvelle Analyse, avant tout envoi réseau.
/// [id] est un UUID généré côté mobile (voir NouvelleAnalyseRepositoryImpl) :
/// le même identifiant sert de clé locale (Drift) et de clé serveur une
/// fois synchronisé, pour que la synchronisation hors ligne soit idempotente
/// (voir EchantillonSerializer.id côté backend).
class NouvelEchantillonEntity extends Equatable {
  final String id;
  final String numero;
  final DateTime dateAnalyse;
  final String producteur;
  final String variete;
  final String region;
  final DateTime? dateRecolte;
  final double? latitude;
  final double? longitude;
  final String origine;
  final String notes;

  const NouvelEchantillonEntity({
    required this.id,
    required this.numero,
    required this.dateAnalyse,
    this.producteur = '',
    this.variete = '',
    this.region = '',
    this.dateRecolte,
    this.latitude,
    this.longitude,
    this.origine = '',
    this.notes = '',
  });

  bool get aCoordonneesGps => latitude != null && longitude != null;

  NouvelEchantillonEntity copierAvec({
    String? numero,
    String? producteur,
    String? variete,
    String? region,
    DateTime? dateRecolte,
    double? latitude,
    double? longitude,
  }) {
    return NouvelEchantillonEntity(
      id: id,
      numero: numero ?? this.numero,
      dateAnalyse: dateAnalyse,
      producteur: producteur ?? this.producteur,
      variete: variete ?? this.variete,
      region: region ?? this.region,
      dateRecolte: dateRecolte ?? this.dateRecolte,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      origine: origine,
      notes: notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        numero,
        dateAnalyse,
        producteur,
        variete,
        region,
        dateRecolte,
        latitude,
        longitude,
        origine,
        notes,
      ];
}
