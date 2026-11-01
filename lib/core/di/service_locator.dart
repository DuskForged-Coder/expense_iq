import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expense_iq/core/services/auth_service.dart';
import 'package:expense_iq/core/services/finance_repository.dart';
import 'package:expense_iq/core/services/local_store.dart';
import 'package:expense_iq/core/services/notification_service.dart';
import 'package:expense_iq/core/services/receipt_scanner_service.dart';
import 'package:expense_iq/core/services/report_service.dart';
import 'package:expense_iq/core/services/security_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final localStore = await LocalStore.create(preferences, secureStorage);
  getIt
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerSingleton<FlutterSecureStorage>(secureStorage)
    ..registerSingleton<LocalStore>(localStore)
    ..registerLazySingleton<AuthService>(() => AuthService(getIt()))
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<FinanceRepository>(
      () => FinanceRepository(getIt(), getIt()),
    )
    ..registerLazySingleton<ReceiptScannerService>(ReceiptScannerService.new)
    ..registerLazySingleton<ReportService>(ReportService.new)
    ..registerLazySingleton<LocalAuthentication>(LocalAuthentication.new)
    ..registerLazySingleton<SecurityService>(() => SecurityService(getIt(), getIt()))
    ..registerLazySingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin.new,
    )
    ..registerLazySingleton<NotificationService>(
      () => NotificationService(getIt()),
    );

  await getIt<NotificationService>().initialize();
}
