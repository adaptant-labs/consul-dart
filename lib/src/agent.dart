import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:consul/src/catalog.dart';
import 'package:consul/src/consul_base.dart';
import 'package:consul/src/health.dart';
import 'package:meta/meta.dart';

class AgentServiceModel {
  final List<AgentService> agentServices;

  AgentServiceModel({this.agentServices});

  factory AgentServiceModel.fromJson(Map<String, dynamic> json) {
    var list = <AgentService>[];
    json.forEach((key, value) {
      var agentService = AgentService.fromJson(value);
      list.add(agentService);
    });

    return AgentServiceModel(agentServices: list);
  }

  @override
  String toString() {
    return 'AgentServiceModel[agentServices=$agentServices]';
  }
}

class AgentServiceRegistration {
  final String kind;
  final String id;
  final String name;
  final List<String> tags;
  final int port;
  final String address;
  final AgentServiceCheck check;

  AgentServiceRegistration({
    this.kind,
    this.id,
    @required this.name,
    this.tags,
    this.port,
    this.address,
    this.check
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (kind != null) {
      json['Kind'] = kind;
    }

    // If no ID is specified, default to using the name, as per the Consul API.
    if (id != null) {
      json['ID'] = id;
    } else {
      json['ID'] = name;
    }

    json['Name'] = name;
    json['Tags'] = tags;
    json['Port'] = port;
    json['Address'] = address;
    json['Check'] = check.toJson();

    return json;
  }
}

class AgentService {
  final String kind;
  final String id;
  final String service;
  final List<String> tags;
  final Map<String, String> meta;
  final int port;
  final String address;
  final ServiceAddressModel taggedAddresses;
  final AgentWeights weights;
  final bool enableTagOverride;
  final int createIndex;
  final int modifyIndex;
  final String contentHash;

  AgentService({
    this.kind,
    this.id,
    this.service,
    this.tags,
    this.meta,
    this.port,
    this.address,
    this.taggedAddresses,
    this.weights,
    this.enableTagOverride,
    this.createIndex,
    this.modifyIndex,
    this.contentHash,
  });

  factory AgentService.fromJson(Map<String, dynamic> json) => AgentService(
    kind: json['Kind'],
    id: json['ID'],
    service: json['Service'],
    meta: mapFromJson(json['Meta']).cast(),
    tags: json['Tags']?.cast<String>(),
    address: json['Address'],
    port: json['Port'],
    taggedAddresses: ServiceAddressModel.fromJson(json['TaggedAddresses']),
    weights: AgentWeights.fromJson(json['Weights']),
    enableTagOverride: json['EnableTagOverride'],
    createIndex: json['CreateIndex'],
    modifyIndex: json['ModifyIndex'],
    contentHash: json['ContentHash'],
  );

  static Map<String, dynamic> mapFromJson(Map<String, dynamic> json) {
    var map = <String, dynamic>{};
    json.forEach((key, value) => map[key] = value);
    return map;
  }

  @override
  String toString() {
    return 'AgentService[Kind=$kind, ID=$id, Service=$service, Tags=$tags, Address=$address, Port=$port, TaggedAddresses=$taggedAddresses, Weights=$weights, EnableTagOverride=$enableTagOverride, ContentHash=$contentHash]';
  }
}

class AgentWeights {
  final int passing;
  final int warning;

  AgentWeights({
    this.passing,
    this.warning
  });

  factory AgentWeights.fromJson(Map<String, dynamic> json) => AgentWeights(
    passing: json['Passing'],
    warning: json['Warning'],
  );

  @override
  String toString() {
    return 'AgentWeights[Passing=$passing, Warning=$warning]';
  }
}

class AgentServiceCheck {
  final String checkId;
  final String name;
  final List<String> args;
  final String interval;
  final String notes;
  final String timeout;
  final String http;
  final bool tlsSkipVerify;

  AgentServiceCheck({
    this.checkId,
    @required this.name,
    this.args,
    this.interval,
    this.timeout = '10s',
    this.notes,
    this.http,
    this.tlsSkipVerify = false,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    // If no ID is specified, default to using the name, as per the Consul API.
    if (checkId != null) {
      json['CheckID'] = checkId;
    } else {
      json['CheckID'] = name;
    }

    json['Name'] = name;
    json['Args'] = args;
    json['HTTP'] = http;
    json['Notes'] = notes;
    json['Interval'] = interval;
    json['TLSSkipVerify'] = tlsSkipVerify;

    return json;
  }

  @override
  String toString() {
    return 'AgentServiceCheck[ID=$checkId, Name=$name, Args=$args, HTTP=$http, Interval=$interval, Notes=$notes, TLSSkipVerify=$tlsSkipVerify]';
  }
}

class AgentServiceChecksInfo {
  final String aggregatedStatus;
  final AgentService service;
  final List<HealthCheck> checks;

  AgentServiceChecksInfo({
    this.aggregatedStatus,
    this.service,
    this.checks,
  });

  factory AgentServiceChecksInfo.fromJson(Map<String, dynamic> json) => AgentServiceChecksInfo(
    aggregatedStatus: json['AggregatedStatus'],
    service: AgentService.fromJson(json['Service']),
    checks: HealthChecksModel.fromJsonList(json['Checks']).healthChecks,
  );

  @override
  String toString() {
    return 'AgentServiceChecksInfo[AggregatedStatus=$aggregatedStatus, Service=$service, Checks=$checks]';
  }
}

class ConsulAgent {
  final Consul consul;

  ConsulAgent({Consul consul}) : consul = consul ?? defaultConsul;

  Future<List<AgentService>> getServices() async {
    var servicesUri = _buildUri('services');
    var response = await http.get(servicesUri);
    var services = AgentServiceModel.fromJson(jsonDecode(response.body));
    return services.agentServices;
  }

  Future<AgentService> getService(String serviceName) async {
    var serviceUri = _buildUri('service/' + serviceName);
    var response = await http.get(serviceUri);
    if (response.statusCode == HttpStatus.notFound) {
      return null;
    }
    return AgentService.fromJson(jsonDecode(response.body));
  }

  Future<AgentServiceChecksInfo> getServiceHealthByID(String serviceID) async {
    var healthUri = _buildUri('health/service/id/' + serviceID);
    var response = await http.get(healthUri);
    if (response.statusCode == 404) {
      return null;
    }
    return AgentServiceChecksInfo.fromJson(jsonDecode(response.body));
  }

  Future<void> registerService(AgentServiceRegistration service) async {
    var registerUri = _buildUri('service/register');
    var data = service.toJson();
    var response = await http.put(registerUri, body: json.encode(data));
    if (response.statusCode != HttpStatus.ok) {
      print('Failed to register with Consul agent: ' + response.body);
    }
  }

  Future<void> deregisterService(String serviceID) async {
    var deregisterUri = _buildUri('service/deregister' + serviceID);
    var response = await http.put(deregisterUri);
    if (response.statusCode != HttpStatus.ok) {
      print('Failed to deregister service from Consul agent: ' + response.body);
    }
  }

  Uri _buildUri(String resource, [Map<String, dynamic> params]) {
    return consul.buildUri('agent', resource);
  }
}
