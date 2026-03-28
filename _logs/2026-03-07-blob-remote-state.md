---
layout: log
title: "Azure Blob Remote State Done Properly"
date: 2026-03-07
summary: "What I consider the minimum viable baseline for Terraform state, locking, and operational sanity in Azure."
category: ops
tags: [terraform, azure-storage, state, ops]
reading_time: "5 min"
id: log-2026-03-07-blob-remote-state
series: terraform-delivery
series_title: "Terraform Delivery"
series_order: 1
---

Remote state in Azure is straightforward to set up and easy to get wrong in ways that compound later.

This is the minimum viable baseline.

## The storage account

```hcl
resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${var.environment}${var.postfix}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }
}
```

Versioning and soft-delete are not optional. They are the difference between a recoverable state corruption and a permanent one.

## Access control

Use RBAC, not access keys.

```hcl
resource "azurerm_role_assignment" "tfstate_contributor" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.service_principal_id
}
```

Disable `allow_blob_public_access`. If your pipeline uses workload identity federation, disable storage account key access entirely. Keys are credentials — they rotate poorly and expire badly.

## The backend block

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-prod"
    storage_account_name = "tfstateprodabc123"
    container_name       = "tfstate"
    key                  = "platform/core.tfstate"
    use_oidc             = true
  }
}
```

`use_oidc = true` removes the credential from the backend configuration entirely. The pipeline authenticates via federated identity — no client secret required.

## State file naming

Use a structured key path. `platform/core.tfstate` is more useful than `core.tfstate` when multiple workstreams share a container. The path becomes the namespace.

## What this prevents

- Concurrent apply conflicts via automatic blob lease locking
- State loss via soft-delete and versioning
- Credential exposure via RBAC-only access
- Blast radius expansion via per-workstream state isolation

This is the baseline. Everything else — private endpoints, customer-managed keys, geo-redundant storage — is additive from here.
