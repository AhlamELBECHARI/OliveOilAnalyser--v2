import '../entities/appareil_appaire_entity.dart';
import '../entities/commande_analyseur.dart';
import '../entities/etat_connexion_analyseur_entity.dart';
import '../entities/info_appareil_analyseur_entity.dart';
import '../entities/spectre_entity.dart';

/// Abstraction du module Bluetooth pilotant l'analyseur spectroscopique.
///
/// Le protocole exact du spectromètre (jeu de commandes, format binaire,
/// appairage) n'est pas encore documenté par le fabricant : cette interface
/// ne suppose donc RIEN de ce protocole. Elle n'expose que des concepts
/// métier stables (état de connexion, commande, spectre, infos appareil),
/// pour que l'UI et le reste de l'app n'aient jamais à changer quand
/// l'implémentation Bluetooth réelle sera branchée à la place du simulateur
/// — seule la configuration get_it (core/di/injection_container.dart)
/// choisit l'implémentation, jamais un `if` dispersé dans le code.
///
/// Deux implémentations dans la couche Data :
/// - [AnalyseurBluetoothImpl] (Bluetooth Classic / SPP, connexion auto à
///   l'appareil déjà appairé, protocole isolé dans
///   data/protocole/protocole_spectrometre.dart)
/// - [AnalyseurSimuleImpl] (spectre NIR simulé, pour développer/démontrer
///   l'app avant que le matériel ne soit disponible ou documenté)
abstract class AnalyseurRepository {
  /// Flux continu de l'état de connexion (déconnecté / recherche / connecté
  /// / erreur). Stream broadcast : un nouvel abonné reçoit immédiatement
  /// l'état courant, pas seulement les changements futurs.
  Stream<EtatConnexionAnalyseurEntity> get flusEtatConnexion;

  /// Recherche l'appareil déjà appairé correspondant à la configuration et
  /// s'y connecte automatiquement, SANS afficher de liste ni demander de
  /// sélection à l'utilisateur. En cas de coupure ultérieure, chaque
  /// implémentation gère sa propre reconnexion automatique (tentatives
  /// espacées) en arrière-plan.
  Future<void> connecterAutomatiquement();

  /// Envoie une commande à l'analyseur (ex. démarrer une acquisition).
  /// Lève une exception si aucun appareil n'est connecté.
  Future<void> envoyerCommande(CommandeAnalyseur commande);

  /// Flux de réception du spectre : peut émettre plusieurs [SpectreBrutEntity]
  /// successifs pendant une acquisition (rendu progressif "temps réel"),
  /// le dernier ayant `complet: true`.
  Stream<SpectreBrutEntity> get flusSpectre;

  /// Informations de l'appareil actuellement connecté (nom, type, numéro de
  /// série, firmware, batterie), ou `null` si aucun appareil n'est connecté.
  Future<InfoAppareilAnalyseurEntity?> obtenirInfoAppareil();

  /// Libère les ressources (connexion Bluetooth, StreamControllers). À
  /// appeler quand l'écran qui pilote l'analyseur est fermé.
  Future<void> liberer();

  /// Appareils Bluetooth déjà appairés au système (écran "Configuration de
  /// l'appareil") — jamais de scan/découverte ici, seulement les appareils
  /// déjà appairés dans les réglages du téléphone.
  Future<List<AppareilAppaireEntity>> listerAppareilsAppaires();

  /// Mémorise l'appareil à utiliser pour [connecterAutomatiquement] (persisté
  /// localement, pour que la connexion automatique cible ce même appareil
  /// aux lancements suivants). `null` revient à la détection par nom par
  /// défaut du protocole.
  Future<void> definirAppareilParDefaut(String? adresse);

  /// Adresse actuellement mémorisée comme appareil par défaut, s'il y en a une.
  Future<String?> obtenirAppareilParDefaut();

  /// Tente une connexion ponctuelle à [adresse] puis la referme aussitôt,
  /// sans toucher à l'état de connexion principal — sert uniquement au
  /// bouton "Tester la connexion" de l'écran de configuration.
  Future<bool> testerConnexion(String adresse);
}
