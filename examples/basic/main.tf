provider "digitalocean" {}

locals {
  name        = "app"
  environment = "test"
  region      = "nyc3"
}

##------------------------------------------------
## Container Registry module call — minimal/basic
## Uses starter tier with read-only credentials.
## No Kubernetes integration.
##------------------------------------------------
module "container_registry" {
  source = "./../../"

  name        = local.name
  environment = local.environment
  region      = local.region

  subscription_tier_slug = "starter"

  # Read-only credentials valid for ~50 years (default)
  write          = false
  expiry_seconds = 1576800000
}
