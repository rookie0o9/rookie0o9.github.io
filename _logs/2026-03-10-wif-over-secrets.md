---
layout: log
title: "Why Workload Identity Federation Beats Secrets in Terraform Pipelines"
date: 2026-03-10
summary: "The case for federated auth in Azure DevOps when you want cleaner, safer Terraform delivery."
category: security
tags: [identity, azure, terraform, security]
reading_time: "6 min"
id: log-2026-03-10-wif-over-secrets
series: terraform-delivery
series_title: "Terraform Delivery"
series_order: 2
---

The case for replacing service principal secrets in Terraform pipelines with workload identity federation.

## The problem with client secrets

A client secret is a credential. It has a value, an expiry, and a rotation requirement. In practice:

- Secrets get stored in pipeline variable groups where access is hard to audit
- Rotation is a manual process that gets deferred until it breaks something
- Leaked secrets are indistinguishable from legitimate use until damage is done
- Every service connection that uses a secret is another credential to track, rotate, and protect

When a secret is compromised, you find out after the fact.

## What federation replaces this with

Workload Identity Federation replaces the secret with a trust relationship. Azure AD trusts a specific issuer (Azure DevOps, GitHub Actions) to assert identity claims. No secret is exchanged — the pipeline proves its identity via a signed JWT, Azure validates the claim against the configured federation, and issues a short-lived token.

```hcl
resource "azurerm_federated_identity_credential" "pipeline" {
  name                = "ado-pipeline-federation"
  resource_group_name = azurerm_resource_group.identity.name
  parent_id           = azurerm_user_assigned_identity.pipeline.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://vstoken.dev.azure.com/<org-id>"
  subject             = "sc://<org>/<project>/<service-connection-name>"
}
```

No secret value. Nothing to store, rotate, or leak.

## The operational difference

| | Client Secret | WIF |
|---|---|---|
| Credential to manage | Yes | No |
| Rotation required | Yes | No |
| Blast radius on leak | Immediate | None |
| Audit trail | Incomplete | Full — token request logged |
| Pipeline config | Secret in variable group | Service connection only |

## Where to be careful

Federation subjects are specific. The `subject` field must match the exact service connection, project, and organisation name. A misconfigured subject silently fails authentication — the trust relationship exists but the assertion does not match.

Test the federation before removing the secret. Once confirmed, remove the secret from the service principal and delete it from the variable group. Do not leave both active — two authentication paths means two attack surfaces.

The migration is a one-time cost. The operational simplification is permanent.
