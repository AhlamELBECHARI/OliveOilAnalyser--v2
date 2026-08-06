/// Commandes génériques envoyées à l'analyseur. Volontairement abstraites
/// (pas de trame binaire ici) : chaque implémentation (data/repositories/)
/// les traduit dans son propre protocole. La liste s'enrichira une fois le
/// jeu de commandes réel du fabricant documenté.
enum CommandeAnalyseur { demarrerAcquisition, annulerAcquisition }
