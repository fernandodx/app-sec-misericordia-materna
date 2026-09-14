import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/env_config.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/url_strategy/url_strategy.dart';
import 'firebase_options.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/signals/auth_signal.dart';
import 'presentation/signals/theme_signal.dart';
import 'theme.dart';
import 'util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();

  // 1. Carregar variáveis de ambiente (.env)
  await EnvConfig.init();

  // 2. Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erro na inicialização do Firebase: $e');
  }

  // 3. Inicializar Injeção de Dependências (SOLID)
  sl.setup();

  // 4. Inicializar Tema Persistido (Signals)
  await themeSignal.init();

  // 5. Inicializar Ouvinte de Autenticação (Signals)
  authSignal.init();

  runApp(const MisericordiaMaternaApp());
}

class MisericordiaMaternaApp extends StatelessWidget {
  const MisericordiaMaternaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aplicação da fonte "Basic" conforme solicitado
    final textTheme = createAppTextTheme(context);
    final materialTheme = MaterialTheme(textTheme);

    return SignalBuilder(
      builder: (context) {
        final currentThemeMode = themeSignal.themeMode.value;

        return MaterialApp.router(
          title: 'Secretaria Misericórdia Materna',
          debugShowCheckedModeBanner: false,
          themeMode: currentThemeMode,
          theme: materialTheme.light(),
          darkTheme: materialTheme.dark(),
          routerConfig: AppRouter.createRouter(),
        );
      },
    );
  }
}
