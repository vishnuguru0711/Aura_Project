import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/tts_service.dart';
import 'services/voice_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await TtsService.instance.init();
  runApp(const SmartWalkingStickApp());
}

class SmartWalkingStickApp extends StatelessWidget {
  const SmartWalkingStickApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Walking Stick',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoiceService.instance.startListening(context);
    });
  }

  @override
  void dispose() {
    VoiceService.instance.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}

class AppTheme {
  static const Color bg       = Color(0xFF0A0C0F);
  static const Color bg2      = Color(0xFF12151A);
  static const Color bg3      = Color(0xFF1A1F27);
  static const Color card     = Color(0xFF1E242E);
  static const Color accent   = Color(0xFF00E5A0);
  static const Color accent2  = Color(0xFFFF6B35);
  static const Color danger   = Color(0xFFFF3B5C);
  static const Color blue     = Color(0xFF4FACFE);
  static const Color textPri  = Color(0xFFF0F4FF);
  static const Color textMuted= Color(0xFF8892A0);
  static const Color border   = Color(0x14FFFFFF);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accent2,
      error: danger,
      surface: card,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      foregroundColor: textPri,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: textPri,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge:  TextStyle(color: textPri,    fontSize: 16),
      bodyMedium: TextStyle(color: textPri,    fontSize: 14),
      bodySmall:  TextStyle(color: textMuted,  fontSize: 12),
    ),
  );
}
