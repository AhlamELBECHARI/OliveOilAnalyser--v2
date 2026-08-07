import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/local_storage/local_database.dart';
import 'package:olive_iq_app/core/sync/synchronisation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDio extends Mock implements Dio {}

Response<Object?> _reponseSucces(String chemin) {
  return Response(requestOptions: RequestOptions(path: chemin), statusCode: 201, data: {});
}

DioException _erreurServeur(String chemin) {
  return DioException(
    requestOptions: RequestOptions(path: chemin),
    response: Response(requestOptions: RequestOptions(path: chemin), statusCode: 500),
  );
}

void main() {
  late LocalDatabase base;
  late MockDio dio;
  late SynchronisationService service;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/echantillons/'));
  });

  setUp(() async {
    base = LocalDatabase(NativeDatabase.memory());
    dio = MockDio();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    service = SynchronisationService(
      base: base,
      dio: dio,
      preferences: preferences,
      connectivite: null,
    );
  });

  tearDown(() async {
    await base.close();
  });

  Future<void> insererEchantillon(String id, {String statutSync = 'enAttente'}) {
    return base.insererEchantillon(EchantillonsLocauxCompanion.insert(
      id: id,
      numero: 'SMP-2026-$id',
      dateAnalyse: DateTime(2026, 1, 1),
      statutSync: Value(statutSync),
    ));
  }

  Future<void> insererSpectre(String id, String echantillonId, {String statutSync = 'enAttente'}) {
    return base.insererSpectre(SpectresLocauxCompanion.insert(
      id: id,
      echantillonId: echantillonId,
      valeursXJson: '[400.0, 401.0]',
      valeursYJson: '[0.1, 0.2]',
      nombreSeries: 2,
      dateAcquisition: DateTime(2026, 1, 1),
      statutSync: Value(statutSync),
    ));
  }

  group('synchroniser — échantillons', () {
    test('marque un échantillon synchronisé après un POST réussi', () async {
      await insererEchantillon('ech-1');
      when(() => dio.post('/echantillons/', data: any(named: 'data')))
          .thenAnswer((_) async => _reponseSucces('/echantillons/'));

      await service.synchroniser();

      final echantillon = await base.obtenirEchantillon('ech-1');
      expect(echantillon!.statutSync, 'synchronise');
      expect(echantillon.messageErreurSync, isNull);
    });

    test('marque une erreur et incrémente les tentatives quand le POST échoue', () async {
      await insererEchantillon('ech-2');
      when(() => dio.post('/echantillons/', data: any(named: 'data')))
          .thenThrow(_erreurServeur('/echantillons/'));

      await service.synchroniser();

      final echantillon = await base.obtenirEchantillon('ech-2');
      expect(echantillon!.statutSync, 'erreur');
      expect(echantillon.nombreTentativesSync, 1);
      expect(echantillon.messageErreurSync, isNotNull);
    });

    test("ne retente pas un échantillon déjà marqué synchronisé", () async {
      await insererEchantillon('ech-3', statutSync: 'synchronise');

      await service.synchroniser();

      verifyNever(() => dio.post('/echantillons/', data: any(named: 'data')));
    });

    test('retente automatiquement un échantillon resté en erreur (pas abandonné après un échec)', () async {
      await insererEchantillon('ech-3b', statutSync: 'erreur');
      when(() => dio.post('/echantillons/', data: any(named: 'data')))
          .thenAnswer((_) async => _reponseSucces('/echantillons/'));

      await service.synchroniser();

      final echantillon = await base.obtenirEchantillon('ech-3b');
      expect(echantillon!.statutSync, 'synchronise');
    });
  });

  group('synchroniser — spectres', () {
    test("ne pousse pas un spectre tant que son échantillon parent n'est pas synchronisé", () async {
      await insererEchantillon('ech-4');
      await insererSpectre('spec-4', 'ech-4');
      when(() => dio.post('/echantillons/', data: any(named: 'data')))
          .thenThrow(_erreurServeur('/echantillons/'));

      await service.synchroniser();

      verifyNever(() => dio.post('/spectres/', data: any(named: 'data')));
      final spectre = await base.obtenirSpectrePourEchantillon('ech-4');
      expect(spectre!.statutSync, 'enAttente');
    });

    test('pousse le spectre une fois son échantillon parent déjà synchronisé', () async {
      await insererEchantillon('ech-5', statutSync: 'synchronise');
      await insererSpectre('spec-5', 'ech-5');
      when(() => dio.post('/spectres/', data: any(named: 'data')))
          .thenAnswer((_) async => _reponseSucces('/spectres/'));

      await service.synchroniser();

      final spectre = await base.obtenirSpectrePourEchantillon('ech-5');
      expect(spectre!.statutSync, 'synchronise');
    });

    test('synchronise échantillon puis spectre dans la même passe', () async {
      await insererEchantillon('ech-6');
      await insererSpectre('spec-6', 'ech-6');
      when(() => dio.post('/echantillons/', data: any(named: 'data')))
          .thenAnswer((_) async => _reponseSucces('/echantillons/'));
      when(() => dio.post('/spectres/', data: any(named: 'data')))
          .thenAnswer((_) async => _reponseSucces('/spectres/'));

      await service.synchroniser();

      expect((await base.obtenirEchantillon('ech-6'))!.statutSync, 'synchronise');
      expect((await base.obtenirSpectrePourEchantillon('ech-6'))!.statutSync, 'synchronise');
    });
  });

  test('flusElementsEnAttente reflète le nombre d\'éléments encore en attente après synchronisation', () async {
    await insererEchantillon('ech-7');
    await insererEchantillon('ech-8');
    when(() => dio.post('/echantillons/', data: any(named: 'data')))
        .thenAnswer((invocation) async {
      final data = invocation.namedArguments[#data] as Map;
      return data['id'] == 'ech-7' ? _reponseSucces('/echantillons/') : throw _erreurServeur('/echantillons/');
    });

    final valeurs = <int>[];
    final abonnement = service.flusElementsEnAttente.listen(valeurs.add);

    await service.synchroniser();
    await Future<void>.delayed(Duration.zero);
    await abonnement.cancel();

    expect(valeurs.last, 1);
  });

  test('synchroniser() est un no-op quand estActivee est faux', () async {
    await insererEchantillon('ech-9');
    await service.definirActivee(false);

    await service.synchroniser();

    verifyNever(() => dio.post('/echantillons/', data: any(named: 'data')));
    expect((await base.obtenirEchantillon('ech-9'))!.statutSync, 'enAttente');
  });

  test('derniereSynchronisation est horodatée une fois tout synchronisé, pas avant', () async {
    expect(service.derniereSynchronisation, isNull);

    await insererEchantillon('ech-10');
    when(() => dio.post('/echantillons/', data: any(named: 'data')))
        .thenAnswer((_) async => _reponseSucces('/echantillons/'));

    await service.synchroniser();

    expect(service.derniereSynchronisation, isNotNull);
  });
}
