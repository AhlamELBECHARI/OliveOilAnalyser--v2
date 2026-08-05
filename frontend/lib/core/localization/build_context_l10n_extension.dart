import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

/// Raccourci d'accès aux chaînes traduites : `context.l10n.maCle` plutôt que
/// `AppLocalizations.of(context)!.maCle` partout. Pas un package tiers ni une
/// Map de chaînes : une simple extension au-dessus des classes générées par
/// le SDK Flutter officiel (flutter gen-l10n).
extension BuildContextL10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
