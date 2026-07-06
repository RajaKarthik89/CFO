import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/theme.dart';
import 'app/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation for a mobile finance app.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style – light content on dark background.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Load environment variables (gracefully skip if .env is missing).
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('⚠️  .env file not found — running with defaults.');
  }

  runApp(const ProviderScope(child: CFOApp()));
}

class CFOApp extends ConsumerWidget {
  const CFOApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'CFO',
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────
      theme: cfoLightTheme,
      darkTheme: cfoDarkTheme,
      themeMode: mode,

      // ── Responsive text scaling ──────────────
      // Scale font sizes proportionally with screen width so text
      // stays readable on tablets and desktops without a fixed-width shell.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final scaleFactor = (mq.size.width / 390).clamp(1.0, 1.5);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(scaleFactor)),
          child: child!,
        );
      },

      // ── Router ──────────────────────────────
      routerConfig: router,
    );
  }
}
