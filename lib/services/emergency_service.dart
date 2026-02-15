import 'package:url_launcher/url_launcher.dart';

class EmergencyUtils {
  static Future<void> callEmergency({String number = '112'}) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }
}