import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/statistiques_dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<StatistiquesDashboardModel> obtenirStatistiques();

  /// Nombre total d'alertes non résolues (page_size=1 : seul le champ
  /// `count` de la pagination nous intéresse ici).
  Future<int> compterAlertesNonResolues();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  const DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<StatistiquesDashboardModel> obtenirStatistiques() async {
    try {
      final reponse = await dio.get('/dashboard/statistiques/');
      return StatistiquesDashboardModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<int> compterAlertesNonResolues() async {
    try {
      final reponse = await dio.get(
        '/alertes/',
        queryParameters: {'est_resolue': 'false', 'page_size': 1},
      );
      return (reponse.data as Map<String, dynamic>)['count'] as int;
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
