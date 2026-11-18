import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api/api_client.dart';
import '../games/data/import_service.dart' show httpClientProvider;

/// The signed-in user's profile from `GET /api/v1/me`.
@immutable
class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    required this.puzzleRating,
    required this.provisional,
    required this.puzzlesPlayed,
    this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    id: j['id'] as String,
    email: j['email'] as String?,
    displayName: j['displayName'] as String,
    puzzleRating: (j['puzzleRating'] as num).toInt(),
    provisional: j['provisional'] as bool? ?? true,
    puzzlesPlayed: (j['puzzlesPlayed'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String? email;
  final String displayName;
  final int puzzleRating;
  final bool provisional;
  final int puzzlesPlayed;
}

/// Signed out, signed in (with a profile), or not known yet.
@immutable
class AccountState {
  const AccountState({
    this.loading = false,
    this.profile,
    this.offline = false,
  });

  static const unknown = AccountState(loading: true);
  static const signedOut = AccountState();

  final bool loading;
  final Profile? profile;

  /// Signed in, but the server could not be reached to refresh the profile.
  final bool offline;

  bool get signedIn => profile != null;
}

/// Refresh tokens live in the platform keychain / keystore (web: encrypted
/// local storage).
class SecureTokenStore implements TokenStore {
  static const _access = 'evilchess.accessToken';
  static const _refresh = 'evilchess.refreshToken';
  final _storage = const FlutterSecureStorage();

  @override
  Future<Tokens?> read() async {
    try {
      final refresh = await _storage.read(key: _refresh);
      if (refresh == null) return null;
      return Tokens(await _storage.read(key: _access) ?? '', refresh);
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> write(Tokens t) async {
    await _storage.write(key: _access, value: t.accessToken);
    await _storage.write(key: _refresh, value: t.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }
}

final apiUrlProvider = Provider<String>((ref) => defaultApiUrl());

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    baseUrl: ref.watch(apiUrlProvider),
    httpClient: ref.watch(httpClientProvider),
    store: ref.watch(tokenStoreProvider),
  );
  return client;
});

/// Sign-in state and actions.
class AccountController extends Notifier<AccountState> {
  ApiClient get _api => ref.read(apiClientProvider);

  @override
  AccountState build() {
    _api.onSignedOut = () => state = AccountState.signedOut;
    unawaited(_restore());
    return AccountState.unknown;
  }

  Future<void> _restore() async {
    if (!await _api.hasSession) {
      state = AccountState.signedOut;
      return;
    }
    await refreshProfile();
  }

  /// Reloads the profile (e.g. after a rated puzzle).
  Future<void> refreshProfile() async {
    try {
      final json = await _api.get('/api/v1/me') as Map<String, dynamic>;
      state = AccountState(profile: Profile.fromJson(json));
    } on ApiException catch (e) {
      if (e.isNetwork && await _api.hasSession) {
        // Keep the session; show what we had.
        state = AccountState(profile: state.profile, offline: true);
      } else if (e.isUnauthorized) {
        await _api.clearSession();
        state = AccountState.signedOut;
      } else {
        state = AccountState(profile: state.profile);
      }
    }
  }

  Future<void> register(String email, String password, {String? name}) =>
      _signIn('/api/v1/auth/register', {
        'email': email,
        'password': password,
        if (name != null && name.trim().isNotEmpty) 'displayName': name.trim(),
      });

  Future<void> login(String email, String password) =>
      _signIn('/api/v1/auth/login', {'email': email, 'password': password});

  Future<void> _signIn(String path, Map<String, Object> body) async {
    final json = await _api.send(
      'POST',
      path,
      body: body,
      auth: false,
    ) as Map<String, dynamic>;
    await _api.setTokens(Tokens.fromJson(json));
    await refreshProfile();
  }

  Future<void> logout() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    if (tokens != null) {
      try {
        await _api.send(
          'POST',
          '/api/v1/auth/logout',
          body: {'refreshToken': tokens.refreshToken},
          auth: false,
        );
      } on ApiException {
        // Offline: the token just expires on its own.
      }
    }
    await _api.clearSession();
    state = AccountState.signedOut;
  }

  Future<void> rename(String name) async {
    final json = await _api.patch('/api/v1/me', {
      'displayName': name.trim(),
    }) as Map<String, dynamic>;
    state = AccountState(profile: Profile.fromJson(json));
  }
}

final accountProvider = NotifierProvider<AccountController, AccountState>(
  AccountController.new,
);
