import 'dart:io';

import 'package:args/args.dart';

import 'command-line/arg-parser.dart';
import 'command-line/command-line.dart';
import 'command-line/helper.dart';
import 'command-line/serve.dart';

void main(List<String> arguments) async {
  ArgResults argResults = parser.parse(arguments);
  CommandLine commandLine = CommandLine(
    arguments: argResults,
  );
  Serve serve = Serve(
    arguments: argResults,
  );
  if (argResults.wasParsed('help')) {
    print(await Helper.showLogo());
    print(parser.usage);
    exit(0);
  }
  if (argResults.wasParsed(serveRotatingProxy)) {
    await serve.run();
  } else {
    await commandLine.run();
  }
}
