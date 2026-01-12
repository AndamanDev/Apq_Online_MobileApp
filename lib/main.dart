import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Class/ClassObject.dart';
import 'Pages/InitPage.dart';
import 'Provider/ProviderAuth.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await _requestPermissions();
  final authProvider = ProviderAuth();
  await authProvider.loadFromDb(); 
  runApp(
     MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
      ],
      child:  DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()),
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
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

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

      home: const InitPage(),
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
