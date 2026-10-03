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

- Status: Learning — account reconnaissance and first load-balancer discussion; no troubleshooting lab or independent assessment yet
- Evidence: Read-only inventory found the playground's default VPC and public-subnet layout. This is reconnaissance, not proof of independent mastery. On 2026-09-28, asked how ALB and NLB differ by OSI layer and protocol; noted no prior hands-on ALB experience.
- Concepts introduced: Elastic Load Balancing (ELB) is the AWS load-balancing service/family. Application Load Balancer (ALB) operates at Layer 7 and understands HTTP(S) requests, enabling host/path/header-aware routing. Network Load Balancer (NLB) operates primarily at Layer 4 and forwards connections/flows; listeners support transport options including TCP, TLS, UDP, and TCP_UDP. “TCP vs HTTP” is not an either/or at the same layer: HTTP is an application protocol carried over a transport. SSH/FTP are application protocols commonly carried over TCP; DNS commonly uses UDP and can also use TCP.
- Strengths observed: Connected load-balancer selection to layer/protocol and asked whether state, user geography, AZ resilience, and transfer cost affect the design.
- ALB health behavior introduced (2026-09-28): With at least one healthy target, ALB routes to healthy targets. If every registered target in a target group is unhealthy, ALB **fails open** and routes to all registered targets regardless of health. If the group has no registered targets (or only unused targets), ALB can return HTTP 503. Therefore “all targets unhealthy” and “no usable targets registered” are distinct cases.
- Health-check vs scaling distinction: ALB health checks affect routing; they do not imply that an Auto Scaling group exists. An appropriately configured Auto Scaling group can replace unhealthy EC2 instances, but replacement is a separate mechanism.
- Learner's answer (2026-09-28): “drop the request or send a 5xx or something like 'upstream not available".” This was **partly right**, not simply wrong: HTTP 503/upstream-unavailable can occur when there are no registered/usable targets. The missing distinction was that when all registered targets are unhealthy, ALB fails open and still forwards traffic to them; an error could then come from a target, but ALB does not return 503 solely because every registered target failed health checks. Tutor correction: my previous response framed this too bluntly and failed to credit the valid 5xx case.
- Follow-up: Check that the learner can distinguish (a) every registered target unhealthy from (b) an empty/unused target group.
- Phase 0 diagnostic baseline (2026-10-03): 3/4. Correctly selected the reachability layers to investigate after DNS succeeds but TCP times out, ALB for host/path routing, and NAT Gateway for private-subnet egress. Correction: security groups are stateful and network ACLs are stateless; NACL return traffic requires explicit inbound and outbound rules.
- Next action: For a website routing `/api` and `/web` to different target groups, choose a load-balancer type and explain which request information it must inspect.
