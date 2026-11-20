import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chunky_button.dart';
import '../../l10n/app_localizations.dart';
import '../account/account.dart';
import '../account/error_text.dart';
import '../sync/sync_controller.dart';

/// The Profile tab: sign in / create an account, or your profile and sync.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(accountProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProfile),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: account.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(EcSpace.md),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: account.signedIn
                        ? _SignedIn(state: account)
                        : const _SignInForm(),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SignInForm extends ConsumerStatefulWidget {
  const _SignInForm();

  @override
  ConsumerState<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<_SignInForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final ctrl = ref.read(accountProvider.notifier);
    try {
      if (_register) {
        await ctrl.register(_email.text, _password.text, name: _name.text);
      } else {
        await ctrl.login(_email.text, _password.text);
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final valid =
        _email.text.contains('@') &&
        _password.text.length >= (_register ? 8 : 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.lg),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_person_rounded, size: 48, color: palette.brand),
              const SizedBox(height: EcSpace.sm),
              Text(
                _register ? l10n.createAccountButton : l10n.signInTitle,
                textAlign: TextAlign.center,
                style: text.headlineSmall,
              ),
              const SizedBox(height: EcSpace.xs),
              Text(
                l10n.signInSubtitle,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: palette.inkMuted),
              ),
              const SizedBox(height: EcSpace.lg),
              TextField(
                key: const Key('email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l10n.emailLabel),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: EcSpace.sm),
              TextField(
                key: const Key('password'),
                controller: _password,
                obscureText: true,
                textDirection: TextDirection.ltr,
                autofillHints: [
                  _register
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  helperText: _register ? l10n.passwordHint : null,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => valid && !_busy ? _submit() : null,
              ),
              if (_register) ...[
                const SizedBox(height: EcSpace.sm),
                TextField(
                  key: const Key('display-name'),
                  controller: _name,
                  maxLength: 40,
                  decoration: InputDecoration(labelText: l10n.displayNameLabel),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: EcSpace.sm),
                Text(
                  _error!,
                  key: const Key('auth-error'),
                  style: text.bodyMedium?.copyWith(color: palette.hot),
                ),
              ],
              const SizedBox(height: EcSpace.md),
              ChunkyButton(
                key: const Key('submit-auth'),
                label: _register ? l10n.createAccountButton : l10n.signInButton,
                expand: true,
                onPressed: valid && !_busy ? _submit : null,
              ),
              TextButton(
                key: const Key('toggle-register'),
                onPressed: () => setState(() {
                  _register = !_register;
                  _error = null;
                }),
                child: Text(
                  _register ? l10n.switchToSignIn : l10n.switchToRegister,
                ),
              ),
              const Divider(height: EcSpace.xl),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.g_mobiledata_rounded),
                label: Text(l10n.continueWithGoogle),
              ),
              const SizedBox(height: EcSpace.sm),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.apple_rounded),
                label: Text(l10n.continueWithApple),
              ),
              const SizedBox(height: EcSpace.xs),
              Text(
                l10n.socialSoon,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: palette.inkMuted),
              ),
              const SizedBox(height: EcSpace.md),
              Text(
                l10n.guestNote,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: palette.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignedIn extends ConsumerWidget {
  const _SignedIn({required this.state});

  final AccountState state;

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.editName),
        content: TextField(
          controller: controller,
          maxLength: 40,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty) {
      try {
        await ref.read(accountProvider.notifier).rename(name);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(friendlyError(l10n, e))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final p = state.profile!;
    final sync = ref.watch(syncProvider);

    String syncLine() {
      if (sync.running) return l10n.syncing;
      if (sync.error != null) return friendlyError(l10n, sync.error!);
      if (sync.result != null) {
        return l10n.syncDone(sync.result!.pushed, sync.result!.pulled);
      }
      if (sync.lastSyncAt != null) {
        return l10n.lastSynced(
          MaterialLocalizations.of(context).formatShortDate(sync.lastSyncAt!),
        );
      }
      return l10n.neverSynced;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(EcSpace.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: palette.brand,
                  child: Text(
                    p.displayName.characters.first.toUpperCase(),
                    style: text.headlineSmall?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: EcSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.displayName,
                        key: const Key('profile-name'),
                        style: text.titleLarge,
                      ),
                      if (p.email != null)
                        Text(
                          p.email!,
                          textDirection: TextDirection.ltr,
                          style: text.bodySmall?.copyWith(
                            color: palette.inkMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.editName,
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => _rename(context, ref, p.displayName),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: EcSpace.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(EcSpace.lg),
            child: Row(
              children: [
                Icon(Icons.extension_rounded, color: palette.hot, size: 32),
                const SizedBox(width: EcSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.puzzleRatingLabel, style: text.titleMedium),
                      Text(
                        l10n.puzzlesPlayedCount(p.puzzlesPlayed),
                        style: text.bodySmall?.copyWith(
                          color: palette.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${p.puzzleRating}${p.provisional ? '?' : ''}',
                  textDirection: TextDirection.ltr,
                  style: text.headlineMedium?.copyWith(color: palette.hot),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: EcSpace.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(EcSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.sync_rounded, color: palette.brand),
                    const SizedBox(width: EcSpace.sm),
                    Text(l10n.syncTitle, style: text.titleMedium),
                  ],
                ),
                const SizedBox(height: EcSpace.sm),
                Text(
                  state.offline ? l10n.serverOffline : syncLine(),
                  key: const Key('sync-status'),
                ),
                const SizedBox(height: EcSpace.md),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ChunkyButton(
                    key: const Key('sync-now'),
                    label: l10n.syncNow,
                    icon: Icons.sync_rounded,
                    onPressed: sync.running
                        ? null
                        : () => ref.read(syncProvider.notifier).sync(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: EcSpace.lg),
        OutlinedButton.icon(
          key: const Key('sign-out'),
          onPressed: () => ref.read(accountProvider.notifier).logout(),
          icon: const Icon(Icons.logout_rounded),
          label: Text(l10n.signOut),
        ),
      ],
    );
  }
}
