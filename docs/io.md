# Inputs and Outputs: terraform-digitalocean-container-registry

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| `environment` | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| `label_order` | Label order, e.g. `name`, `application`. | `list(any)` | `["name", "environment"]` | no |
| `managedby` | ManagedBy, e.g. `terraform-do-modules` or `hello@clouddrove.com`. | `string` | `"terraform-do-modules"` | no |
| `enabled` | Whether to create the resources. Set to `false` to prevent the module from creating any resources. | `bool` | `true` | no |
| `subscription_tier_slug` | The slug identifier for the subscription tier to use (`starter`, `basic`, or `professional`). | `string` | `"starter"` | no |
| `region` | The region in which to create the registry, e.g. `syd1`, `nyc3`, `blr1`. | `string` | `"syd1"` | no |
| `write` | Allow write access to the container registry. Defaults to `false`. | `bool` | `false` | no |
| `expiry_seconds` | The amount of time in seconds before the Docker credentials expire. Must be greater than 0 and less than 1576800000. | `number` | `1576800000` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ID of the container registry. |
| `name` | The name of the container registry. |
| `subscription_tier_slug` | The slug identifier for the subscription tier. |
| `region` | The slug identifier for the region. |
| `endpoint` | The URL endpoint of the container registry. |
| `server_url` | The domain of the container registry. |
| `storage_usage_bytes` | The amount of storage used in the registry in bytes. |
| `created_at` | The date and time when the registry was created. |
| `docker_credentials` | Credentials for the container registry (sensitive). |
| `expiry_seconds` | Number of seconds after creation for the token to expire. |
| `credential_expiration_time` | The date and time the registry access token will expire. |
