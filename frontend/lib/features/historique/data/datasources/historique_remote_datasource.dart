import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/resultat_historique_model.dart';

abstract class HistoriqueRemoteDataSource {
  Future<List<ResultatHistoriqueModel>> listerHistorique();
  Future<ResultatHistoriqueModel> obtenirResultat(String resultatId);
}

class HistoriqueRemoteDataSourceImpl implements HistoriqueRemoteDataSource {
  final Dio dio;

  const HistoriqueRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ResultatHistoriqueModel>> listerHistorique() async {
    try {
      final reponse = await dio.get('/resultats/');
      final resultats = (reponse.data as Map<String, dynamic>)['results'] as List;
      return resultats
          .map((e) => ResultatHistoriqueModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
}
