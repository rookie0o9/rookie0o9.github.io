---
layout: log
title: "When the Service Connection Fails on Management Group Read"
date: 2026-03-01
summary: "A troubleshooting log on Azure authorization failure, management group scope, and what these errors reveal about permission design."
category: ops
tags: [azure, rbac, troubleshooting, field-note]
reading_time: "4 min"
id: log-2026-03-01-service-connection-mg-read
---

Azure DevOps pipeline. Terraform plan stage. The service connection fails with a 403 on a management group read.

```
Error: authorization failed (Status 403)
│ Caller does not have permission to perform action
│ on scope /providers/Microsoft.Management/managementGroups/...
```

This is a permissions problem with a specific shape.

## What the error reveals

The service principal behind the service connection has Reader access at subscription scope but nothing at management group scope. Management group operations require explicit role assignment at the MG level — subscription-scoped roles do not inherit upward.

This is not obvious from the Azure RBAC documentation unless you already know the management group scope behaves differently from other resource hierarchies.

## The fix

Assign the service principal `Management Group Reader` at the relevant management group scope:

```bash
az role assignment create \
  --assignee <service-principal-id> \
  --role "Management Group Reader" \
  --scope "/providers/Microsoft.Management/managementGroups/<mg-id>"
```

Scope the assignment to the highest group the pipeline needs to read. If the Terraform config traverses the full hierarchy, assign at the root tenant management group.

## What this reveals about permission design

The failure mode is common: roles are assigned at the scope where resources live, but operations that traverse the hierarchy need scope-appropriate assignments.

When designing service principal permissions for IaC pipelines:

- Map the full scope of read operations the plan phase will perform, not just write operations
- Management group reads, policy reads, and subscription enumeration all require explicit scoping
- Principle of least privilege applies to plan as well as apply — read-only is still an attack surface

The 403 on plan is better than a misconfigured apply. Treat it as a design check, not just an error to clear.
