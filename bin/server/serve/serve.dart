import 'dart:async';
import 'dart:io';

import 'package:chalkdart/chalk.dart';

import '../../dto/proxy_dto.dart';

class Server {
  final List<ProxyDto> proxyPool;
  final int? changeAfter;
  int requestCounter = 0;
  int cursor = 0;

  Server({
    required this.proxyPool,
    this.changeAfter,
  });

  Future<void> run({InternetAddress? address, int? port}) async {
    ServerSocket socket = await ServerSocket.bind(
      address ?? InternetAddress.anyIPv4,
      port ?? 8080,
    );
    print(
      "Listening at ${chalk.blue("${socket.address.address}:${socket.port}")}",
    );
    await for (final Socket socket in socket) {
      runZonedGuarded(
        () => handleRequest(socket),
        (error, stack) {
          socket.destroy();
          print(
            "[${chalk.green(DateTime.now())}] [${chalk.red("ERROR")}] => $error",
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
      cursor++;
      throw Exception("Cant connect to proxy");
    });
    simpleSocket.done.whenComplete(() => clientSocket.destroy());
    print(
      "[${chalk.green(DateTime.now())}] [${chalk.blue("INFO")}]  => forwarding through $proxy",
    );
    clientSocket.addStream(simpleSocket.asBroadcastStream());
    simpleSocket.addStream(clientSocket.asBroadcastStream());
  }

  ProxyDto getProxy() {
    ProxyDto res = proxyPool.first;
    if (changeAfter != null) {
      if (requestCounter >= changeAfter!) {
        cursor++;
        cursor %= proxyPool.length;
        requestCounter = 0;
      }
      res = proxyPool[cursor];
    }
    requestCounter++;
    return res;
  }
}
