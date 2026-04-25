import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/app_theme.dart';
import 'core/router.dart';
import 'providers/app_provider.dart';

const String supabaseUrl = 'https://rqssumhlbrrvnuoehwts.supabase.co';
const String supabaseAnonKey =
    'sb_publishable_tQS01m_ESXy9DWNmLBrrdA_bBoDYCXB';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('th', null);

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AquaFlowApp());
}

class AquaFlowApp extends StatelessWidget {
  const AquaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Builder(
        builder: (context) {
          final provider = context.read<AppProvider>();
          return MaterialApp.router(
            title: 'AquaFlow',
            theme: AppTheme.lightTheme,
            routerConfig: createRouter(provider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
