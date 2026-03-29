---
layout: log
title: "AZ-104 Lab 05 — Implementing Intersite Connectivity"
date: 2026-03-29
summary: "VNet peering over the Microsoft backbone, Network Watcher for connectivity testing, and user-defined routes for traffic steering. Plus: the Terraform extracted from the deployed resources."
category: labs
tags: [az-104, azure, networking, vnet-peering, udr]
reading_time: "7 min"
id: log-2026-03-29-az104-lab05-intersite-connectivity
series: az-104
series_title: "AZ-104 Lab Series"
series_order: 2
---

Lab 05. Three problems, three tools: VNet isolation, peering to fix it, and user-defined routes to control it.

This lab also builds evidence — the Terraform was extracted from the deployed resources and is [stored in the lab reference repo](https://github.com/rookie0o9/rookie0o9.github.io/tree/main/labs/az104/lab05/).

## The topology

Two VNets in separate address spaces:

| VNet | CIDR | VM | Private IP |
|---|---|---|---|
| CoreServicesVnet | 10.0.0.0/16 | CoreServicesVM | 10.0.0.4 |
| ManufacturingVnet | 172.16.0.0/16 | ManufacturingVM | 172.16.0.4 |

CoreServicesVnet has two subnets: `Core` (10.0.0.0/24) and `perimeter` (10.0.1.0/24). The perimeter subnet is where a future NVA would sit — relevant to Task 6.

## Task 1 & 2 — Deploy the VMs

Both VMs deployed via ARM template into their respective VNets. The Terraform extracted afterwards shows what Azure actually provisioned: two `azurerm_windows_virtual_machine` resources (Windows Server 2025), two NICs, two NSGs with no custom rules, a route table, and the two VNets.

Note: the lab instructions use East US as the region. These were deployed to Sweden Central — the Terraform reflects the actual state, not the guide defaults.

## Task 3 — Network Watcher: verify the failure

Network Watcher's Connection Troubleshoot runs a probe from CoreServicesVM to ManufacturingVM's private IP. Result: unreachable.

This is the expected outcome. **VNets are isolated by default.** Resources in different virtual networks cannot communicate through Azure's fabric unless you explicitly connect them. The probe establishes the baseline before peering.

## Task 4 — VNet Peering

Bidirectional peering configured between CoreServicesVnet and ManufacturingVnet. Key settings:

- Traffic to remote VNet: **allowed**
- Traffic forwarded from remote VNet: **allowed**
- Gateway transit: not configured (no VPN gateway in this lab)

Peering uses Microsoft's private backbone — traffic between peered VNets does not traverse the public internet. Latency is low and bandwidth is constrained only by the VM SKU, not the peering link itself.

Two peering links are created: one in each direction. This is easy to miss in the portal — peering is not a single symmetric object, it is two directional links that must both be in a `Connected` state before traffic flows.

## Task 5 — Validate connectivity

With peering in place, re-run the connection test via PowerShell on ManufacturingVM:

```powershell
Test-NetConnection -ComputerName 10.0.0.4 -Port 3389
```

`TcpTestSucceeded: True`. The path is open. Private IP reachable across VNets over the Microsoft backbone.

## Task 6 — User-Defined Routes

This task introduces the mechanism for overriding Azure's system routes.

A route table `rt-CoreServices` is created with a single route:

```
Name:           PerimetertoCore
Address prefix: 10.0.0.0/16
Next hop type:  VirtualAppliance
Next hop IP:    10.0.1.7
```

The route table is associated with the `perimeter` subnet. Any traffic destined for `10.0.0.0/16` that enters the perimeter subnet will be redirected to `10.0.1.7` — the IP where an NVA (firewall, IDS, etc.) would sit — rather than going directly to the destination.

The NVA at `10.0.1.7` does not exist in this lab. The route table is the declaration of intent: traffic must pass through an inspection point. In a production design, that IP would be a Network Virtual Appliance or Azure Firewall.

## What the Terraform tells you

The extracted `main.tf` captures the complete post-lab resource state:

- `azurerm_virtual_network.res-9` — CoreServicesVnet with both subnets, `Core` subnet already referencing `azurerm_route_table.res-8`
- `azurerm_route_table.res-8` — `rt-CoreServices` with the UDR to `10.0.1.7`
- `azurerm_network_security_group` resources — both NSGs with empty `security_rule = []`, consistent with the default-rules-only state after the lab
- `bgp_route_propagation_enabled = false` on the route table — this prevents BGP routes from a VPN gateway overriding the custom UDR, a deliberate hardening decision

One thing the Terraform does not capture: the VNet peering itself. Peering is a child resource of the VNet and was not included in the export. The `virtualNetworkPeerings: []` in the ARM templates confirms the starting state — post-lab the peerings exist in Azure but are not reflected in the files here.

## The routing logic in full

```
ManufacturingVM (172.16.0.4)
  → [peering link]
    → CoreServicesVnet
      → if destination is 10.0.0.0/16 and entering perimeter subnet:
          → redirect to NVA at 10.0.1.7   [UDR]
      → if destination is 10.0.0.0/16 and entering Core subnet:
          → route directly                 [system route]
```

Peering opens the path. UDRs shape it.
