import 'package:url_launcher/url_launcher.dart';

/// Opens links outside the app (store subscription settings, terms,
/// privacy policy).
abstract interface class UrlOpener {
  /// False when nothing could open [uri].
  Future<bool> open(Uri uri);
}

final class PlatformUrlOpener implements UrlOpener {
  const PlatformUrlOpener();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
