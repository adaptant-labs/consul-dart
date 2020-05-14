class HealthChecksModel {
  final List<HealthCheck> healthChecks;

  HealthChecksModel({this.healthChecks});

  factory HealthChecksModel.fromJsonList(List<dynamic> jsonList) {
    var list = <HealthCheck>[];
    jsonList.forEach((value) {
      list.add(HealthCheck.fromJson(value));
    });
    return HealthChecksModel(healthChecks: list);
  }

  @override
  String toString() {
    return 'HealthChecksModel[healthChecks=$healthChecks]';
  }
}

class HealthCheckDefinition {
  final String http;
  final String method;
  final bool tlsSkipVerify;
  final String tcp;
  final String intervalDuration;
  final String timeoutDuration;
  final String deregisterCriticalServiceAfterDuration;

  HealthCheckDefinition({
    this.http,
    this.method,
    this.tlsSkipVerify,
    this.tcp,
    this.intervalDuration,
    this.timeoutDuration,
    this.deregisterCriticalServiceAfterDuration,
  });

  factory HealthCheckDefinition.fromJson(Map<String, dynamic> json) => HealthCheckDefinition(
    http: json['HTTP'],
    method: json['Method'],
    tlsSkipVerify: json['TLSSkipVerify'],
    intervalDuration: json['Interval'],
    timeoutDuration: json['Timeout'],
    deregisterCriticalServiceAfterDuration: json['DeregisterCriticalServiceAfter'],
  );

  @override
  String toString() {
    return 'HealthCheckDefinition[HTTP=$http, Method=$method, TLSSkipVerify=$tlsSkipVerify, Interval=$intervalDuration, Timeout=$timeoutDuration, DeregisterCriticalServiceAfterShutdown=$deregisterCriticalServiceAfterDuration]';
  }
}

class HealthCheck {
  final String node;
  final String checkId;
  final String name;
  final String status;
  final String notes;
  final String serviceId;
  final String serviceName;
  final HealthCheckDefinition definition;

  HealthCheck({
    this.node,
    this.checkId,
    this.name,
    this.status,
    this.notes,
    this.serviceId,
    this.serviceName,
    this.definition,
  });

  factory HealthCheck.fromJson(Map<String, dynamic> json) => HealthCheck(
    node: json['Node'],
    checkId: json['CheckID'],
    name: json['Name'],
    status: json['Status'],
    notes: json['Notes'],
    serviceId: json['ServiceID'],
    serviceName: json['ServiceName'],
    definition: HealthCheckDefinition.fromJson(json['Definition']),
  );

  @override
  String toString() {
    return 'HealthChecks[Node=$node, CheckID=$checkId, Name=$name, Status=$status, Definition=$definition]';
  }
}
