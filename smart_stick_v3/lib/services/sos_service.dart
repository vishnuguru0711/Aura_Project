import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tts_service.dart';

class SosService {
  SosService._();
  static final SosService instance = SosService._();

  static const String _defaultNumber = '+919XXXXXXXXX'; // fallback

  Future<String> getGuardianNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('guardian_number') ?? _defaultNumber;
  }

  Future<void> saveGuardianNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('guardian_number', number);
  }

  Future<void> sendSos() async {
    TtsService.instance.speak('S O S activated. Getting your location. Please wait.');

    // Get GPS
    Position? position;
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));
      }
    } catch (_) {}

    final guardian = await getGuardianNumber();
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    String message;
    String mapsLink = '';
    if (position != null) {
      mapsLink =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      message = '🆘 EMERGENCY ALERT!\n'
          'Your family member needs immediate help!\n'
          'Time: $timeStr\n'
          'Live Location: $mapsLink\n'
          'Sent from Smart Walking Stick App.';
    } else {
      message = '🆘 EMERGENCY ALERT!\n'
          'Your family member needs immediate help!\n'
          'Time: $timeStr\n'
          'GPS unavailable — please call them immediately!\n'
          'Sent from Smart Walking Stick App.';
    }

    final smsUri = Uri(
      scheme: 'sms',
      path: guardian,
      queryParameters: {'body': message},
    );
    final encodedMsg = Uri.encodeComponent(message);
    final whatsappUri = Uri.parse(
        'https://wa.me/${guardian.replaceAll('+', '')}?text=$encodedMsg');

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        TtsService.instance
            .speak('Message ready. Tap send to alert your guardian.');
      } else if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        TtsService.instance
            .speak('WhatsApp ready. Tap send to alert your guardian.');
      } else {
        TtsService.instance
            .speak('Could not open messaging app. Please call your guardian.');
      }
    } catch (_) {
      TtsService.instance.speak('Error sending SOS. Please call for help.');
    }
  }
}
