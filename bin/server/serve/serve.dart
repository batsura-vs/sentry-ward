import 'dart:async';
import 'dart:io';

import 'package:chalkdart/chalk.dart';

import '../../dto/proxy_dto.dart';
import '../../fetcher/fetcher.dart';
import '../../validator/validator.dart';

class Server {
  List<ProxyDto> proxyPool;
  final int? changeAfter;
  final Fetcher? fetcher;
  final int? updateTime;
  final int? timeToChangeProxy;
  int requestCounter = 0;
  int cursor = 0;

  Server({
    required this.proxyPool,
    this.changeAfter,
    this.fetcher,
    this.updateTime,
    this.timeToChangeProxy,
  });

  Future<void> run({InternetAddress? address, int? port}) async {
    ServerSocket socket = await ServerSocket.bind(
      address ?? InternetAddress.anyIPv4,
      port ?? 8080,
    );
    print(
      "Listening at ${chalk.blue("${socket.address.address}:${socket.port}")}",
    );
    if (updateTime != null) {
      Timer.periodic(
        Duration(seconds: updateTime!),
        (timer) => updateProxyList(),
      );
    }
    if (timeToChangeProxy != null) {
      Timer.periodic(
        Duration(seconds: timeToChangeProxy!),
        (timer) {
          cursor = (cursor + 1) % proxyPool.length;
          print(
            "[${chalk.green(DateTime.now())}] ${chalk.blue("[System]").padRight(20)} => proxy changed to ${proxyPool[cursor].proxy}",
          );
        },
      );
    }
    await for (final Socket socket in socket) {
      runZonedGuarded(
        () => handleRequest(socket),
        (error, stack) {
          socket.destroy();
          print(
            "[${chalk.green(DateTime.now())}] ${chalk.red("[ERROR]").padRight(20)} => $error",
          );
        },
      );
    }
  }

  Future<void> handleRequest(Socket clientSocket) async {
    ProxyDto proxy = getProxy();
    clientSocket.done.whenComplete(() => clientSocket.destroy());
    Socket simpleSocket = await Socket.connect(proxy.host, proxy.port)
        .onError((error, stackTrace) {
      throw Exception("Cant connect to proxy");
    });
    simpleSocket.done.whenComplete(() => clientSocket.destroy());
    print(
      "[${chalk.green(DateTime.now())}] ${chalk.blue("[INFO]").padRight(20)} => forwarding through $proxy",
    );
    clientSocket.addStream(simpleSocket.asBroadcastStream());
    simpleSocket.addStream(clientSocket.asBroadcastStream());
  }

  ProxyDto getProxy() {
    cursor %= proxyPool.length;
    ProxyDto res = proxyPool[cursor];
    if (changeAfter != null) {
      if (requestCounter >= changeAfter!) {
        cursor++;
        cursor %= proxyPool.length;
        requestCounter = 0;
      }
      res = proxyPool[cursor];
      requestCounter++;
    }
    return res;
  }

  Future<void> updateProxyList() async {
    if (fetcher == null) return;
    print(
      "[${chalk.green(DateTime.now())}] ${chalk.green("[System]").padRight(20)} => Updating proxy list",
    );
    List<ProxyDto> prx = await fetcher!.fetchAll();
    proxyPool =
        await ProxyValidator(proxies: prx).validateAll(onValid: (proxy) {
      print(
        "[${chalk.red(proxy.ipInfo?.countryCode)}] $proxy",
      );
    });
    print(
      "[${chalk.green(DateTime.now())}] ${chalk.green("[System]").padRight(20)} => Update finished",
    );
  }
}
