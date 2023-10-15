// {
// "ipVersion": 4,
// "ipAddress": "95.84.158.25",
// "latitude": 55.904514,
// "longitude": 37.560879,
// "countryName": "Russian Federation",
// "countryCode": "RU",
// "timeZone": "+03:00",
// "zipCode": "141707",
// "cityName": "Dolgoprudnyy",
// "regionName": "Moskovskaya oblast'",
// "continent": "Europe",
// "continentCode": "EU"
// }

class IpInfo {
  final int? ipVersion;
  final String? ipAddress;
  final double? latitude;
  final double? longitude;
  final String? countryName;
  final String? countryCode;
  final String? timeZone;
  final String? zipCode;
  final String? cityName;
  final String? regionName;
  final String? continent;
  final String? continentCode;

  IpInfo({
    this.ipVersion,
    this.ipAddress,
    this.latitude,
    this.longitude,
    this.countryName,
    this.countryCode,
    this.timeZone,
    this.zipCode,
    this.cityName,
    this.regionName,
    this.continent,
    this.continentCode,
  });

  /// from json
  factory IpInfo.fromJson(Map<String, dynamic> json) {
    return IpInfo(
      ipVersion: json['ipVersion'],
      ipAddress: json['ipAddress'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      countryName: json['countryName'],
      countryCode: json['countryCode'],
      timeZone: json['timeZone'],
      zipCode: json['zipCode'],
      cityName: json['cityName'],
      regionName: json['regionName'],
      continent: json['continent'],
      continentCode: json['continentCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ipVersion': ipVersion,
      'ipAddress': ipAddress,
      'latitude': latitude,
      'longitude': longitude,
      'countryName': countryName,
      'countryCode': countryCode,
      'timeZone': timeZone,
      'zipCode': zipCode,
      'cityName': cityName,
      'regionName': regionName,
      'continent': continent,
      'continentCode': continentCode,
    };
  }
}
