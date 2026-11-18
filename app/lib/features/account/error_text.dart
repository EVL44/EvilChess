import '../../core/api/api_client.dart';
import '../../l10n/app_localizations.dart';

/// A sentence for the user describing [error].
String friendlyError(AppLocalizations l10n, Object error) {
  if (error is ApiException) {
    if (error.isNetwork) return l10n.serverOffline;
    return switch (error.code) {
      'email_taken' => l10n.errEmailTaken,
      'invalid_credentials' => l10n.errInvalidCredentials,
      'rate_limited' => l10n.errRateLimited,
      _ => l10n.errGeneric(error.message),
    };
  }
  return l10n.errGeneric('$error');
}
