import 'dart:io';

import 'package:args/args.dart';
import 'package:chalkdart/chalk.dart';
import 'package:console/console.dart';

import '../dto/proxy_dto.dart';
import '../fetcher/fetcher.dart';
import '../server/serve/serve.dart';
import '../validator/validator.dart';
import 'arg-parser.dart';
import 'helper.dart';

class Serve {
  final ArgResults arguments;
  final RegExp proxyRe = RegExp(
    r"([0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}):([0-9]{1,5})",
  );

  Serve({
    required this.arguments,
  });

  Future<void> run() async {
    Console.write(await Helper.showLogo());

    List<ProxyDto> proxies = await fetchFromRemote();
    proxies.addAll(await getFromLocal(arguments[local]));
    print(
      "\n${chalk.green("Total proxies")}: ${proxies.length}\n",
    );
    proxies = await validateAll(proxies);
    await Server(proxyPool: proxies).run();
    exit(0);
  }

  Future<List<ProxyDto>> getFromLocal(List<String> paths) async {
    List<ProxyDto> proxies = [];
    for (final path in paths) {
      String data = File(path).readAsStringSync();
      List matches = proxyRe.allMatches(data).toList();
      print("${"[${chalk.blue(matches.length)}]:".padRight(20)}$path");
      for (var element in matches) {
        proxies.add(ProxyDto(
          host: element.group(1)!,
          port: int.parse(element.group(2)!),
        ));
      }
    }
    return proxies;
  }

  Future<List<ProxyDto>> validateAll(List<ProxyDto> proxies) async {
    Console.eraseDisplay();
    ProxyValidator validator = ProxyValidator(
      proxies: proxies,
      socketTimeout: int.tryParse(arguments[socketTimeOut]),
      connectTimeout: int.tryParse(arguments[connectTimeout]),
      concurrentCheckers: int.tryParse(arguments[concurrentRequests]),
      showErrors: arguments[showErrors],
    );
    List<ProxyDto> validatedProxies =
        await validator.validateAll(onValid: (proxy) {
      print(
        "[${chalk.red(proxy.ipInfo?.countryCode)}] "
        "${chalk.green("${proxy.ipInfo?.cityName}").padRight(30)} "
        "${proxy.proxy.padRight(26)}",
      );
    });
    Console.write(
      "\n\n${chalk.green("Validation completed")}: ${validatedProxies.length} proxies\n",
    );
    return validatedProxies;
  }

  Future<List<ProxyDto>> fetchFromRemote() async {
    if (!arguments.wasParsed(remote)) return [];
    Console.eraseDisplay();
    Fetcher fetcher = Fetcher(
      proxyLists: arguments[remote],
    );
    List<ProxyDto> proxies = await fetcher.fetchAll(
      onProgress: (url, count) =>
          print("${"[${chalk.blue(count)}]:".padRight(10)}$url"),
    );
    return proxies;
  }
}
