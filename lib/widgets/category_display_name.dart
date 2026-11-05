import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Name to show for a category.
///
/// The built-in categories are stored under fixed English names because code looks them up by
/// name (e.g. `category.name == 'Favorites'`). Translate those at display time only; categories
/// the user named themselves are shown as typed.
String categoryDisplayName(BuildContext context, String storedName) {
  final l = AppLocalizations.of(context);
  if (l == null) return storedName;
  switch (storedName) {
    case 'Favorites':
      return l.favoriteApps;
    case 'All Apps':
    case 'Applications':
      return l.allApplications;
    case 'TV Applications':
    case 'TV Apps':
      return l.tvApplications;
    case 'Non-TV Applications':
    case 'Non-TV Apps':
      return l.nonTvApplications;
    default:
      return storedName;
  }
}
