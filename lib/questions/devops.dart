// DevOps Q&A
const Map<String, String> qDevOps = {
  "In DevOps, the distributed version control system widely used to track changes and collaborate via branches and pull requests is _ _.":
      "GIT",
  "In DevOps, the CI server that automates builds, tests, and deployments using jobs and declarative pipelines is _ _.":
      "JENKINS",
  "In DevOps, the practice of automatically building and testing every change to catch defects early is _ _.":
      "CI",
  "In DevOps, the practice of frequently shipping deployable changes to reduce release risk is _ _.":
      "CD",
  "In DevOps, the IaC tool that uses HCL to define infrastructure and apply plans to create or change resources is _ _.":
      "TERRAFORM",
  "In DevOps, the configuration management tool that uses YAML playbooks and SSH to push idempotent changes is _ _.":
      "ANSIBLE",
  "In DevOps, the container platform that packages apps with dependencies into lightweight, isolated images is _ _.":
      "DOCKER",
  "In DevOps, the container orchestrator that schedules pods and manages services is _ _.":
      "K8S",
  "In observability, the signal that tracks numeric time‑series like latency, CPU, and throughput is _ _.":
      "METRICS",
  "In observability, the signal that traces requests across services to aid root‑cause analysis is _ _.":
      "TRACING",
  "In observability, the signal that records event messages and errors for later analysis is _ _.":
      "LOGGING",
  "In monitoring, the dashboard tool that visualizes metrics, panels, and alerts for systems is _ _.":
      "GRAFANA",
  "In DevOps, the code quality platform that scans code in CI to detect bugs and code smells is _ _.":
      "SONARQUBE",
  "In DevOps, the scripted sequence that builds, tests, and deploys software automatically is a _ _.":
      "PIPELINE",
  "In release strategies, shifting a small percentage of traffic to a new version to reduce risk is _ _.":
      "CANARY",
  "In release strategies, running two identical environments and switching traffic when ready is _ _.":
      "BLUEGREEN",
  "In releases, the process of restoring a previous version after a failed deployment is a _ _.":
      "ROLLBACK",
  "In DevOps, the small, versioned package produced by a build and later deployed is an _ _.":
      "ARTIFACT",
  "In DevOps, the centralized store for versioned images or packages used by CI/CD is a _ _.":
      "REGISTRY",
  "In DevOps, managing servers and networks as code in version control is _ _.":
      "IAC",
  "In DevOps, the human‑readable data format that commonly defines CI pipelines and configs is _ _.":
      "YAML",
  "In DevOps, the mechanism that provides sensitive configuration like tokens and keys at runtime, not in code, is _ _.":
      "SECRETS",
  "In architecture, the principle where services keep no local state so they can scale horizontally is _ _.":
      "STATELESS",
  "In operations, automatically increasing or decreasing replicas based on load is _ _.":
      "AUTOSCALE",
  "In releases, the quick, critical‑path verification after deployment to ensure basics work is a _ _.":
      "SMOKETEST",
  "In incident culture, focusing on learning and avoiding assigning fault to individuals is _ _.":
      "BLAMELESS",
  "In reliability, the role that applies engineering to reliability using SLOs, error budgets, and automation is _ _.":
      "SRE",
  "In reliability, the target that defines the acceptable level for a service’s behavior is _ _.":
      "SLO",
  "In reliability, the agreement that formalizes customer‑facing reliability and support commitments is _ _.":
      "SLA",
  "In recovery, the metric that limits acceptable data loss during an outage is _ _.":
      "RPO",
  "In recovery, the metric that limits maximum acceptable downtime to restore service is _ _.":
      "RTO",
  "In infrastructure, the approach that favors replacing over patching by keeping images and servers unchangeable is _ _.":
      "IMMUTABLE",
  "In version control, the branching model that uses long‑lived develop/release branches and structured workflows is _ _.":
      "GITFLOW",
  "In releases, the versioning scheme that uses MAJOR.MINOR.PATCH to signal compatibility is _ _.":
      "SEMVER",
  "In CI, the step that enforces coding rules and catches simple issues automatically is _ _.":
      "LINTING",
  "In policy, the engine that lets you enforce guardrails as code across pipelines and clusters is _ _.":
      "OPA",
  "In builds, the file that pins exact dependency versions to ensure reproducible builds is a _ _.":
      "LOCKFILE",
  "In Kubernetes, the resource that routes external HTTP traffic to services inside the cluster is _ _.":
      "INGRESS",
  "In Kubernetes, the probe that indicates an app is ready to receive traffic is _ _.":
      "READINESS",
  "In Kubernetes, the pod pattern that adds a helper container for tasks like proxies or log shipping is _ _.":
      "SIDECAR",
  "In microservices, the service mesh that provides mTLS, traffic control, and observability is _ _.":
      "ISTIO",
  "In CI/CD, the HTTP callback mechanism that triggers pipelines when repository events occur is a _ _.":
      "WEBHOOK",
  "In CI, the worker process that executes jobs on behalf of the server is a _ _.":
      "RUNNER",
  "In security, the tool that securely stores tokens, keys, and dynamic credentials for apps is _ _.":
      "VAULT",
  "In testing, the fast test type that verifies small units of code in isolation during CI is _ _.":
      "UNIT",
  "In Kubernetes, the package manager that installs versioned charts with templating is _ _.":
      "HELM",
  "In environments, the label that typically refers to the system serving real users is _ _.":
      "PROD",
  "In Kubernetes, the fields that cap CPU and memory per container to protect nodes are _ _.":
      "LIMITS",
  "In security, the CI scan that analyzes source code to find vulnerabilities early is _ _.":
      "SAST",
  "In infrastructure, the tool that builds immutable machine images from scripts and provisioners is _ _.":
      "PACKER",
  "In logging pipelines, the tool that ingests, transforms, and ships logs to backends is _ _.":
      "LOGSTASH",
  "In Kubernetes, the object that stores non‑secret key–value config for pods is _ _.":
      "CONFIGMAP",
  "In twelve‑factor apps, the practice that keeps configuration in environment variables is _ _.":
      "ENVVARS",
  "In monitoring, the rule that notifies humans when metrics cross critical thresholds is _ _.":
      "ALERTS",
  "In incident response, the practice that rotates responsibility for responding to pages and incidents is _ _.":
      "ONCALL",
  "In incident management, the SaaS that manages paging workflows and on‑call rotations is _ _.":
      "PAGERDUTY",
  "In Kubernetes, the smallest deployment unit that groups one or more containers is a _ _.":
      "POD",
  "In resilience, the retry strategy that increases wait time between attempts to reduce load is _ _.":
      "BACKOFF",
  "In Kubernetes, the resource that exposes a set of pods via a stable virtual IP is _ _.":
      "SERVICE",
  "In testing, the test type that validates the full user workflow across components and systems is _ _.":
      "E2E",
};
