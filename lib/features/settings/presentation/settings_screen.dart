import 'package:expense_iq/core/di/service_locator.dart';
import 'package:expense_iq/core/models/app_settings.dart';
import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/core/services/local_store.dart';
import 'package:expense_iq/core/services/security_service.dart';
import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: <Widget>[
            Text(
              'Settings',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _NavTile(
                    icon: Icons.account_balance_wallet,
                    title: 'Budgets',
                    onTap: () => context.go('/settings/budgets'),
                  ),
                  _NavTile(
                    icon: Icons.flag,
                    title: 'Savings goals',
                    onTap: () => context.go('/settings/savings'),
                  ),
                  _NavTile(
                    icon: Icons.document_scanner,
                    title: 'Receipt scanner',
                    onTap: () => context.go('/settings/scanner'),
                  ),
                  _NavTile(
                    icon: Icons.file_download,
                    title: 'Reports',
                    onTap: () => context.go('/settings/reports'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('Dark mode'),
                    secondary: const Icon(Icons.dark_mode),
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (enabled) => _update(
                      ref,
                      settings.copyWith(
                        themeMode: enabled ? ThemeMode.dark : ThemeMode.light,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Currency'),
                    trailing: DropdownButton<String>(
                      value: settings.currencyCode,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        DropdownMenuItem(value: 'INR', child: Text('INR')),
                        DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                      ],
                      onChanged: (value) => _update(
                        ref,
                        settings.copyWith(currencyCode: value),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    trailing: DropdownButton<String>(
                      value: settings.languageCode,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'es', child: Text('Spanish')),
                        DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                      ],
                      onChanged: (value) => _update(
                        ref,
                        settings.copyWith(languageCode: value),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Notifications'),
                    secondary: const Icon(Icons.notifications_active),
                    value: settings.notificationsEnabled,
                    onChanged: (value) => _update(
                      ref,
                      settings.copyWith(notificationsEnabled: value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('PIN lock'),
                    secondary: const Icon(Icons.pin),
                    value: settings.pinEnabled,
                    onChanged: (enabled) => _setPin(context, ref, settings, enabled),
                  ),
                  SwitchListTile(
                    title: const Text('Fingerprint authentication'),
                    secondary: const Icon(Icons.fingerprint),
                    value: settings.biometricsEnabled,
                    onChanged: (enabled) =>
                        _setBiometrics(context, ref, settings, enabled),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _NavTile(
                    icon: Icons.backup,
                    title: 'Backup',
                    onTap: () => _backup(context),
                  ),
                  _NavTile(
                    icon: Icons.restore,
                    title: 'Restore',
                    onTap: () => _restore(context, ref),
                  ),
                  _NavTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/auth');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update(WidgetRef ref, AppSettings settings) async {
    await ref.read(appSettingsProvider.notifier).update(settings);
  }

  Future<void> _setPin(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    bool enabled,
  ) async {
    if (!enabled) {
      await _update(ref, settings.copyWith(pinEnabled: false));
      return;
    }
    final controller = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'PIN'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (pin == null) {
      return;
    }
    await getIt<SecurityService>().setPin(pin);
    await _update(ref, settings.copyWith(pinEnabled: true));
  }

  Future<void> _setBiometrics(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    bool enabled,
  ) async {
    if (!enabled) {
      await _update(ref, settings.copyWith(biometricsEnabled: false));
      return;
    }
    final authenticated =
        await getIt<SecurityService>().authenticateWithBiometrics();
    if (authenticated) {
      await _update(ref, settings.copyWith(biometricsEnabled: true));
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication is unavailable.')),
      );
    }
  }

  Future<void> _backup(BuildContext context) async {
    final backup = await getIt<LocalStore>().exportBackup();
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup data'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: SelectableText(backup)),
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore backup'),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(labelText: 'Backup JSON'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (raw == null || raw.trim().isEmpty) {
      return;
    }
    await getIt<LocalStore>().restoreBackup(raw);
    ref.read(appSettingsProvider.notifier).reload();
    ref.read(financeProvider.notifier).refresh();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Backup restored.')));
    }
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
