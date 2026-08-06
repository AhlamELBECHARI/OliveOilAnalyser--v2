/// Statut de synchronisation d'un enregistrement écrit localement (Drift)
/// vers l'API. Stocké en base comme le `.name` de cette enum (colonne
/// texte) plutôt qu'un type Drift personnalisé, pour rester simple et
/// lisible directement dans la base pendant le développement/débogage.
enum StatutSynchronisation { enAttente, synchronise, erreur }
