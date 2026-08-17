import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/storage/token_storage_service.dart';
import 'package:olive_iq_app/features/authentification/data/datasources/auth_local_datasource.dart';
import 'package:olive_iq_app/features/authentification/domain/entities/etat_session_locale.dart';
import 'package:olive_iq_app/features/authentification/domain/entities/raison_message_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTokenStorageService extends Mock implements TokenStorageService {}

void main() {
  late MockTokenStorageService tokenStorage;
  late AuthLocalDataSourceImpl datasource;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() async {
    tokenStorage = MockTokenStorageService();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    datasource = AuthLocalDataSourceImpl(tokenStorage: tokenStorage, preferences: preferences);
  });

  group('obtenirEtatSessionLocale', () {
    test('retourne absente quand aucun token n\'est stocké', () async {
      when(() => tokenStorage.possedeTokens()).thenAnswer((_) async => false);

      expect(await datasource.obtenirEtatSessionLocale(), EtatSessionLocale.absente);
    });

    test('retourne valide quand la dernière authentification date de moins de 30 jours', () async {
      when(() => tokenStorage.possedeTokens()).thenAnswer((_) async => true);
      when(() => tokenStorage.lireDerniereAuthentification())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(days: 10)));

      expect(await datasource.obtenirEtatSessionLocale(), EtatSessionLocale.valide);
    });

    test('reste valide pile à 30 jours (limite incluse)', () async {
      when(() => tokenStorage.possedeTokens()).thenAnswer((_) async => true);
      when(() => tokenStorage.lireDerniereAuthentification())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(days: 30)));

      expect(await datasource.obtenirEtatSessionLocale(), EtatSessionLocale.valide);
    });

    test('retourne valide et attribue un horodatage de départ quand aucun n\'existe (migration)', () async {
      when(() => tokenStorage.possedeTokens()).thenAnswer((_) async => true);
      when(() => tokenStorage.lireDerniereAuthentification()).thenAnswer((_) async => null);
      when(() => tokenStorage.enregistrerDerniereAuthentification(any())).thenAnswer((_) async {});

      expect(await datasource.obtenirEtatSessionLocale(), EtatSessionLocale.valide);
      verify(() => tokenStorage.enregistrerDerniereAuthentification(any())).called(1);
    });

    test(
        'au-delà de 30 jours, efface les tokens, retourne expireeHorsLigne et enregistre la raison '
        'du message affiché sur l\'écran de connexion', () async {
      when(() => tokenStorage.possedeTokens()).thenAnswer((_) async => true);
      when(() => tokenStorage.lireDerniereAuthentification())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(days: 31)));
      when(() => tokenStorage.supprimerTokens()).thenAnswer((_) async {});

      final etat = await datasource.obtenirEtatSessionLocale();

      expect(etat, EtatSessionLocale.expireeHorsLigne);
      verify(() => tokenStorage.supprimerTokens()).called(1);
      expect(await datasource.consommerRaisonMessageLogin(), RaisonMessageLogin.sessionExpireeHorsLigne);
    });
  });

  test('consommerRaisonMessageLogin efface la raison après lecture (un seul affichage)', () async {
    await datasource.enregistrerRaisonMessageLogin(RaisonMessageLogin.deconnexionHorsLigne);

    expect(await datasource.consommerRaisonMessageLogin(), RaisonMessageLogin.deconnexionHorsLigne);
    expect(await datasource.consommerRaisonMessageLogin(), RaisonMessageLogin.aucune);
  });
}
