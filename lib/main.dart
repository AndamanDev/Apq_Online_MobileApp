import 'package:apq_m1/Provider/ProviderLanguage.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'Class/ClassObject.dart';
import 'Class/ClassPrinterService.dart';
import 'Class/Global.dart';
import 'Pages/InitPage.dart';
import 'Provider/ProviderAuth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/app_localizations_delegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _requestPermissions();
  await Classprinterservice.instance.init();

  final authProvider = ProviderAuth();
  await authProvider.loadFromDb();

  // runApp(
  //   ToastificationWrapper(
  //     child: MultiProvider(
  //       providers: [
  //         ChangeNotifierProvider(create: (_) => authProvider),
  //       ],
  //       child: DevicePreview(
  //         enabled: !kReleaseMode,
  //         builder: (context) => const MyApp(),
  //       ),
  //     ),
  //   ),
  // );

  runApp(
    ToastificationWrapper(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ProviderAuth>.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => ProviderLanguage()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> _requestPermissions() async {
  final statuses = await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ].request();

  if (statuses[Permission.bluetooth]!.isGranted &&
      statuses[Permission.bluetoothConnect]!.isGranted &&
      statuses[Permission.bluetoothScan]!.isGranted) {
    print('All Bluetooth permissions granted');
  } else {
    print('Some Bluetooth permissions are not granted');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderLanguage>(
      builder: (context, lang, _) {
        return MaterialApp(
          locale: lang.locale,
          supportedLocales: const [Locale('th'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          useInheritedMediaQuery: true,
          // locale: DevicePreview.locale(context),
          // builder: DevicePreview.appBuilder,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.primary,
            primaryColor: AppColors.primary,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),

            textTheme: responsiveTextTheme(context),
          ),

          darkTheme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.primary,
          ),
          scaffoldMessengerKey: rootMessengerKey,
          home: const InitPage(),
        );
      },
    );
  }

  TextTheme responsiveTextTheme(BuildContext context) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: AppSize.font(context, 32),
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: AppSize.font(context, 24),
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(fontSize: AppSize.font(context, 18)),
      bodyMedium: TextStyle(fontSize: AppSize.font(context, 16)),
    );
  }
}
