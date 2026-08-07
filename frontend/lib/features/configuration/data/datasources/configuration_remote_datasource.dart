import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/configuration_model.dart';

abstract class ConfigurationRemoteDataSource {
  Future<ConfigurationModel> obtenirConfiguration();
  Future<ConfigurationModel> modifierConfiguration(ConfigurationModel configuration);
}

class ConfigurationRemoteDataSourceImpl implements ConfigurationRemoteDataSource {
  final Dio dio;

  const ConfigurationRemoteDataSourceImpl({required this.dio});

  @override
  Future<ConfigurationModel> obtenirConfiguration() async {
    try {
      final reponse = await dio.get('/configuration/');
      return ConfigurationModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<ConfigurationModel> modifierConfiguration(ConfigurationModel configuration) async {
    try {
      final reponse = await dio.put('/configuration/', data: configuration.toJson());
      return ConfigurationModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
