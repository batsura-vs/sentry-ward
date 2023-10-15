import 'package:dio/dio.dart';

import '../dto/proxy_dto.dart';

class Fetcher {
  final List<String> proxyLists;
  final Dio dio = Dio(
    BaseOptions(
      validateStatus: (status) => true,
    ),
  );
  final RegExp proxyRe = RegExp(
    r"([0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}):([0-9]{1,5})",
  );

  Fetcher({
    required this.proxyLists,
  });

  Future<List<ProxyDto>> fetchAll({Function(String, int)? onProgress}) async {
    List<ProxyDto> proxies = [];
    for (final proxy in proxyLists) {
      List<ProxyDto>? proxiesFromOne =
          await _fetchOne(proxy).onError((error, stackTrace) => null);
      onProgress?.call(proxy, proxiesFromOne?.length ?? 0);
      if (proxiesFromOne == null) continue;
      proxies.addAll(proxiesFromOne);
    }
    return proxies;
  }

  Future<List<ProxyDto>?> _fetchOne(String resource) async {
    List<ProxyDto> proxies = [];
    var Response(:data, :statusCode) = await dio.get(resource);
    if (statusCode != 200) return null;

    proxyRe.allMatches(data).forEach((element) {
      proxies.add(
        ProxyDto(
          host: element.group(1)!,
          port: int.parse(element.group(2)!),
        ),
      );
    });
    return proxies;
  }
}
