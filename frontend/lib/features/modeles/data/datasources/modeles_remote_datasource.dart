import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/modele_model.dart';

abstract class ModelesRemoteDataSource {
  Future<List<ModeleModel>> listerModeles();
}

class ModelesRemoteDataSourceImpl implements ModelesRemoteDataSource {
  final Dio dio;

  const ModelesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ModeleModel>> listerModeles() async {
    try {
      final reponse = await dio.get('/modeles/');
      final resultats = (reponse.data as Map<String, dynamic>)['results'] as List;
      return resultats.map((e) => ModeleModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
