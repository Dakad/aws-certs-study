# Domain 5 — Networking and Content Delivery

**Exam weight:** 18% of scored content  
**Status:** Learning  
**Official objective:** [AWS Domain 5 guide](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain5.html) (scope checked 2026-10-03)

## What this domain is about

Build and optimize network paths, deliver applications through DNS/CDN services, and investigate connectivity failures from evidence. A useful troubleshooting habit is to trace the complete path—name resolution, addressing, routes, gateways, security controls, listener/application, and return traffic—instead of guessing at one component.

## Official task areas and study guides

| Official task | What to study | Task guide |
|---|---|---|
| **5.1 — Implement and optimize networking features and connectivity** | VPC components, private connectivity, network-protection services, and network architecture cost. | [Networking and connectivity](01-task-5-1-networking-connectivity.md) |
| **5.2 — Configure domains, DNS services, and content delivery** | Route 53 Resolver and routing policies/query logs; CloudFront and Global Accelerator. | [DNS and content delivery](02-task-5-2-dns-content-delivery.md) |
| **5.3 — Troubleshoot network connectivity issues** | VPC, hybrid, and private connectivity; VPC Flow Logs and service logs; cache failures and CloudWatch network monitoring. | [Network troubleshooting](03-task-5-3-network-troubleshooting.md) |

Use the [Domain 5 contexts index](contexts/README.md) for reusable topologies and incident scenarios. The task guides provide practice and checks; learner results remain in the progress notes below and [`PROGRESS.md`](../../../PROGRESS.md).

## Services

The service list follows the [official Domain 5 objectives](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain5.html); examples are exam-scope coverage, not an exhaustive AWS catalog.

- **VPC connectivity:** VPCs, subnets, route tables, network ACLs, security groups, NAT gateways, internet gateways, egress-only internet gateways, VPC endpoints, AWS PrivateLink, VPC peering, and transit gateways.
- **Network protection:** Route 53 Resolver DNS Firewall, AWS WAF, AWS Shield, and AWS Network Firewall.
- **DNS and distribution:** Amazon Route 53 (including Resolver, routing policies, and query logging), Amazon CloudFront, and AWS Global Accelerator.
- **Troubleshooting and telemetry:** VPC Flow Logs, Elastic Load Balancing access logs, WAF web ACL logs, CloudFront logs, container logs, and CloudWatch network monitoring services.

### Cross-service impacts

Network reachability and security rules affect compute, databases, and private service access; load balancers and DNS health/routing choices also shape availability and recovery (see [Domain 2](../02-reliability-business-continuity/README.md)). Network logs complement application and infrastructure signals during incident investigation (see [Domain 1](../01-monitoring-logging-analysis-remediation-performance-optimization/README.md)). Provisioning must account for subnet sizing, routes, and policy dependencies (see [Domain 3](../03-deployment-provisioning-automation/README.md)), while IAM and network-protection controls enforce different security boundaries (see [Domain 4](../04-security-compliance/README.md)).

## Learning targets

- Distinguish public/private subnet behavior from subnet names; reason from route tables and address assignment.
- Explain the stateful behavior of security groups versus stateless network ACL rules and check both directions of a flow.
- Trace DNS, routing, filtering, target/listener, and return-path evidence in a deliberate order.
- Interpret flow/log records carefully and distinguish “not observed” from “proven impossible.”
- Understand content caching, origin behavior, DNS routing, and private connectivity at an operational level.

## Practice and evidence

- **CLI:** inspect VPC, subnet, route, SG/NACL, DNS, and flow-log configuration; build only in an isolated lab VPC.
- **Console:** visually trace resource associations and compare them with CLI output.
- **IaC:** recreate a small network from configuration; use plans to see graph/dependency effects and verify teardown.
- **Demonstrated when:** solve a fresh connectivity incident from the available evidence, explain each test's purpose, and identify what remains uncertain.

### Progress notes

- **Status:** Learning. Read-only reconnaissance and introductory load-balancer discussion completed; no troubleshooting lab or independent assessment yet.
- **Durable evidence:** Identified reachability layers after DNS succeeds but TCP times out, ALB for host/path routing, and NAT Gateway for private-subnet egress.
- **Next study:** Trace a fresh reachability incident from evidence, then complete a safe isolated networking lab.
