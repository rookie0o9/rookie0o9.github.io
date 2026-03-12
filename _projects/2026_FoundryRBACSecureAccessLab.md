---
layout: project
title: Foundry RBAC + Secure Access Lab
subtitle: Practical role boundaries and least-privilege access patterns in a controlled lab.
status: active
build_status: planned
category_label: Access Control Build
date: 2026-02-24
stack: Microsoft Security Stack, Entra RBAC, Policy Simulation
objective: Validate role design and secure-access patterns before promoting changes to production-facing environments.
why: Permission design mistakes are cheap in a lab and expensive in production.
key_decision: Model access on task-scoped operational roles instead of broad admin umbrellas.
result: Draft role matrix identified over-privileged paths and cleaner escalation boundaries.
next_iteration: Add scenario-driven test scripts for incident, support, and deployment roles.
---
## Build objective
Design and test least-privilege role boundaries with clear escalation routes.

## Why it mattered
Access models often grow from convenience. This lab forces role intent to be explicit and testable.

## Stack
- Role mapping and policy simulation
- Controlled scenario testing
- Audit-first validation of role outcomes

## Current status
Planned baseline is complete. Next phase is scripted scenario validation.
