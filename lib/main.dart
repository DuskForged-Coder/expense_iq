import 'package:expense_iq/core/di/service_locator.dart';
import 'package:expense_iq/core/routing/app_router.dart';
import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } on Object {
    // The app remains fully usable offline until Firebase is configured.
  }
  await configureDependencies();
  runApp(const ProviderScope(child: ExpenseIqApp()));
}

class ExpenseIqApp extends ConsumerWidget {
  const ExpenseIqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp.router(
      title: 'ExpenseIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: createRouter(),
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('es'),
        Locale('hi'),
      ],
    );
  }
}
