import 'package:flutter/material.dart';
import '../main.dart';
import '../services/tts_service.dart';
import '../services/voice_service.dart';
import '../services/sos_service.dart';
import '../services/scan_service.dart';
import '../widgets/common_widgets.dart';
import 'detection_screen.dart';
import 'navigation_screen.dart';
import 'sos_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _pendingDestination = '';
  bool _autoScan = false;

  final List<String> _tabLabels = ['Home', 'Scan', 'Navigate', 'SOS'];
  final List<IconData> _tabIcons = [
    Icons.home_outlined,
    Icons.remove_red_eye_outlined,
    Icons.navigation_outlined,
    Icons.warning_amber_rounded,
  ];

  @override
  void initState() {
    super.initState();

    VoiceService.instance.onTabSwitch = (i) {
      if (mounted) setState(() => _tab = i);
    };

    VoiceService.instance.onNavigate = (dest) {
      if (mounted) setState(() {
        _pendingDestination = dest;
        _tab = 2;
      });
    };

    VoiceService.instance.onSos = () {
      if (mounted) setState(() => _tab = 3);
      SosService.instance.sendSos();
    };

    VoiceService.instance.onScan = () {
      if (mounted) setState(() {
        _autoScan = true;
        _tab = 1;
      });
    };
  }

  Widget _buildBody() {
    switch (_tab) {
      case 0: return _buildHome();
      case 1: return const DetectionScreen();
      case 2: return NavigationScreen(initialDestination: _pendingDestination);
      case 3: return const SosScreen();
      default: return _buildHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg2,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: SafeArea(
          child: Row(
            children: List.generate(4, (i) {
              final selected = _tab == i;
              Color color = i == 3
                  ? AppTheme.danger
                  : selected ? AppTheme.accent : AppTheme.textMuted;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _tab = i;
                      if (i != 1) _autoScan = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_tabIcons[i], color: color, size: 22),
                        const SizedBox(height: 3),
                        Text(_tabLabels[i],
                            style: TextStyle(fontSize: 10, color: color,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    final isListening = VoiceService.instance.isListening;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart Walking Stick',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                            color: AppTheme.textPri)),
                    SizedBox(height: 2),
                    Text('Voice-Driven Assistive System',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border)),
                    child: const Icon(Icons.settings_outlined,
                        color: AppTheme.textMuted, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Voice Orb
            Center(
              child: Column(
                children: [
                  VoiceOrb(
                    active: isListening,
                    onTap: () => TtsService.instance.speak(
                        'Say navigate to a place, scan, or help for S O S.'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isListening ? '● Listening...' : 'Tap or Say a Command',
                    style: TextStyle(fontSize: 12,
                        color: isListening ? AppTheme.accent : AppTheme.textMuted,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  const Text('"Navigate to hospital" · "Scan" · "Help"',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ESP32-CAM Status
            DarkCard(
              child: Row(
                children: [
                  PulsingDot(color: AppTheme.accent, size: 8),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ESP32-CAM Stream',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('Stream connected · Object scan ready',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  StatusBadge(label: 'LIVE', color: AppTheme.accent),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Feature Cards
            const SectionLabel('Features'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _featCard(Icons.remove_red_eye_outlined, AppTheme.accent,
                    'Object Scan', 'Detect · TTS', 1),
                _featCard(Icons.navigation_outlined, AppTheme.blue,
                    'Navigate', 'Google Maps', 2),
                _featCard(Icons.mic_outlined, AppTheme.accent2,
                    'Voice AI', 'Always On', 0),
                _featCard(Icons.warning_amber_rounded, AppTheme.danger,
                    'SOS Alert', 'SMS + Location', 3),
              ],
            ),

            const SizedBox(height: 16),

            // Commands reference
            const SectionLabel('Voice Commands'),
            DarkCard(
              child: Column(
                children: [
                  _cmdRow(Icons.navigation_outlined, AppTheme.blue,
                      '"Navigate to hospital"', 'Opens Google Maps turn-by-turn'),
                  const Divider(color: AppTheme.border, height: 20),
                  _cmdRow(Icons.remove_red_eye_outlined, AppTheme.accent,
                      '"Scan"', 'Detects objects every 2 seconds with voice'),
                  const Divider(color: AppTheme.border, height: 20),
                  _cmdRow(Icons.warning_amber_rounded, AppTheme.danger,
                      '"Help"', 'Sends live GPS location to guardian'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SOS Banner
            GestureDetector(
              onTap: () {
                setState(() => _tab = 3);
                SosService.instance.sendSos();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTheme.danger.withOpacity(0.18),
                    AppTheme.danger.withOpacity(0.07),
                  ]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.danger.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    PulsingDot(color: AppTheme.danger),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Emergency SOS',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                  color: AppTheme.danger)),
                          SizedBox(height: 2),
                          Text('Say "Help" or tap to send live location to guardian',
                              style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.danger),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cmdRow(IconData icon, Color color, String cmd, String desc) => Row(
    children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
            color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cmd, style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600, color: AppTheme.textPri)),
            Text(desc, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ),
    ],
  );

  Widget _featCard(IconData icon, Color color, String name, String sub, int tab) =>
      GestureDetector(
        onTap: () => setState(() => _tab = tab),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _tab == tab
                ? color.withOpacity(0.4) : AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(name, style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppTheme.textPri)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ),
      );
}
