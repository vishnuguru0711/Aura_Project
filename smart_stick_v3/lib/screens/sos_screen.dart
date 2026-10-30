import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import '../services/sos_service.dart';
import '../services/tts_service.dart';
import '../widgets/common_widgets.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});
  @override State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool _sending = false;
  String _status = '';
  Position? _position;
  final TextEditingController _guardianCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGuardian();
    _getLocation();
  }

  Future<void> _loadGuardian() async {
    final n = await SosService.instance.getGuardianNumber();
    if (mounted) _guardianCtrl.text = n;
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
            .timeout(const Duration(seconds: 10));
        if (mounted) setState(() => _position = pos);
      }
    } catch (_) {}
  }

  Future<void> _sendSos() async {
    setState(() { _sending = true; _status = 'Getting location...'; });
    await _getLocation();
    setState(() => _status = 'Opening messenger...');
    await SosService.instance.sendSos();
    if (mounted) setState(() { _sending = false; _status = 'Message ready to send!'; });
  }

  Future<void> _saveGuardian() async {
    final n = _guardianCtrl.text.trim();
    if (n.isEmpty) return;
    await SosService.instance.saveGuardianNumber(n);
    TtsService.instance.speak('Guardian number saved.');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardian number saved'), backgroundColor: AppTheme.accent),
      );
    }
  }

  @override
  void dispose() {
    _guardianCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.danger, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency SOS',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                            color: AppTheme.danger)),
                    Text('Send live location to guardian',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // GPS Status
            DarkCard(
              child: Row(
                children: [
                  PulsingDot(
                      color: _position != null ? AppTheme.accent : AppTheme.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _position != null ? 'GPS Location Ready' : 'Getting GPS...',
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600, color: AppTheme.textPri),
                        ),
                        if (_position != null)
                          Text(
                            '${_position!.latitude.toStringAsFixed(5)}, '
                            '${_position!.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(fontSize: 10,
                                color: AppTheme.textMuted, fontFamily: 'monospace'),
                          )
                        else
                          const Text('Waiting for location permission...',
                              style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  if (_position != null)
                    StatusBadge(label: 'READY', color: AppTheme.accent),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Guardian number
            const SectionLabel('Guardian Number'),
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Phone number for emergency alerts',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _guardianCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                              color: AppTheme.textPri,
                              fontSize: 15,
                              fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: '+91XXXXXXXXXX',
                            hintStyle: const TextStyle(color: AppTheme.textMuted),
                            prefixIcon: const Icon(Icons.phone_outlined,
                                color: AppTheme.textMuted, size: 18),
                            filled: true,
                            fillColor: AppTheme.bg3,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _saveGuardian,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.accent.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.save_outlined,
                              color: AppTheme.accent, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // What the SOS sends
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SOS Message includes:',
                      style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w600, color: AppTheme.textPri)),
                  const SizedBox(height: 10),
                  _msgRow(Icons.location_on_outlined, AppTheme.accent,
                      'Live Google Maps link with GPS coords'),
                  const SizedBox(height: 6),
                  _msgRow(Icons.access_time, AppTheme.blue, 'Current time of distress'),
                  const SizedBox(height: 6),
                  _msgRow(Icons.message_outlined, AppTheme.accent2,
                      'Sent via SMS or WhatsApp'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status message
            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.accent, size: 16),
                      const SizedBox(width: 8),
                      Text(_status, style: const TextStyle(
                          fontSize: 12, color: AppTheme.accent)),
                    ],
                  ),
                ),
              ),

            // Big SOS Button
            GestureDetector(
              onTap: _sending ? null : _sendSos,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTheme.danger,
                    AppTheme.danger.withOpacity(0.75),
                  ]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.danger.withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_sending)
                      const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                    else
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    Text(
                      _sending ? 'Sending SOS...' : 'SEND SOS NOW',
                      style: const TextStyle(fontSize: 17,
                          fontWeight: FontWeight.w800, color: Colors.white,
                          letterSpacing: 1.0),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Or say "Help" at any time to trigger SOS automatically',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _msgRow(IconData icon, Color color, String text) => Row(
    children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 8),
      Expanded(child: Text(text,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted))),
    ],
  );
}
