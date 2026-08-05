import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/alerte_model.dart';

abstract class AlertesRemoteDataSource {
  Future<List<AlerteModel>> listerAlertes();
}

class AlertesRemoteDataSourceImpl implements AlertesRemoteDataSource {
  final Dio dio;

  const AlertesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AlerteModel>> listerAlertes() async {
    try {
      final reponse = await dio.get('/alertes/');
      final resultats = (reponse.data as Map<String, dynamic>)['results'] as List;
      return resultats.map((e) => AlerteModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
