import 'ip_info.dart';

class ProxyDto {
  final String host;
  final int port;
  final IpInfo? ipInfo;

  ProxyDto({
    required this.host,
    required this.port,
    this.ipInfo,
  });

  String get proxy => '$host:$port';

  /// copy with
  ProxyDto copyWith({
    String? host,
    int? port,
    IpInfo? ipInfo,
  }) {
    return ProxyDto(
      host: host ?? this.host,
      port: port ?? this.port,
      ipInfo: ipInfo ?? this.ipInfo,
    );
  }

  /// to json
  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'ipInfo': ipInfo?.toJson(),
    };
  }
}
