---
layout: log
title: "Building a Credible Terraform Delivery Backbone in Azure DevOps"
date: 2026-03-12
summary: "How I am building Q1 around repo structure, remote state, workload identity, and validation-first delivery."
category: labs
tags: [terraform, azure-devops, delivery, q1]
reading_time: "7 min"
id: log-2026-03-12-terraform-backbone
---

What I wanted at the start of Q1 was a Terraform workflow that survives contact with real delivery — not a clean lab setup that falls apart when a second engineer touches it.

This is what I built toward.

## The problem with starting clean

Most Terraform getting-started guides produce something that works once, locally, with one person. State is local. Credentials are a service principal secret in a `.env` file. There is no review step. Plan and apply run in the same command.

Fine for learning. Not a delivery baseline.

## The four decisions that matter

**1. Remote state with access controls**

State lives in Azure Blob Storage with versioning, soft-delete, and RBAC-only access. No access keys. No local state files. State locking is automatic via blob leases.

See: [Azure Blob Remote State Done Properly](/logs/2026-03-07-blob-remote-state/)

**2. Workload identity federation**

No client secrets in the pipeline. The Azure DevOps service connection authenticates via federated identity. No rotation, no leakage surface, full audit trail on every token request.

See: [Why WIF Beats Secrets in Terraform Pipelines](/logs/2026-03-10-wif-over-secrets/)

**3. Plan before apply, always**

The pipeline runs `terraform plan` and saves the plan file as an artefact. Apply is a separate stage that consumes the saved plan. Nothing is applied without a visible, reviewable plan.

```yaml
- stage: Plan
  jobs:
    - job: TerraformPlan
      steps:
        - script: terraform plan -out=tfplan
        - publish: tfplan

- stage: Apply
  dependsOn: Plan
  jobs:
    - job: TerraformApply
      steps:
        - download: current
        - script: terraform apply tfplan
```

**4. Repo structure that reflects scope**

Modules are scoped to what they own. State files are namespaced by workstream. A platform engineer can read the repo structure and understand what owns what without opening every resource block.

```
/modules/
  networking/
  identity/
  management/
/platform/
  main.tf        # calls modules
  backend.tf     # state configuration
  variables.tf
```

## What this gives you

A delivery path that is auditable, reversible, and legible to someone other than the author. Changes are visible before they are applied. State is protected. Credentials are not stored anywhere.

That is the baseline. The next iteration adds policy validation in CI and drift detection reporting.
