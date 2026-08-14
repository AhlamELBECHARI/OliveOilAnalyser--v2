import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/gestion_donnees_model.dart';
import '../models/journal_audit_model.dart';
import '../models/supervision_model.dart';

abstract class AdministrationRemoteDataSource {
  Future<SupervisionModel> obtenirSupervision();
  Future<void> resoudreAlerte(int alerteId);
  Future<({List<JournalAuditModel> entrees, bool aPageSuivante, int total})> listerJournalAudit({
    required int page,
  });
  Future<StatistiquesOccupationModel> obtenirStatistiquesOccupation();
  Future<PurgeApercuModel> previsualiserPurge(DateTime dateLimite);
  Future<void> executerPurge(DateTime dateLimite);
}

class AdministrationRemoteDataSourceImpl implements AdministrationRemoteDataSource {
  final Dio dio;

  const AdministrationRemoteDataSourceImpl({required this.dio});

  String _formaterDate(DateTime date) => date.toIso8601String().split('T').first;

  @override
  Future<SupervisionModel> obtenirSupervision() async {
    try {
      final reponse = await dio.get('/admin/supervision/');
      return SupervisionModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<void> resoudreAlerte(int alerteId) async {
    try {
      await dio.post('/alertes/$alerteId/resoudre/');
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<({List<JournalAuditModel> entrees, bool aPageSuivante, int total})> listerJournalAudit({
    required int page,
  }) async {
    try {
      final reponse = await dio.get('/admin/journal-audit/', queryParameters: {'page': page});
      final data = reponse.data as Map<String, dynamic>;
      final entrees = (data['results'] as List)
          .map((e) => JournalAuditModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return (entrees: entrees, aPageSuivante: data['next'] != null, total: data['count'] as int);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<StatistiquesOccupationModel> obtenirStatistiquesOccupation() async {
    try {
      final reponse = await dio.get('/admin/donnees/statistiques/');
      return StatistiquesOccupationModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<PurgeApercuModel> previsualiserPurge(DateTime dateLimite) async {
    try {
      final reponse = await dio.post(
        '/admin/donnees/purge/apercu/',
        data: {'date_limite': _formaterDate(dateLimite)},
      );
      return PurgeApercuModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<void> executerPurge(DateTime dateLimite) async {
    try {
      await dio.post('/admin/donnees/purge/', data: {'date_limite': _formaterDate(dateLimite)});
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
