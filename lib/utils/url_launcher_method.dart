import 'package:fhir_demo/constants/extension.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherOptions {
  static Future<void> launchWeb(String url, {bool? launchModeEXT = false}) async {
    final launchUri = Uri.parse(url);
    try {
      await launchUrl(launchUri, mode: launchModeEXT == false ? LaunchMode.inAppWebView : LaunchMode.platformDefault);
    } catch (e) {
      'this is the error from launchWeb $e'.logError(name: 'launch_web');
      if (e is ArgumentError) {
        throw e.message.toString();
      } else {
        throw 'An unexpected error occurred while trying to launch the URL.';
      }
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static Future<void> sendSms(String phoneNumber) async {
    final launchUri = Uri(scheme: 'sms', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static Future<void> sendEmail(String email) async {
    final launchUri = Uri(scheme: 'mailto', path: email);
    await launchUrl(launchUri);
  }
}
