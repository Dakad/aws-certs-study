# Lab 02 — Isolated network reachability, ALB health, and Flow Logs

**Exam domain:** [5. Networking and Content Delivery](../../../domains/05-networking-content-delivery/README.md) (18%), with a [Domain 2.2](../../../domains/02-reliability-business-continuity/02-task-2-2-high-availability-resilience.md) overlap on ALB health checks
**Task guides:** [5.1 Networking and connectivity](../../../domains/05-networking-content-delivery/01-task-5-1-networking-connectivity.md), [5.3 Network troubleshooting](../../../domains/05-networking-content-delivery/03-task-5-3-network-troubleshooting.md)
**Knowledge nodes:** [Elastic Load Balancing](../../services/elb/README.md), [CloudWatch](../../services/cloudwatch/README.md)
**Status:** Not yet run

## Why this lab exists

The Domain 5 checks are the ones the learner has never attempted, and networking is a stated weaker area. They also share a trap with Domain 1 and Domain 2: an HTTP 503 does not tell you which component produced it. This lab makes the producing component controllable, so the question has a knowable answer instead of a guess.

Everything lives in one purpose-built VPC. Nothing routes to the internet except the load balancer, and there is no NAT gateway — see the cost table.

## Objective

By the end you can:

1. Trace a request through DNS → route → security group → NACL → listener → target group → target, and name the evidence available at each hop.
2. Distinguish `HTTPCode_ELB_5XX_Count` from `HTTPCode_Target_5XX_Count` and say which one fires here.
3. Say what VPC Flow Logs can and cannot prove, using the actual fields this lab produces.
4. Explain why "the ALB is reachable" does not mean "the request succeeded".

## Design

The lab makes the 503 deterministic:

- A target group holds one **registered IP target that has nothing listening on it** — a real, healthy-looking registration that can never pass a health check.
- The listener's default action is a **fixed response of 503**. With no healthy targets, the ALB serves that fixed response.
- The learner can therefore prove where the 503 came from, then flip one thing and watch the source change.

`HTTPCode_ELB_5XX_Count` counts the fixed-response 503s. `HTTPCode_Target_5XX_Count` stays at zero, because no target ever ran. Reading only one of those two metrics is exactly the mistake the Domain 1 and Domain 5 checks are built to catch.

## Safety, scope, and cost

| Item | Note |
|---|---|
| Scope | The authorized playground (`sso-apptweakplayground-admin`) or a personal account. Never a shared or production AppTweak account. |
| CIDR | `10.60.0.0/16`. Chosen to be obviously outside the learner's other work. Confirm nothing in the account already uses it. |
| **NAT gateway** | **Deliberately absent.** At roughly $0.045/hour plus $0.045/GB it is the single most common way a networking lab generates an unexpected bill. Nothing in this lab needs outbound internet from a private subnet. |
| Application load balancer | Roughly $0.0225/hour, so about **$0.55/day**. This is the dominant cost. Delete it the day you finish. |
| EC2 instances | **None.** The unhealthy target is an IP registration, not an instance. Compute cost is zero. |
| VPC, subnets, IGW, route tables | No charge. |
| VPC Flow Logs to CloudWatch Logs | Per GB ingested. Minutes of test traffic is a fraction of a cent. |
| Expected total | Under $0.75/day, and roughly $0.25 of that on the day you finish. |

## Sequence

### Step 0 — Verify identity and region, and check the CIDR is free

```bash
aws sts get-caller-identity
aws ec2 describe-vpcs --filters Name=cidr,Values=10.60.0.0/16 \
  --query 'Vpcs[].VpcId' --output text
```

An empty result is what you want. A non-empty result means pick a different CIDR in the script's `VPC_CIDR` variable before creating anything.

### Step 1 — Create

```bash
AWS_PROFILE=sso-apptweakplayground-admin ./cli/01-create.sh
```

Read the script before running it. It creates the VPC, two subnets in different AZs, an internet gateway, a route table, an ALB with a security group, a target group with an unreachable IP target, a fixed-response 503 default action, and VPC Flow Logs to a CloudWatch log group.

### Step 2 — Generate traffic and read the evidence

Generate requests from the learner's machine, then compare four sources:

```bash
./cli/02-probe.sh
```

| Source | What it shows | What it cannot show |
|---|---|---|
| `curl -i` response headers | Which component answered, via `server: awselb/2.0` and the request ID | Whether the target was ever tried |
| ALB access logs | Per-request target-group outcome, chosen target, processing time | Application-internal errors |
| `HTTPCode_ELB_5XX_Count` | The ALB itself generated the 503 | Whether a target was healthy |
| `HTTPCode_Target_5XX_Count` | A target generated the error | Anything about ALB-generated errors |
| VPC Flow Logs | Which ENIs carried the flow, and accept/reject at the NACL layer | HTTP status, headers, body, or which target group was used |

The two 5xx metrics are the core of this lab. Establish whether the target group has a healthy target, and you can predict which metric will move.

### Step 3 — Optional: break the return path with a NACL

This is the Domain 5 stateless-filter trap, done deliberately rather than by accident. Create a network ACL that allows inbound on 80 but **denies the ephemeral return range** (32768–60999 on TCP). The connection establishes from the client's point of view, then stalls.

Then state, before checking anything: which of the five evidence sources above would show this, and which would look completely normal? Flow Logs show `ACCEPT` on ingress and the connection exists; they do not tell you the reply never came back. Predict first, then verify.

### Step 4 — Optional: replace the IP target with a real instance

Only if the ALB is still running. A `t4g.micro` with an HTTP server in a public subnet adds roughly $0.28/day, and it flips the default action off, so `HTTPCode_Target_5XX_Count` becomes the meaningful metric instead. The comparison between the two setups is worth more than the $0.28.

## Evidence to record

Copy into [EVIDENCE.md](EVIDENCE.md). Redact account IDs; never record ARNs or the account number.

- The `server:` header and request ID from a failing `curl -i`.
- Access-log line for one failing request, with the `target_group` and `elb_status`/`target_status` fields.
- `HTTPCode_ELB_5XX_Count` and `HTTPCode_Target_5XX_Count` values at the same timestamp.
- Two Flow Log fields you can read and one thing you still cannot determine.
- Your Step 3 prediction, written before you looked.
- Teardown output showing the verification queries returned nothing.

## Cleanup risk if interrupted

```bash
aws elbv2 describe-load-balancers --names soa-c03-lab02-alb \
  --query 'LoadBalancers[].LoadBalancerArn' --output text
aws ec2 describe-vpcs --filters Name=cidr,Values=10.60.0.0/16 \
  --query 'Vpcs[].VpcId' --output text
```

The load balancer is the cost-bearing resource. Delete it first even if the VPC deletion will eventually cascade.
