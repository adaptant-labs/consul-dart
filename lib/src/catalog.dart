class ServiceAddressModel {
  final Map<String, ServiceAddress> serviceAddressMap;

  ServiceAddressModel({this.serviceAddressMap});

  factory ServiceAddressModel.fromJson(Map<String, dynamic> json) {
    var map = <String, ServiceAddress>{};
    if (json != null) {
      json.forEach((key, value) {
        map[key] = ServiceAddress.fromJson(value);
      });
    }
    return ServiceAddressModel(serviceAddressMap: map);
  }

  @override
  String toString() {
    return 'ServiceAddressModel[ServiceAddressMap=$serviceAddressMap]';
  }
}

class ServiceAddress {
  final String address;
  final int port;

  ServiceAddress({this.address, this.port});

  factory ServiceAddress.fromJson(Map<String, dynamic> json) => ServiceAddress(
    address: json['Address'],
    port: json['Port'],
  );

  @override
  String toString() {
    return 'ServiceAddress[Address=$address, Port=$port]';
  }
}
