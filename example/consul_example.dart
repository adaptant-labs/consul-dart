import 'package:consul/consul.dart';

Future<void> main() async {
  // Connect to the local Consul Agent. ConsulAgent() takes an optional
  // Consul host/port specification, but will default to localhost:8500 if this
  // is omitted - it is only included here for demonstrative purposes.
  var consul = Consul(host: 'localhost', port: 8500);
  var agent = ConsulAgent(consul: consul);

  // Register a new test service and health check.
  var serviceRegistration = AgentServiceRegistration(
    name: 'test-service',
    address: 'localhost',
    port: 12345,
    check: AgentServiceCheck(
      name: 'test-service-check',
      interval: '30s',
      http: 'http://localhost:12345/health',
    ),
  );

  await agent.registerService(serviceRegistration);

  var services = await agent.getServices();
  print(services);

  var service = await agent.getService('test-service');
  print(service);

  var health = await agent.getServiceHealthByID('test-service');
  print(health);

  await agent.deregisterService('test-service');
}
