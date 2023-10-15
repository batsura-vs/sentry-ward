import 'package:dio/dio.dart';
import 'package:dio/io.dart';

extension ProxyX on Dio {
  /// Use a proxy to connect to the internet.
  ///
  /// If [proxyUrl] is a non-empty, non-null String, connect to the proxy server.
  ///
  /// If [proxyUrl] is empty or `null`, does nothing.
  void useProxy(String? proxyUrl) {
    if (proxyUrl != null && proxyUrl.isNotEmpty) {
      (httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (client) => client
            ..findProxy = (url) {
              return 'PROXY $proxyUrl';
            }
            ..badCertificateCallback = (cert, host, post) => true;
    } else {
      httpClientAdapter = IOHttpClientAdapter();
    }
  }
}
