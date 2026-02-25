# Architecture: terraform-digitalocean-container-registry

## Overview

This module provisions a DigitalOcean Container Registry, which is a private Docker-compatible image registry hosted on DigitalOcean infrastructure. It also manages scoped Docker credentials for authenticating against that registry.

The module wraps two DigitalOcean resources:

- `digitalocean_container_registry` — creates the registry itself with a chosen subscription tier and region.
- `digitalocean_container_registry_docker_credentials` — generates Docker credentials (a `.dockerconfigjson`-formatted token) with a configurable expiry and optional write access.

A `labels` sub-module call is used to derive a consistent, environment-prefixed name for the registry (e.g. `app-test-container-registry`).

---

## Subscription Tiers

DigitalOcean Container Registry is offered in three tiers. Choose the tier that matches your storage and repository requirements.

| Tier         | Slug           | Storage    | Private Repositories |
|--------------|----------------|------------|----------------------|
| Starter      | `starter`      | 500 MB     | 1                    |
| Basic        | `basic`        | 5 GB       | 5                    |
| Professional | `professional` | 100 GB     | Unlimited            |

The `subscription_tier_slug` variable controls which tier is provisioned. Changing the tier on an existing registry is supported in-place by the provider.

---

## Region Placement

The registry must be placed in a supported DigitalOcean region via the `region` variable. Locating the registry in the same region as your Kubernetes cluster or Droplets reduces image pull latency and avoids cross-region data transfer fees.

Supported region slugs include: `nyc1`, `nyc3`, `sfo3`, `ams3`, `sgp1`, `lon1`, `fra1`, `tor1`, `blr1`, `syd1`.

---

## Docker Credentials

The `digitalocean_container_registry_docker_credentials` resource produces a time-limited credential token. Key considerations:

- **Write access**: Controlled by the `write` variable (default `false`). Set to `true` only for CI/CD pipelines that push images.
- **Expiry**: The `expiry_seconds` variable defaults to `1576800000` (approximately 50 years). For short-lived CI tokens, use a smaller value such as `3600` (1 hour).
- The `docker_credentials` output is marked `sensitive` and contains the raw `.dockerconfigjson` value suitable for use as a Kubernetes Secret.

---

## Integration with Kubernetes (imagePullSecrets)

To pull images from a private registry in a Kubernetes cluster, the Docker credentials output must be stored as a Kubernetes Secret of type `kubernetes.io/dockerconfigjson`.

Typical workflow:

1. Set `write = false` and choose an appropriate `expiry_seconds` for a read-only pull token.
2. Pass the `docker_credentials` output to a `kubernetes_secret` resource in a separate Terraform root module or via an external script.
3. Reference the secret name in the `imagePullSecrets` field of your Pod or ServiceAccount spec.

Example (conceptual, outside this module):

```hcl
resource "kubernetes_secret" "registry" {
  metadata {
    name      = "do-registry"
    namespace = "default"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = module.container_registry.docker_credentials
  }
}
```

---

## Operational Checklist

- **Garbage collection**: DigitalOcean does not automatically reclaim storage from untagged or deleted manifest layers. Run garbage collection via the DigitalOcean API or control panel periodically to reclaim storage.
- **Image tagging policy**: Avoid using the `latest` tag in production. Use immutable, content-addressed tags (e.g. Git SHA or semantic version) to ensure reproducible deployments and to make garbage collection safe.
- **Credential rotation**: Terraform manages a single credential resource. To rotate credentials, `taint` or `replace` the `digitalocean_container_registry_docker_credentials.main` resource and re-apply.
- **Tier upgrades**: Upgrading the subscription tier is non-destructive. Downgrading may fail if current storage usage exceeds the lower tier's limit.
- **Access control**: Use `write = false` for tokens distributed to production workloads. Restrict write-enabled tokens to CI/CD pipelines only.
- **Sensitive output**: The `docker_credentials` output is sensitive. Avoid logging or printing it. Use `terraform output -json docker_credentials` only in secured environments.
