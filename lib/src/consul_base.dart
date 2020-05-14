class Consul {
  String host;
  int port;

  String apiVersion;
  String scheme;

  Consul({
    this.host = 'localhost',
    this.port = 8500,
    this.apiVersion = 'v1',
    this.scheme = 'http',
  });

  Uri buildUri(String prefix, String resource, [Map<String, dynamic> params]) {
    return Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: '/' + apiVersion + '/' + prefix + '/' + resource,
      queryParameters: params,
    );
  }
}

Consul defaultConsul = Consul();