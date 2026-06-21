import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/app_localizations.dart';

class AuthErrorMapper {
  AuthErrorMapper._();

  static String message(Object error, AppLocalizations l) {
    final value = error is AuthException
        ? error.message.toLowerCase()
        : error.toString().toLowerCase();

    if (value.contains('invalid login credentials') ||
        value.contains('invalid credentials')) {
      return l.invalidCredentials;
    }
    if (value.contains('email not confirmed')) return l.emailNotConfirmed;
    if (value.contains('user already registered') ||
        value.contains('already been registered') ||
        value.contains('already exists')) {
      return l.emailAlreadyRegistered;
    }
    if (value.contains('password should be') ||
        value.contains('weak password')) {
      return l.weakPassword;
    }
    if (value.contains('invalid api key')) {
      return l.serviceConfigurationError;
    }
    if (value.contains('socket') ||
        value.contains('network') ||
        value.contains('connection')) {
      return l.networkError;
    }
    if (value.contains('rate limit') || value.contains('too many requests')) {
      return l.tooManyAttempts;
    }
    if (value.contains('database error saving new user') ||
        value.contains('new row violates row-level security') ||
        value.contains('row-level security policy') ||
        value.contains('profile') && value.contains('not found')) {
      return l.registrationServiceError;
    }
    if (value.contains('signup is disabled') ||
        value.contains('signups not allowed')) {
      return l.registrationDisabled;
    }
    if (value.contains('delete_user_account') ||
        value.contains('delete_current_user') ||
        value.contains('account deletion failed') ||
        value.contains('could not find the function')) {
      return l.accountDeletionFailed;
    }
    return l.unexpectedError;
  }
}
