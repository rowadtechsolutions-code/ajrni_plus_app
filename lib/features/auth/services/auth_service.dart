import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/enums/enums.dart';
import '../../../core/services/cache/app_preferences.dart';
import '../../offices/models/office_model.dart';
import '../../offices/services/office_service.dart';
import '../models/account_session.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class RegistrationData {
  final AccountType type;
  final String name;
  final String email;
  final String phoneNumber;
  final String country;
  final String city;
  final String password;
  final String commercialRegistrationNumber;

  const RegistrationData({
    required this.type,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.country,
    required this.city,
    required this.password,
    this.commercialRegistrationNumber = '',
  });
}

class RegistrationResult {
  final AccountSession? session;
  final bool needsEmailConfirmation;

  const RegistrationResult({this.session, this.needsEmailConfirmation = false});
}

class AuthService {
  final SupabaseClient _client;
  final UserService _users;
  final OfficeService _offices;

  AuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      _users = UserService(client: client),
      _offices = OfficeService(client: client);

  Future<RegistrationResult> register(RegistrationData data) async {
    final email = data.email.trim().toLowerCase();
    final metadata = <String, dynamic>{
      'account_type': data.type.name,
      'full_name': data.type == AccountType.user ? data.name.trim() : null,
      'office_name': data.type == AccountType.office ? data.name.trim() : null,
      'phone_number': data.phoneNumber.trim(),
      'country': data.country,
      'city': data.city,
      'commercial_registration_number': data.commercialRegistrationNumber
          .trim(),
    }..removeWhere((_, value) => value == null || value == '');

    final response = await _client.auth.signUp(
      email: email,
      password: data.password,
      data: metadata,
    );
    final authUser = response.user;
    if (authUser == null) {
      throw const AuthException('تعذر إنشاء الحساب، حاول مرة أخرى.');
    }

    AccountSession fallbackSession;
    if (data.type == AccountType.office) {
      final office = OfficeModel(
        id: authUser.id,
        officeName: data.name,
        email: email,
        phoneNumber: data.phoneNumber,
        country: data.country,
        city: data.city,
        commercialRegistrationNumber: data.commercialRegistrationNumber,
      );
      fallbackSession = AccountSession.office(office);
    } else {
      final user = UserModel(
        id: authUser.id,
        fullName: data.name,
        email: email,
        phoneNumber: data.phoneNumber,
        country: data.country,
        city: data.city,
      );
      fallbackSession = AccountSession.user(user);
    }

    if (response.session == null) {
      return const RegistrationResult(needsEmailConfirmation: true);
    }

    // The database trigger normally creates the profile with the Auth user.
    // Avoid a redundant upsert because it can fail under RLS even though the
    // registration itself succeeded.
    var session = await loadAccount(authUser.id);
    if (session == null) {
      if (fallbackSession.office != null) {
        await _offices.upsertOffice(fallbackSession.office!);
      } else {
        await _users.upsertUser(fallbackSession.user!);
      }
      session = await loadAccount(authUser.id) ?? fallbackSession;
    }

    await _cacheSession(session);
    return RegistrationResult(session: session);
  }

  Future<AccountSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final id = response.user?.id;
    if (id == null) throw const AuthException('بيانات الدخول غير صحيحة.');
    final account = await loadAccount(id);
    if (account == null) {
      await _client.auth.signOut();
      throw const AuthException(
        'الحساب موجود في المصادقة لكن ملفه الشخصي غير مكتمل.',
      );
    }
    await _cacheSession(account);
    return account;
  }

  Future<AccountSession?> restoreSession() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final account = await loadAccount(user.id);
    if (account != null) await _cacheSession(account);
    return account;
  }

  Future<AccountSession?> loadAccount(String id) async {
    final user = await _users.getUserById(id);
    if (user != null) return AccountSession.user(user);
    final office = await _offices.getOfficeById(id);
    if (office != null) return AccountSession.office(office);
    return null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await AppPreferences().removeSession();
  }

  Future<bool> sendPasswordReset(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final isRegistered = await _client.rpc(
      'is_email_registered',
      params: {'email_value': normalizedEmail},
    );
    if (isRegistered != true) return false;

    final passwordResetClient = SupabaseClient(
      ApiConstants.baseUrl,
      ApiConstants.apiKey,
      authOptions: const AuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: false,
      ),
    );
    try {
      await passwordResetClient.auth.resetPasswordForEmail(
        normalizedEmail,
        redirectTo: ApiConstants.passwordResetRedirectUrl,
      );
    } finally {
      await passwordResetClient.dispose();
    }
    return true;
  }

  Future<void> deleteCurrentAccount() async {
    try {
      final deleted = await _client.rpc('delete_user_account');
      if (deleted != true) {
        throw const AuthException('account deletion failed');
      }
    } on PostgrestException catch (error) {
      // Compatibility with databases that still have the previous RPC name.
      if (error.code == 'PGRST202' ||
          error.message.toLowerCase().contains('could not find the function')) {
        await _client.rpc('delete_current_user');
      } else {
        rethrow;
      }
    }
    await _client.auth.signOut(scope: SignOutScope.local);
    await AppPreferences().removeSession();
  }

  Future<void> _cacheSession(AccountSession session) async {
    await AppPreferences().setter(CacheKeys.guestMode, false);
    await AppPreferences().setter(CacheKeys.loggedIn, true);
    await AppPreferences().setter(CacheKeys.id, session.id);
    await AppPreferences().setter(CacheKeys.email, session.email);
    await AppPreferences().setter(CacheKeys.name, session.displayName);
    await AppPreferences().setter(CacheKeys.accountType, session.type.name);
  }
}
