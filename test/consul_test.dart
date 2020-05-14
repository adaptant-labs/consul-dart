import 'package:consul/consul.dart';
import 'package:test/test.dart';

// Tests for the Consul API
void main() {
  var agent = ConsulAgent();

  group('Validate API Defaults', () {
    test('Test Consul Agent Defaults', () {
      expect(agent.consul.host, 'localhost');
      expect(agent.consul.port, 8500);
    });
  });
}
