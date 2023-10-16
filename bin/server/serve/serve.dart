import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:chalkdart/chalk.dart';

import '../../dto/proxy_dto.dart';

class Server {
  final List<ProxyDto> proxyPool;

  Server({required this.proxyPool});

  Future<void> run({InternetAddress? address, int? port}) async {
    ServerSocket socket = await ServerSocket.bind(
      address ?? InternetAddress.anyIPv4,
      port ?? 8080,
    );
    print("Listening at ${socket.address.address}:${socket.port}");
    await for (final Socket socket in socket) {
      runZonedGuarded(
        () => handleRequest(socket),
        (error, stack) => print(
            "[${chalk.green(DateTime.now())}] [${chalk.red("ERROR").padRight(10)}] => $error"),
      );
    }
  }

  Future<void> handleRequest(Socket clientSocket) async {
    ProxyDto proxy = (proxyPool..shuffle()).first;
    clientSocket.done.onError((error, stackTrace) => null);
    Socket simpleSocket = await Socket.connect(proxy.host, proxy.port);
    simpleSocket.done.onError((error, stackTrace) => null);
    print(
      "[${chalk.green(DateTime.now())}] [${chalk.blue("INFO").padRight(10)}] => forwarding through $proxy",
    );
    clientSocket.addStream(simpleSocket.asBroadcastStream());
    simpleSocket.addStream(clientSocket.asBroadcastStream());
  }

  void updatePool() {}
}
