---
layout: log
title: "AZ-104 Lab 05 — Implementing Intersite Connectivity"
date: 2026-03-29
summary: "VNet peering over the Microsoft backbone, Network Watcher for connectivity testing, and user-defined routes for traffic steering. Architecture, implementation, security observations, and evidence checklist."
category: labs
tags: [az-104, azure, networking, vnet-peering, udr]
reading_time: "12 min"
id: log-2026-03-29-az104-lab05-intersite-connectivity
series: az-104
series_title: "AZ-104 Lab Series"
series_order: 2
---

| | |
|---|---|
| **Certification Track** | AZ-104: Microsoft Azure Administrator |
| **Lab Reference** | AZ-104 Lab 05 — Microsoft Learning |
| **Skills Demonstrated** | VNet Peering, Network Watcher, UDRs, Custom Routing, Topology Design |
| **Azure Services Used** | Virtual Networks, Virtual Machines, Network Watcher, Route Tables |
| **Subscription** | Azure for Students |
| **Region** | Sweden Central |
| **Resource Group** | az104-rg5 |
| **Lab Reference Files** | [github.com/rookie0o9/labs/az104/lab05](https://github.com/rookie0o9/labs/tree/main/az104/lab05/) |

---

## 1. Objective

This lab addresses a common enterprise network segmentation requirement: enabling controlled communication between isolated virtual networks while maintaining clear security boundaries between them. The scenario models a real-world architecture where core IT services (DNS, security tooling) are segmented from operational departments — in this case, a manufacturing division — and need a defined, auditable connectivity path.

Specific outcomes delivered in this lab:

- Deploy virtual machines across two logically isolated virtual networks with non-overlapping address spaces
- Validate the pre-peering isolation state using Network Watcher diagnostics
- Establish bidirectional VNet peering with forwarded traffic enabled
- Confirm post-peering connectivity via PowerShell `Test-NetConnection`
- Implement a User-Defined Route (UDR) to steer traffic through a future Network Virtual Appliance (NVA) — a core pattern in hub-spoke security architectures

---

## 2. Architecture Overview

The lab implements a two-VNet flat peering topology with a custom routing layer applied to the core services network. The architecture is designed as a precursor to a full hub-spoke model, where the perimeter subnet and UDR represent the insertion point for a future NVA such as Azure Firewall.

### 2.1 Network Design

| Component | Configuration | Purpose |
|---|---|---|
| CoreServicesVnet | 10.0.0.0/16 — Subnets: Core (10.0.0.0/24), perimeter (10.0.1.0/24) | Simulates core IT — DNS, security services, shared infrastructure |
| ManufacturingVnet | 172.16.0.0/16 — Subnet: Manufacturing (172.16.0.0/24) | Simulates an operational department network requiring controlled access to core services |
| CoreServicesVM | Private IP: 10.0.0.4 — No public inbound ports | Target endpoint for cross-VNet connectivity tests |
| ManufacturingVM | Private IP: 172.16.0.4 — No public inbound ports | Source for connectivity tests; simulates workload requiring core service access |
| VNet Peering | Bidirectional — Connected status on both sides, forwarded traffic enabled both directions | Enables private backbone routing between VNets without gateway dependency |
| Route Table: rt-CoreServices | Route: PerimetertoCore — Dest: 10.0.0.0/16 → Next hop: Virtual Appliance (10.0.1.7) — Associated to: Core subnet | Enforces traffic steering through a future NVA for inspection before reaching core services |

### 2.2 Key Design Decisions

- **Non-overlapping address spaces** (10.0.0.0/16 vs 172.16.0.0/16) — a mandatory requirement for VNet peering; overlapping CIDRs prevent peering establishment
- **No public inbound ports on either VM** — all connectivity tested over private IPs, consistent with zero-trust network posture
- **Forwarded traffic enabled on both peering links** — required for any hub-spoke extension where traffic transits through a shared hub VNet
- **Propagate gateway routes set to No** on the route table — isolates UDR behaviour from any future VPN/ExpressRoute gateway influence
- **UDR next hop set to Virtual Appliance with a placeholder IP (10.0.1.7)** — the perimeter subnet is pre-staged for NVA insertion without requiring immediate deployment

---

## 3. Implementation — Task by Task

### Task 1 & 2: Virtual Network and VM Deployment

Both virtual machines were deployed with no public inbound ports, boot diagnostics disabled, and network configuration created inline with the VM — demonstrating the common deployment pattern where network infrastructure is provisioned as part of the compute workload rather than pre-staged separately.

> **Evidence to Capture**
>
> 1. Resource Group az104-rg5 Overview blade — all deployed resources visible in a single inventory view
> 2. CoreServicesVnet → Overview: address space 10.0.0.0/16, subnets listed
> 3. ManufacturingVnet → Overview: address space 172.16.0.0/16, subnets listed
> 4. Both VMs → Overview showing Running state, private IP addresses, and no public IP

### Task 3: Pre-Peering Isolation Validation (Network Watcher)

Network Watcher Connection Troubleshoot was used to confirm that the two VMs were unreachable from each other prior to peering. This is a critical before-state capture — it proves the lab started from a correct isolated baseline, not a pre-connected environment. Without this evidence, the peering result has no comparative context.

> **Evidence to Capture**
>
> 5. Network Watcher → Connection Troubleshoot result showing **Unreachable** (CoreServicesVM → ManufacturingVM, TCP 3389)
> 6. Network Watcher → Topology view showing two isolated VNets with no peering links

### Task 4: VNet Peering Configuration

A bidirectional peering was established from CoreServicesVnet to ManufacturingVnet. Azure automatically creates the reverse peering link, but each direction must be independently verified. Peering status must show **Connected** — Initiated or Disconnected states indicate a provisioning race condition or misconfiguration.

> **Evidence to Capture**
>
> 7. CoreServicesVnet → Peerings blade: CoreServicesVnet-to-ManufacturingVnet, Peering status: **Connected**
> 8. ManufacturingVnet → Peerings blade: ManufacturingVnet-to-CoreServicesVnet, Peering status: **Connected**
> 9. Peering detail view (click into the link): showing Allow forwarded traffic enabled on both directions

### Task 5: Post-Peering Connectivity Confirmation (PowerShell)

ManufacturingVM Run Command was used to execute `Test-NetConnection` against the CoreServicesVM private IP on TCP port 3389. `TcpTestSucceeded: True` confirms that peering is routing traffic correctly over the Microsoft backbone. The Run Command approach is also portfolio-relevant — it demonstrates the ability to execute diagnostics without RDP or bastion, which is important in environments where public endpoints are not exposed.

```powershell
Test-NetConnection -ComputerName 10.0.0.4 -Port 3389
```

> **Evidence to Capture**
>
> 10. ManufacturingVM → Run Command → RunPowerShellScript output showing **TcpTestSucceeded: True** with CoreServicesVM private IP as the remote address
> 11. Screenshot must show the VM name in the Azure portal breadcrumb to confirm which VM ran the test

### Task 6: User-Defined Route (UDR) — NVA Traffic Steering

A route table was created and a custom route added to redirect traffic destined for the core services address space (10.0.0.0/16) through a future NVA at 10.0.1.7 in the perimeter subnet. The route table was then associated with the Core subnet. This pattern is foundational to hub-spoke security architectures where Azure Firewall or a third-party NVA performs east-west traffic inspection between spokes.

> **Evidence to Capture**
>
> 12. rt-CoreServices → Routes blade: PerimetertoCore route — Destination: 10.0.0.0/16, Next hop type: Virtual appliance, Next hop: 10.0.1.7
> 13. rt-CoreServices → Subnets blade: association to CoreServicesVnet/Core subnet confirmed
> 14. CoreServicesVnet → Subnets blade: Core subnet showing Route table: rt-CoreServices in the Route table column
> 15. CoreServicesVnet → Subnets: perimeter subnet (10.0.1.0/24) visible — NVA insertion point pre-staged

---

## 4. Activity Log — Audit Trail

The Azure Activity Log provides timestamped, operation-level evidence of every resource provisioned and configured during this lab. This mirrors the audit trail generated in production environments and demonstrates change management awareness — a key competency in cloud security roles.

Navigation path: `az104-rg5 → Activity Log → filter to last 24 hours`

| Operation | Resource Type | Expected Result |
|---|---|---|
| Create or Update Virtual Network | Microsoft.Network/virtualNetworks | Succeeded — for both CoreServicesVnet and ManufacturingVnet |
| Create or Update Virtual Machine | Microsoft.Compute/virtualMachines | Succeeded — for CoreServicesVM and ManufacturingVM |
| Create or Update Virtual Network Peering | Microsoft.Network/virtualNetworks/virtualNetworkPeerings | Succeeded — two entries, one per peering link direction |
| Create or Update Route Table | Microsoft.Network/routeTables | Succeeded — rt-CoreServices |
| Create or Update Route | Microsoft.Network/routeTables/routes | Succeeded — PerimetertoCore route |
| Create or Update Subnet | Microsoft.Network/virtualNetworks/subnets | Succeeded — perimeter subnet and route table association |

Export the Activity Log as JSON or CSV via `Activity Log → Export Activity Logs`. The exported file provides machine-readable, timestamped proof of all operations — equivalent to a change record audit trail.

---

## 5. Security Observations

### 5.1 VNet Peering is Non-Transitive by Design

If a third VNet (VnetC) is peered with CoreServicesVnet, it cannot communicate with ManufacturingVnet through that peering — even though CoreServicesVnet has connectivity to both. Non-transitivity is a security feature, not a limitation. It enforces explicit peering relationships and prevents unintended lateral reachability. In hub-spoke architectures, this behaviour is deliberately exploited: all spoke-to-spoke traffic is forced through the hub (where inspection occurs) because there is no direct spoke-to-spoke peering.

### 5.2 UDRs Override System Routes — Precedence Matters

Azure automatically creates system routes for each subnet. A UDR associated to a subnet overrides matching system routes — including the default internet route (0.0.0.0/0) if a matching UDR is present. This means misconfigured UDRs can silently black-hole traffic or redirect it in unintended directions with no immediate error. In production, UDR changes should be treated as high-impact changes with pre/post connectivity validation built into the change process. The PerimetertoCore route in this lab is currently non-functional (NVA not deployed), which means traffic to 10.0.0.0/16 from the Core subnet would be dropped — an intentional design state that must be resolved before the NVA is live.

### 5.3 Network Watcher as the Primary Diagnostic Tool

Network Watcher Connection Troubleshoot operates at the control plane — it tests reachability without generating actual traffic between VMs. This is significant in security-sensitive environments where generating test traffic may be restricted. The tool evaluates NSG rules, routing tables, and peering state as part of its diagnostic chain, making it the correct first-response tool for connectivity issues in Azure before resorting to RDP or bastion-based testing. IP Flow Verify and Next Hop tools within Network Watcher are the logical next steps for deeper diagnosis.

### 5.4 Peering Directionality and Forwarded Traffic

The Allow forwarded traffic setting on a peering link controls whether traffic that was forwarded into a VNet from outside (i.e., not originating from that VNet) can traverse the peering. In practice, this setting is essential in hub-spoke topologies: without it enabled, traffic from a spoke that transits the hub cannot exit through the hub's peering to reach another spoke or on-premises network. Enabling it on both directions during peering setup is the correct default for any architecture that anticipates routing through NVAs or gateways.

---

## 6. Lab Extension — Recommended Next Steps

- Deploy Azure Firewall into the perimeter subnet (10.0.1.0/24) and update the UDR next hop to the Firewall's private IP — activating the NVA insertion pattern already scaffolded in this lab
- Add a Network Security Group to the Core subnet with explicit allow/deny rules and validate that NSG rules and UDRs interact correctly (UDRs route, NSGs filter — they operate independently)
- Enable Network Watcher Flow Logs on both VNets and route them to a Log Analytics Workspace — this produces the traffic visibility layer needed for Sentinel analytics rules
- Extend to a third VNet to demonstrate non-transitivity explicitly — peer VnetC with CoreServicesVnet and confirm ManufacturingVM cannot reach VnetC, then resolve via hub-spoke restructure
- Export Network Watcher Topology as an architecture diagram to supplement this case study

---

## Appendix: Evidence Checklist

| # | Evidence Item | Location in Portal | Captured |
|---|---|---|---|
| 1 | Resource Group az104-rg5 — full resource inventory | az104-rg5 → Overview | ☐ |
| 2 | CoreServicesVnet Overview — address space, subnets | Virtual Networks → CoreServicesVnet → Overview | ☐ |
| 3 | ManufacturingVnet Overview — address space, subnets | Virtual Networks → ManufacturingVnet → Overview | ☐ |
| 4 | CoreServicesVM — Running state, private IP, no public IP | Virtual Machines → CoreServicesVM → Overview | ☐ |
| 5 | ManufacturingVM — Running state, private IP, no public IP | Virtual Machines → ManufacturingVM → Overview | ☐ |
| 6 | Network Watcher — Pre-peering Unreachable result | Network Watcher → Connection Troubleshoot | ☐ |
| 7 | Network Watcher Topology — isolated VNets before peering | Network Watcher → Topology | ☐ |
| 8 | CoreServicesVnet Peerings — Connected status | CoreServicesVnet → Peerings | ☐ |
| 9 | ManufacturingVnet Peerings — Connected status | ManufacturingVnet → Peerings | ☐ |
| 10 | Peering detail — forwarded traffic settings | Click into peering link → Configuration | ☐ |
| 11 | PowerShell Run Command — TcpTestSucceeded: True | ManufacturingVM → Run Command | ☐ |
| 12 | Route Table — PerimetertoCore route details | rt-CoreServices → Routes | ☐ |
| 13 | Route Table — Subnet association confirmed | rt-CoreServices → Subnets | ☐ |
| 14 | Activity Log — all operations Succeeded | az104-rg5 → Activity Log | ☐ |
| 15 | Activity Log export — JSON/CSV file | Activity Log → Export Activity Logs | ☐ |
