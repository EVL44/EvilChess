import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/settings/app_settings.dart';
import '../account/account.dart';
import 'sync_service.dart';

@immutable
class SyncState {
  const SyncState({
    this.running = false,
    this.lastSyncAt,
    this.result,
    this.error,
  });

  final bool running;
  final DateTime? lastSyncAt;
  final SyncResult? result;

  /// The last failure (an [ApiException] or other error).
  final Object? error;
}

/// Runs sync for the signed-in account and remembers how it went.
class SyncController extends Notifier<SyncState> {
  @override
  SyncState build() =>
      SyncState(lastSyncAt: ref.read(syncServiceProvider).lastSyncAt);

  Future<void> sync() async {
    final profile = ref.read(accountProvider).profile;
    if (profile == null || state.running) return;
    state = SyncState(running: true, lastSyncAt: state.lastSyncAt);
    try {
      final result = await ref.read(syncServiceProvider).sync(profile.id);
      // Settings may have arrived from another device.
      ref.read(appSettingsProvider.notifier).reload();
      state = SyncState(lastSyncAt: DateTime.now(), result: result);
    } on ApiException catch (e) {
      state = SyncState(lastSyncAt: state.lastSyncAt, error: e);
    } catch (e) {
      state = SyncState(lastSyncAt: state.lastSyncAt, error: e);
    }
  }
}

final syncProvider = NotifierProvider<SyncController, SyncState>(
  SyncController.new,
);
