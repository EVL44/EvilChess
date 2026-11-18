import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/account.dart';
import '../../account/server_imports.dart';
import '../../sync/sync_controller.dart';
import '../data/game_repository.dart';
import '../data/import_service.dart';
import '../data/online_import.dart';
import '../domain/game_record.dart';
import '../domain/pgn_import.dart';

/// Bottom sheet with every way to get games in: paste, file, linked accounts.
Future<void> showImportSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const ImportSheet(),
    );

class ImportSheet extends ConsumerStatefulWidget {
  const ImportSheet({super.key});

  @override
  ConsumerState<ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends ConsumerState<ImportSheet> {
  final _pgn = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _pgn.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _importText(String text) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final r = await ref.read(importServiceProvider).importPgn(text);
      if (!mounted) return;
      _toast(l10n.importResult(r.added));
      Navigator.of(context).pop();
    } on PgnImportException {
      _toast(l10n.pgnNoGames);
    } catch (e) {
      _toast(l10n.importFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pgn', 'txt'],
    );
    if (files.isEmpty) return;
    final bytes = await files.first.readAsBytes();
    await _importText(utf8.decode(bytes, allowMalformed: true));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: EcSpace.lg,
        right: EcSpace.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + EcSpace.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.importGames, style: text.headlineSmall),
            const SizedBox(height: EcSpace.lg),
            Text(l10n.importOnlineTab, style: text.titleMedium),
            const SizedBox(height: EcSpace.sm),
            const AccountTile(provider: GameSource.lichess),
            const SizedBox(height: EcSpace.sm),
            const AccountTile(provider: GameSource.chesscom),
            const SizedBox(height: EcSpace.lg),
            Text(l10n.importPasteTab, style: text.titleMedium),
            const SizedBox(height: EcSpace.sm),
            TextField(
              key: const Key('pgn-input'),
              controller: _pgn,
              minLines: 4,
              maxLines: 10,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                hintText: l10n.importPasteHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(EcRadii.md),
                ),
              ),
            ),
            const SizedBox(height: EcSpace.sm),
            Wrap(
              spacing: EcSpace.sm,
              runSpacing: EcSpace.sm,
              children: [
                ChunkyButton(
                  key: const Key('pgn-import'),
                  label: l10n.importButton,
                  icon: Icons.download_rounded,
                  onPressed: _busy || _pgn.text.trim().isEmpty
                      ? null
                      : () => _importText(_pgn.text),
                ),
                ChunkyButton(
                  label: l10n.importFromFile,
                  icon: Icons.folder_open_rounded,
                  color: context.palette.sun,
                  onPressed: _busy ? null : _pickFile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pgn.addListener(() => setState(() {}));
  }
}

/// Link / sync / unlink one online account.
class AccountTile extends ConsumerStatefulWidget {
  const AccountTile({super.key, required this.provider});

  final GameSource provider;

  @override
  ConsumerState<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends ConsumerState<AccountTile> {
  final _name = TextEditingController();
  int? _progress;

  /// The running import happens on the server (signed in).
  bool _onServer = false;

  String get _label =>
      widget.provider == GameSource.lichess ? 'Lichess' : 'Chess.com';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _progress = 0);
    if (ref.read(accountProvider).signedIn && await _syncOnServer(messenger)) {
      return;
    }
    try {
      final r = await ref
          .read(importServiceProvider)
          .sync(
            widget.provider,
            onProgress: (n) {
              if (mounted) setState(() => _progress = n);
            },
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importResult(r.added))),
      );
    } on ImportException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importFailed(e.message))),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed('$e'))));
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  /// Imports through the server so every device gets the games. Returns
  /// false (to fall back to importing here) when the server is unreachable.
  Future<bool> _syncOnServer(ScaffoldMessengerState messenger) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(gameRepositoryProvider);
    final imports = ref.read(serverImportsProvider);
    setState(() => _onServer = true);
    try {
      final account = await repo.account(widget.provider);
      if (account == null) return true;
      await imports.link(widget.provider, account.username);
      final n = await imports.run(
        widget.provider,
        onProgress: (n) {
          if (mounted) setState(() => _progress = n);
        },
      );
      await ref.read(syncProvider.notifier).sync();
      await repo.markSynced(widget.provider, null);
      messenger.showSnackBar(SnackBar(content: Text(l10n.importResult(n))));
      return true;
    } on ApiException catch (e) {
      if (e.isNetwork) return false;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importFailed(e.message))),
      );
      return true;
    } finally {
      if (mounted) {
        setState(() {
          _onServer = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _unlink() async {
    await ref.read(gameRepositoryProvider).unlinkAccount(widget.provider);
    if (ref.read(accountProvider).signedIn) {
      try {
        await ref.read(serverImportsProvider).unlink(widget.provider);
      } on ApiException {
        // Offline: unlinked here; the server keeps its copy for now.
      }
    }
  }

  Future<void> _link() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    await ref.read(gameRepositoryProvider).linkAccount(widget.provider, name);
    await _sync();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final accounts = ref.watch(linkedAccountsProvider).value ?? const [];
    final account = accounts
        .where((a) => a.provider == widget.provider)
        .firstOrNull;
    final busy = _progress != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: account == null
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: Key('username-${widget.provider.name}'),
                      controller: _name,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: '$_label · ${l10n.usernameLabel}',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _link(),
                    ),
                  ),
                  const SizedBox(width: EcSpace.sm),
                  FilledButton(
                    onPressed: busy ? null : _link,
                    child: Text(l10n.linkAndSync),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_label · ${account.username}',
                          style: text.titleSmall,
                        ),
                        Text(
                          busy
                              ? (_onServer
                                    ? l10n.importingOnServer(_progress!)
                                    : l10n.importingCount(_progress!))
                              : account.lastSyncedAt == null
                              ? l10n.neverSynced
                              : l10n.lastSynced(
                                  MaterialLocalizations.of(context)
                                      .formatShortDate(account.lastSyncedAt!),
                                ),
                          style: text.bodySmall?.copyWith(
                            color: context.palette.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (busy)
                    const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  else ...[
                    FilledButton.tonal(
                      onPressed: _sync,
                      child: Text(l10n.syncNow),
                    ),
                    IconButton(
                      tooltip: l10n.unlinkAccount,
                      icon: const Icon(Icons.link_off_rounded),
                      onPressed: _unlink,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

final linkedAccountsProvider = StreamProvider<List<LinkedAccount>>(
  (ref) => ref.watch(gameRepositoryProvider).watchAccounts(),
);
