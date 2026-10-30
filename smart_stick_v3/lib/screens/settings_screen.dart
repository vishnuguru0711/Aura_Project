import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/sos_service.dart';
import '../services/tts_service.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _guardianCtrl = TextEditingController();
  final TextEditingController _streamCtrl   = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final guardian = await SosService.instance.getGuardianNumber();
    final stream = prefs.getString('stream_url') ?? 'http://192.168.1.100:81/stream';
    if (mounted) {
      _guardianCtrl.text = guardian;
      _streamCtrl.text   = stream;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await SosService.instance.saveGuardianNumber(_guardianCtrl.text.trim());
    await prefs.setString('stream_url', _streamCtrl.text.trim());
    TtsService.instance.speak('Settings saved.');
    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  @override
  void dispose() {
    _guardianCtrl.dispose();
    _streamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Emergency Contact'),
              DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Guardian Phone Number',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600, color: AppTheme.textPri)),
                    const SizedBox(height: 4),
                    const Text('SOS alerts will be sent to this number via SMS or WhatsApp',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    const SizedBox(height: 12),
                    _field(_guardianCtrl, '+91XXXXXXXXXX',
                        Icons.phone_outlined, TextInputType.phone),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const SectionLabel('ESP32-CAM Stream'),
              DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stream URL',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600, color: AppTheme.textPri)),
                    const SizedBox(height: 4),
                    const Text('Your ESP32-CAM streaming address (e.g. http://192.168.x.x:81/stream)',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    const SizedBox(height: 12),
                    _field(_streamCtrl, 'http://192.168.1.100:81/stream',
                        Icons.wifi_outlined, TextInputType.url),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppTheme.accent,
                      AppTheme.accent.withOpacity(0.75),
                    ]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_saved ? Icons.check : Icons.save_outlined,
                          color: Colors.black, size: 20),
                      const SizedBox(width: 8),
                      Text(_saved ? 'Saved!' : 'Save Settings',
                          style: const TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w700, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      IconData icon, TextInputType keyboard) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(color: AppTheme.textPri, fontSize: 14,
            fontFamily: 'monospace'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 18),
          filled: true,
          fillColor: AppTheme.bg3,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );
}
