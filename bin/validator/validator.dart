import 'dart:async';
import 'dart:io';

import 'package:chalkdart/chalk.dart';
import 'package:dio/dio.dart';
import 'package:semaphore_plus/semaphore_plus.dart';

import '../dto/ip_info.dart';
import '../dto/proxy_dto.dart';
import '../utils/dio_proxy_adapter.dart';

class ProxyValidator {
  final List<ProxyDto> proxies;
  final int? socketTimeout;
  final int? connectTimeout;
  final int? concurrentCheckers;
  final bool showErrors;

  ProxyValidator({
    required this.proxies,
    this.socketTimeout,
    this.connectTimeout,
    this.concurrentCheckers,
    this.showErrors = false,
  });

  Future<List<ProxyDto>> validateAll({Function(ProxyDto)? onValid}) async {
    LocalSemaphore semaphore = LocalSemaphore(concurrentCheckers ?? 100);
    List<ProxyDto> validatedProxies = [];
    List<Future> tasks = [];
    for (final proxy in proxies) {
      await semaphore.acquire();
      Future<ProxyDto?> checkRes = _pipe(
        [_connectUsingSocket, _fetchIPInfo],
        proxy,
      );
      tasks.add(checkRes);
      checkRes.then((value) {
        if (value == null) return;
        validatedProxies.add(value);
        onValid?.call(value);
      });
      checkRes.whenComplete(() {
        tasks.remove(checkRes);
        semaphore.release();
      });
    }
    await Future.wait(tasks);
    return validatedProxies;
  }

  Future<ProxyDto?> _connectUsingSocket(ProxyDto proxy) async {
    return await RawSocket.connect(
      proxy.host,
      proxy.port,
      timeout: Duration(milliseconds: socketTimeout ?? 2000),
    ).then((value) {
      value.close();
      return proxy;
    });
  }

  Future<ProxyDto?> _fetchIPInfo(ProxyDto proxy) async {
    Dio dio = Dio();
    dio.useProxy(proxy.proxy);
    final response = await dio.get("https://freeipapi.com/api/json").timeout(
          Duration(milliseconds: connectTimeout ?? 5000),
        );
    dio.close(force: true);
    if (response.statusCode == 200) {
      return proxy.copyWith(ipInfo: IpInfo.fromJson(response.data));
    }
    return null;
  }

  Future<ProxyDto?> _pipe(
    List<Future Function(ProxyDto)> checkers,
    ProxyDto proxy,
  ) async {
    ProxyDto? result;
    for (final checker in checkers) {
      result = await checker(proxy).onError((error, stackTrace) {
        if (showErrors) print("[${chalk.red("ERROR")}] => $error");
      });
      if (result == null) return null;
    }
    return result;
  }
}
