---
layout: log
title: "AZ-104 Lab 04 — Implementing Virtual Networking in Azure"
date: 2026-03-28
summary: "Four tasks, two networks, one security boundary, two DNS scopes. Building the address space, security group, and DNS foundations that every subsequent Azure architecture sits on."
category: labs
tags: [az-104, azure, networking, nsg, dns]
reading_time: "6 min"
id: log-2026-03-28-az104-lab04-virtual-networking
series: az-104
series_title: "AZ-104 Lab Series"
series_order: 1
---

Lab 04 of three. This is the foundational networking lab in the AZ-104 track. Four discrete tasks: building VNets via the portal, deploying a second via ARM template, configuring Application and Network Security Groups, and managing both public and private DNS zones.

Not glamorous. But everything in Azure eventually sits on top of this.

## The scenario

A global organisation needs two virtual networks — one sized for core services growth, one for IoT device connectivity across manufacturing sites:

| Network | CIDR | Purpose |
|---|---|---|
| CoreServicesVnet | 10.20.0.0/16 | Shared services, database tier |
| ManufacturingVnet | 10.30.0.0/16 | IoT sensor mesh |

The design principle to carry forward: **non-overlapping address spaces across cloud and on-premises**. Overlapping ranges become a troubleshooting tax you pay indefinitely.

## Task 1 — Manual VNet build via portal

CoreServicesVnet goes in first through the portal. Two subnets:

- `SharedServicesSubnet` — 10.20.10.0/24
- `DatabaseSubnet` — 10.20.20.0/24

The key habit built here is not clicking through the wizard — it is **exporting the resource template** after creation. Azure generates an ARM JSON you can adapt for the next deployment. This is where the portal stops being a click-ops tool and starts becoming a template generator.

> Every subnet loses five addresses to Azure reservations before you allocate a single workload. Plan address space accordingly.

## Task 2 — Template-driven deployment

The exported template from Task 1 gets modified to produce ManufacturingVnet:

- `SensorSubnet1` — 10.30.20.0/24
- `SensorSubnet2` — 10.30.21.0/24

The modification is surgical: swap address prefixes and resource names, redeploy. This is the lab's quiet argument for infrastructure-as-code — the second network costs almost no mental effort once the first is captured as a template.

## Task 3 — NSGs and Application Security Groups

Two security constructs, and the distinction matters.

**Application Security Group (ASG)** — `asg-web`
A logical tag applied to resources with a shared function. No IP ranges involved. ASGs let you write NSG rules that reference application tiers rather than addresses.

**Network Security Group (NSG)** — `myNSGSecure`
Contains the actual allow/deny rules. Custom inbound rules permit ASG-tagged traffic on ports 80 and 443. A custom outbound rule denies internet access.

```
Inbound:  Allow ASG asg-web → ports 80, 443
Outbound: Deny Internet
```

Rules evaluate in priority order — lower number wins. The default outbound internet allow sits at priority 65001. A custom deny at 65000 overrides it without touching the default rule.

The separation that matters operationally: ASGs handle *who*, NSGs handle *what*. Reuse the ASG reference across multiple rules without managing IP lists.

## Task 4 — DNS: public and private zones

**Public DNS zone** — `contoso.com`

Created in Azure DNS. Azure provides four nameservers; you delegate the domain at your registrar. Standard A, AAAA, CNAME records resolve publicly.

```shell
nslookup contoso.com <azure-nameserver>
```

**Private DNS zone** — `private.contoso.com`

Linked exclusively to a virtual network. No public resolution. Records in this zone are invisible outside the linked VNet — correct behaviour for internal service discovery, not a gap to close with a firewall rule.

The operational split: public zones handle external identity, private zones handle internal name resolution without leaking topology.

## What this lab actually builds

Four tasks, two networks, one security boundary, two DNS scopes. The value is in understanding how they compose:

- VNets segment the address space
- Subnets divide VNets into functional tiers
- NSGs enforce traffic policy at the subnet or NIC level
- ASGs abstract policy targets away from IP management
- Private DNS makes service discovery portable without hardcoded addresses

This is the substrate every subsequent Azure architecture sits on. Getting address planning and security group model right here avoids re-architecting under load later.
