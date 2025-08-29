// Microservices Q&A
const Map<String, String> qAMicroservices = {
  "In microservices, an edge component that routes, authenticates, and rate-limits incoming requests is called the _ _.":
      "GATEWAY",
  "In microservices, keeping no per-user session state on the server so any instance can serve any request is being _ _.":
      "STATELESS",
  "In microservices, locating service instances at runtime via a registry like Consul or Eureka is _ _.":
      "DISCOVERY",
  "In microservices, failing fast to stop cascading failures and recovering after a cooldown uses the _ _ Breaker pattern.":
      "CIRCUIT",
  "In microservices, isolating resources so one failing dependency cannot exhaust all threads uses the _ _ pattern.":
      "BULKHEAD",
  "In microservices, coordinating a long business transaction with local steps and compensations is the _ _ pattern.":
      "SAGA",
  "In microservices, providing a tailored backend API layer per client (web, mobile, device) is the _ _ pattern.":
      "BFF",
  "In microservices, decoupling producers and consumers for async communication uses a message _ _.":
      "BROKER",
  "In microservices, a popular log-based streaming platform for event-driven systems is _ _.":
      "KAFKA",
  "In microservices, a machine-readable REST API contract commonly used for compatibility and codegen is _ _.":
      "OPENAPI",
  "In microservices, a compact signed token used to convey identity and claims between services is a _ _.":
      "JWT",
  "In microservices, delegating authorization to a separate server using the authorization code or client credentials flow is _ _.":
      "OAUTH2",
  "In microservices, encrypting and authenticating service-to-service traffic with mutual certificates is _ _.":
      "MTLS",
  "In microservices, attaching a unique value to each request so logs and traces can be linked uses a Correlation_ _.":
      "ID",
  "In microservices, capturing causal timing across services to see end-to-end requests is distributed _ _.":
      "TRACING",
  "In microservices, tracking rates, durations, and counts to monitor health and performance are _ _.":
      "METRICS",
  "In microservices, emitting structured, centralized application output for debugging and auditing is _ _.":
      "LOGGING",
  "In microservices, running a helper proxy alongside each instance to handle cross-cutting concerns is the _ _ pattern.":
      "SIDECAR",
  "In microservices, the rule that each service owns its data and schema privately is _ _ Per Service.":
      "DATABASE",
  "In microservices, deploying a new version alongside the old and switching traffic instantly is _ _ deployment.":
      "BLUEGREEN",
  "In microservices, gradually shifting a small slice of traffic to a new version to reduce risk is a _ _ release.":
      "CANARY",
  "In microservices, incrementally replacing a legacy system by routing new capabilities around it is the _ _ pattern.":
      "STRANGLER",
  "In microservices, the probe that reports readiness to receive traffic (dependencies OK) is _ _.":
      "READINESS",
  "In microservices, the probe that reports the process is alive (heartbeat) is _ _.":
      "LIVENESS",
  "In microservices, limiting requests per client to protect backends and ensure fairness is _ _.":
      "RATELIMIT",
  "In microservices, applying bounded retries with exponential delays to handle transient failures is _ _ with backoff.":
      "RETRY",
  "In microservices, the tracing identifier that represents a single operation within a request is the _ _.":
      "SPANID",
  "In microservices, strongly-typed remote calls over HTTP/2 with protobuf schemas are done with _ _.":
      "GRPC",
  "In microservices, managing traffic, security, and observability via sidecar proxies is a service _ _.":
      "MESH",
  "In microservices, storing configuration outside code and images using environment variables is _ _ config.":
      "ENVVARS",
  "In microservices, packaging and running services as isolated, portable units commonly uses _ _.":
      "DOCKER",
  "In microservices, updating instances gradually without downtime is a _ _ update.":
      "ROLLING",
  "In microservices, a queue where unprocessable messages are kept for inspection and recovery is a _ _.":
      "DLQ",
  "In microservices, accepting temporarily divergent replicas with reconciliation later is _ _ consistency.":
      "EVENTUAL",
  "In microservices, building dashboards to visualize metrics and alerts is often done with _ _.":
      "GRAFANA",
  "In microservices, verifying that providers and consumers agree on request and response shapes is _ _ testing.":
      "CONTRACT",
  "In microservices, generating unique identifiers that are globally unique across services commonly uses _ _.":
      "UUID",
  "In microservices, serving configuration from a central store with watches and dynamic reloads can use _ _.":
      "CONSUL",
  "In microservices, managing passwords, tokens, and certificates securely uses a _ _ manager.":
      "SECRETS",
  "In microservices, smoothing incoming load by delaying or dropping excess requests is _ _.":
      "THROTTLE",
};
