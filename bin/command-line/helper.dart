import 'package:chalkdart/chalk.dart';
import 'package:enough_ascii_art/enough_ascii_art.dart' as art;

import '../fonts/crawford.dart';

class Helper {
  static Future<String> showLogo() async {
    return chalk.blue(art.renderFiglet('Sentry Ward', art.Font.text(font)));
  }
}