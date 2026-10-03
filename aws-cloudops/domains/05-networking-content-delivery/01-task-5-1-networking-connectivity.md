---
title: Task 5.1 - Networking and connectivity
domain: 5
official_task: 5.1
last_verified: 2026-10-03
sources:
  - title: AWS SOA-C03 Content Domain 5
    url: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain5.html
---

# Task 5.1 — Networking and connectivity

**Official skills:** 5.1.1 VPCs, subnets, routes, NACLs, security groups, NAT/IGW/egress-only IGW; 5.1.2 endpoints, PrivateLink, peering; 5.1.3 audit DNS Firewall, WAF, Shield, Network Firewall; 5.1.4 optimize network architecture cost.

## Study / do

- Draw source/destination/protocol/port and forward/return routes. Mark stateless NACL rules and stateful security-group behavior.
- Compare internet gateway, NAT egress, VPC endpoint, PrivateLink, and peering paths: scope, reachability, and remaining dependencies.
- Classify DNS filtering, HTTP filtering, network inspection, and DDoS protection by what each observes.
- Map byte paths across AZs/Regions, NAT, endpoints, and edge services before comparing cost alternatives.

## Check

A private EC2 instance resolves a public name but cannot reach HTTPS. Order checks for DNS answer, route, NAT/endpoint, SG, NACL return path, and target. Name a tool/log that narrows the issue and what it cannot prove.

**Look for:** DNS and IP reachability are separate; verify the actual selected route and both sides of stateless filters before changing controls.
