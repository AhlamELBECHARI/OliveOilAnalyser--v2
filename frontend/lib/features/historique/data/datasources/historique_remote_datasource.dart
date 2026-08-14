import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import '../../domain/entities/demande_export_entity.dart';
import '../models/analyse_historique_model.dart';
import '../models/rapport_export_model.dart';
import '../models/resultat_historique_model.dart';
import '../models/spectre_historique_model.dart';
import '../models/statistiques_rapides_model.dart';

abstract class HistoriqueRemoteDataSource {
  Future<({List<AnalyseHistoriqueModel> analyses, bool aPageSuivante, int total})> listerAnalyses({
    required int page,
    FiltresHistorique filtres,
  });
  Future<StatistiquesRapidesModel> obtenirStatistiquesRapides();
  Future<ResultatHistoriqueModel> obtenirResultat(String resultatId);
  Future<SpectreHistoriqueModel?> obtenirSpectrePourEchantillon(String echantillonId);
  Future<RapportExportModel> declencherExport(DemandeExportEntity demande);
  Future<List<int>> telechargerRapport(String rapportId);
}

class HistoriqueRemoteDataSourceImpl implements HistoriqueRemoteDataSource {
  final Dio dio;

  const HistoriqueRemoteDataSourceImpl({required this.dio});

  String _formaterDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Future<({List<AnalyseHistoriqueModel> analyses, bool aPageSuivante, int total})> listerAnalyses({
    required int page,
    FiltresHistorique filtres = const FiltresHistorique(),
  }) async {
    try {
      final reponse = await dio.get('/analyses/historique/', queryParameters: {
        'page': page,
        if (filtres.recherche != null && filtres.recherche!.isNotEmpty) 'recherche': filtres.recherche,
        if (filtres.qualite != null) 'qualite': filtres.qualite,
        if (filtres.variete != null && filtres.variete!.isNotEmpty) 'variete': filtres.variete,
        if (filtres.region != null && filtres.region!.isNotEmpty) 'region': filtres.region,
        if (filtres.dateDebut != null) 'date_debut': _formaterDate(filtres.dateDebut!),
        if (filtres.dateFin != null) 'date_fin': _formaterDate(filtres.dateFin!),
      });
      final data = reponse.data as Map<String, dynamic>;
      final analyses = (data['results'] as List)
          .map((e) => AnalyseHistoriqueModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return (analyses: analyses, aPageSuivante: data['next'] != null, total: data['count'] as int);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<StatistiquesRapidesModel> obtenirStatistiquesRapides() async {
    try {
      final reponse = await dio.get('/analyses/statistiques-rapides/');
      return StatistiquesRapidesModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<ResultatHistoriqueModel> obtenirResultat(String resultatId) async {
    try {
      final reponse = await dio.get('/resultats/$resultatId/');
      return ResultatHistoriqueModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<SpectreHistoriqueModel?> obtenirSpectrePourEchantillon(String echantillonId) async {
    try {
      final reponse = await dio.get('/spectres/', queryParameters: {'echantillon': echantillonId});
      final resultats = (reponse.data as Map<String, dynamic>)['results'] as List;
      if (resultats.isEmpty) return null;
      return SpectreHistoriqueModel.fromJson(resultats.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<RapportExportModel> declencherExport(DemandeExportEntity demande) async {
    final filtres = demande.filtres;
    try {
      final reponse = await dio.post('/analyses/export/', data: {
        'contenu': demande.contenu.code,
        'format': demande.format,
        if (demande.identifiants != null) 'identifiants': demande.identifiants,
        if (demande.identifiants == null && filtres != null) ...{
          if (filtres.recherche != null && filtres.recherche!.isNotEmpty) 'recherche': filtres.recherche,
          if (filtres.qualite != null) 'qualite': filtres.qualite,
          if (filtres.variete != null && filtres.variete!.isNotEmpty) 'variete': filtres.variete,
          if (filtres.region != null && filtres.region!.isNotEmpty) 'region': filtres.region,
          if (filtres.dateDebut != null) 'date_debut': _formaterDate(filtres.dateDebut!),
          if (filtres.dateFin != null) 'date_fin': _formaterDate(filtres.dateFin!),
        },
      });
      return RapportExportModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<List<int>> telechargerRapport(String rapportId) async {
    try {
      final reponse = await dio.get<List<int>>(
        '/rapports/$rapportId/telecharger/',
        options: Options(responseType: ResponseType.bytes),
      );
      return reponse.data!;
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
