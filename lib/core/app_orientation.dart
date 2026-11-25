import 'package:flutter/services.dart';

class AppOrientation {
  static Future<void> lockPortrait() => SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  static Future<void> allowAll() => SystemChrome.setPreferredOrientations(
    DeviceOrientation.values,
  );
}
