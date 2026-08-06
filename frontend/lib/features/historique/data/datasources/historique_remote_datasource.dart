import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import '../models/analyse_historique_model.dart';
import '../models/resultat_historique_model.dart';
import '../models/statistiques_rapides_model.dart';

abstract class HistoriqueRemoteDataSource {
  Future<({List<AnalyseHistoriqueModel> analyses, bool aPageSuivante})> listerAnalyses({
    required int page,
    FiltresHistorique filtres,
  });
  Future<StatistiquesRapidesModel> obtenirStatistiquesRapides();
  Future<ResultatHistoriqueModel> obtenirResultat(String resultatId);
  Future<void> declencherExport(String format);
}

class HistoriqueRemoteDataSourceImpl implements HistoriqueRemoteDataSource {
  final Dio dio;

  const HistoriqueRemoteDataSourceImpl({required this.dio});

  String _formaterDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Future<({List<AnalyseHistoriqueModel> analyses, bool aPageSuivante})> listerAnalyses({
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
      return (analyses: analyses, aPageSuivante: data['next'] != null);
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
  Future<void> declencherExport(String format) async {
    try {
      await dio.post('/analyses/export/', data: {'format': format});
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
