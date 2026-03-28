---
layout: log
title: "The Azure AI Foundry Lab I'd Actually Recommend"
date: 2026-03-04
summary: "A more realistic way to learn Foundry: deploy it, govern it, secure it, then write the runbook."
category: labs
tags: [azure-ai-foundry, rbac, governance, lab]
reading_time: "8 min"
id: log-2026-03-04-foundry-lab-recommended
---

Most Azure AI Foundry labs stop at deployment. You create a hub, deploy a model, run a prompt. Then the lab ends.

That is not where the interesting problems are.

## What the standard lab skips

Foundry is a governed platform. The default deployment gives you a working inference endpoint with no meaningful access controls, no audit trail, and default networking that accepts traffic from anywhere.

In a production context, that is a security incident waiting to happen.

## What I did instead

**Deploy with least-privilege RBAC from the start**

Foundry uses Azure RBAC roles that are not intuitive. `Azure AI Developer` lets users submit jobs and access deployments. `Azure AI Inference Deployment Operator` allows model deployment. `Cognitive Services OpenAI User` controls inference access.

Map these to actual use cases before assigning them. The default is Owner-or-nothing because it is easier. It is also wrong.

**Configure diagnostic settings before testing**

```bash
az monitor diagnostic-settings create \
  --name foundry-audit \
  --resource <foundry-hub-id> \
  --logs '[{"category":"Audit","enabled":true}]' \
  --workspace <log-analytics-workspace-id>
```

If you do not configure logging before you start testing, you have no audit trail for your test activity. The gap in logs looks identical to the gap that a real access control failure would produce.

**Test the boundaries, not just the happy path**

With RBAC configured, try to access the deployment as a user without the inference role. Verify the 403. Confirm the audit log captures the denied request.

This is the part most labs skip — validating that controls work, not just that they are configured.

## What this produces

A Foundry deployment with:

- Role assignments that map to actual job functions
- Diagnostic logging to Log Analytics before any inference traffic
- Verified access boundaries, not just assumed ones
- A runbook you can hand to the next operator

The lab itself is straightforward. The governance layer is where you learn something.
