# Consul API for Dart

[![Build Status](https://travis-ci.com/adaptant-labs/consul-dart.svg?branch=master)](https://travis-ci.com/adaptant-labs/consul-dart#)
[![Pub](https://img.shields.io/pub/v/consul.svg)](https://pub.dev/packages/consul)

This provides an implementation of the HashiCorp Consul REST API in Dart.

## Overview

This is a work in progress, and only implements a subset of the APIs at present. This has primarily been designed with
the aim of allowing Dart-based microservices to register and unregister themselves and their corresponding health checks
with the Consul Agent, so this has been the initial implementation focus.

Implementation of the other APIs will gradually follow.

## Usage

A simple usage example:

```dart
import 'package:consul/consul.dart';

main() {
  // Connect to the local Consul Agent
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

  ... do something ...

  await agent.deregisterService('test-service');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/adaptant-labs/consul-dart/issues

## License

Licensed under the terms of the Apache 2.0 license.
