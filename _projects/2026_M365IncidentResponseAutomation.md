---
layout: project
title: M365 Incident Response Automation
subtitle: Converting repeated account-compromise triage into an operator-friendly workflow.
status: active
build_status: in-progress
category_label: Incident Build
date: 2026-03-11
stack: PowerShell, Microsoft Graph, Entra ID, KQL
objective: Reduce triage and containment time for high-frequency account incidents by standardising first-response actions.
why: Repeated manual investigations were slow, inconsistent, and heavily dependent on who was on shift.
key_decision: Keep the workflow script-assisted instead of fully automatic so analysts can validate context before containment.
result: Early runs reduced first-action time and improved evidence consistency across cases.
next_iteration: Add controlled ticket integration and automatic timeline export.
---
## Build objective
Create a repeatable response flow for common account-compromise patterns across sign-in abuse, suspicious forwarding rules, and risky token behaviour.

## Why it mattered
The pain point was not lack of tooling. It was inconsistent execution under pressure. The same indicators were being checked in different orders with different output quality.

## Stack
- PowerShell orchestration for fast operator actions
- Microsoft Graph queries for identity and directory context
- KQL pivots for behaviour-level correlation

## Current status
In-progress and already useful for initial triage. The script is intentionally opinionated: it starts with high-signal checks and only expands scope when needed.
