import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:chalkdart/chalk.dart';
import 'package:console/console.dart';
import 'package:csv/csv.dart';

import '../dto/proxy_dto.dart';
import '../fetcher/fetcher.dart';
import '../validator/validator.dart';
import 'arg-parser.dart';
import 'helper.dart';

class CommandLine {
  final ArgResults arguments;
  final RegExp proxyRe = RegExp(
    r"([0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}):([0-9]{1,5})",
  );

  CommandLine({
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
    if (arguments[outputFormat] == "json") {
      await saveAsJSON(proxies);
    } else {
      await saveAsCSV(proxies);
    }
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

  Future<void> saveAsCSV(List<ProxyDto> proxies) async {
    final stream = Stream.fromIterable([
      [
        "HOST",
        "PORT",
        "IP_VERSION",
        "IP_ADDRESS",
        "LATITUDE",
        "LONGITUDE",
        "COUNTRY_NAME",
        "COUNTRY_CODE",
        "TIME_ZONE",
        "ZIP_CODE",
        "CITY_NAME",
        "REGION_NAME",
        "CONTINENT",
        "CONTINENT_CODE"
      ],
      ...List.generate(
          proxies.length,
          (index) => [
                proxies[index].host,
                proxies[index].port,
                proxies[index].ipInfo?.ipVersion,
                proxies[index].ipInfo?.ipAddress,
                proxies[index].ipInfo?.latitude,
                proxies[index].ipInfo?.longitude,
                proxies[index].ipInfo?.countryName,
                proxies[index].ipInfo?.countryCode,
                proxies[index].ipInfo?.timeZone,
                proxies[index].ipInfo?.zipCode,
                proxies[index].ipInfo?.cityName,
                proxies[index].ipInfo?.regionName,
                proxies[index].ipInfo?.continent,
                proxies[index].ipInfo?.continentCode,
              ])
    ]);
    final csvRowStream = stream.transform(ListToCsvConverter());
    final output = File("${arguments[outputFile]}.csv").openWrite();
    await for (var row in csvRowStream) {
      output.write(row);
    }
    await output.close();
  }

  Future<void> saveAsJSON(List<ProxyDto> proxies) async {
    final output = File("${arguments[outputFile]}.json").openWrite();
    output.write(jsonEncode(proxies));
    await output.close();
  }
}
